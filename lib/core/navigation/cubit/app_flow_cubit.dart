import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pocketnest/config/environment_config.dart';

part 'app_flow_state.dart';

class AppFlowCubit extends Cubit<AppFlowState> {
  final SupabaseClient supabaseClient;
  final GoogleSignIn googleSignIn;
  String? _currentUserId;

  AppFlowCubit({required this.supabaseClient, GoogleSignIn? googleSignIn})
    : googleSignIn =
          googleSignIn ??
          GoogleSignIn(serverClientId: EnvironmentConfig.googleWebClientId),
      super(const SplashState());

  Future<void> initializeApp() async {
    try {
      // Show splash for 2 seconds
      await Future.delayed(const Duration(seconds: 2));

      // Check authentication status (Supabase)
      final user = supabaseClient.auth.currentUser;

      if (user == null) {
        // User is not authenticated
        emit(const UnauthenticatedState());
      } else {
        // User is authenticated, check if profile is complete
        final userId = user.id;
        await _checkProfileCompletion(userId);
      }
    } catch (e) {
      emit(AppFlowErrorState(message: e.toString()));
    }
  }

  Future<void> _checkProfileCompletion(String userId) async {
    try {
      final response = await supabaseClient
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        // Profile doesn't exist, create it with onboarding_completed = false
        _currentUserId = userId;

        // Get user email/name from auth
        final authUser = supabaseClient.auth.currentUser;
        final fullName =
            (authUser?.userMetadata?['full_name'] ??
                    authUser?.userMetadata?['name'] ??
                    authUser?.userMetadata?['fullName'] ??
                    '')
                .toString()
                .trim();

        await supabaseClient.from('profiles').upsert({
          'id': userId,
          'email': authUser?.email,
          'full_name': fullName.isNotEmpty
              ? fullName
              : (authUser?.email?.split('@').first ?? 'Friend'),
          'onboarding_completed': false,
        });

        // Allow entry even if profile is incomplete
        emit(ProfileIncompleteState(userId: userId));
      } else {
        _currentUserId = userId;
        // Check if user has already completed onboarding
        final onboardingCompleted = response['onboarding_completed'] ?? false;
        if (onboardingCompleted) {
          // User already did onboarding, go straight to home
          emit(AuthenticatedState(userId: userId));
        } else {
          // Profile is incomplete, allow login and prompt later
          emit(ProfileIncompleteState(userId: userId));
        }
      }
    } catch (e) {
      // If we can't check profile, allow entry and prompt later
      _currentUserId = userId;
      emit(ProfileIncompleteState(userId: userId));
    }
  }

  Future<void> completeOnboarding() async {
    if (_currentUserId == null) {
      return;
    }

    try {
      // Mark onboarding as completed in the database
      await supabaseClient.from('profiles').upsert({
        'id': _currentUserId,
        'onboarding_completed': true,
      });

      emit(AuthenticatedState(userId: _currentUserId!));
    } catch (e) {
      emit(AppFlowErrorState(message: 'Failed to complete onboarding: $e'));
    }
  }

  Future<Map<String, dynamic>?> loadOnboardingResponses() async {
    if (_currentUserId == null) {
      return null;
    }

    final response = await supabaseClient
        .from('onboarding_responses')
        .select('responses')
        .eq('user_id', _currentUserId!)
        .maybeSingle();

    if (response == null || response['responses'] == null) {
      return null;
    }

    return Map<String, dynamic>.from(response['responses'] as Map);
  }

  Future<void> loginWithGoogle() async {
    try {
      emit(const SplashState()); // Show loading state

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        emit(const UnauthenticatedState());
        return;
      }

      final googleAuth = await googleUser.authentication;

      if (googleAuth.idToken == null) {
        emit(
          const AppFlowErrorState(
            message:
                'Google sign-in failed: missing ID token. Check Web Client ID setup.',
          ),
        );
        return;
      }

      // Sign in with Supabase using OAuth
      final response = await supabaseClient.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );

      final user = response.user;
      if (user == null) {
        emit(const UnauthenticatedState());
        return;
      }

      await _checkProfileCompletion(user.id);
    } catch (e) {
      emit(AppFlowErrorState(message: e.toString()));
    }
  }

  Future<void> loginWithApple() async {
    try {
      emit(const SplashState()); // Show loading state

      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      // Sign in with Supabase using OAuth
      final response = await supabaseClient.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: appleCredential.identityToken!,
        nonce: rawNonce,
      );

      final user = response.user;
      if (user == null) {
        emit(const UnauthenticatedState());
        return;
      }

      await _checkProfileCompletion(user.id);
    } catch (e) {
      emit(AppFlowErrorState(message: e.toString()));
    }
  }

  Future<void> loginWithPhone(String phoneNumber) async {
    try {
      emit(const SplashState()); // Show loading state

      await supabaseClient.auth.signInWithOtp(phone: phoneNumber);

      // After OTP is sent, user needs to verify it
      // TODO: Handle OTP verification in UI
      emit(const UnauthenticatedState()); // Waiting for OTP verification
    } catch (e) {
      emit(AppFlowErrorState(message: e.toString()));
    }
  }

  /// Verify OTP for phone sign-in
  Future<void> verifyPhoneOtp(String phoneNumber, String otp) async {
    try {
      emit(const SplashState()); // Show loading state

      final response = await supabaseClient.auth.verifyOTP(
        phone: phoneNumber,
        token: otp,
        type: OtpType.sms,
      );

      final user = response.user;
      if (user == null) {
        emit(const UnauthenticatedState());
        return;
      }

      await _checkProfileCompletion(user.id);
    } catch (e) {
      emit(AppFlowErrorState(message: e.toString()));
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await supabaseClient.auth.signOut();
      await googleSignIn.signOut();
      _currentUserId = null;
      emit(const UnauthenticatedState());
    } catch (e) {
      emit(AppFlowErrorState(message: e.toString()));
    }
  }

  /// Complete user profile
  Future<void> completeProfile(
    String userId,
    Map<String, dynamic> profileData,
  ) async {
    try {
      await supabaseClient.from('profiles').upsert({
        'id': userId,
        ...profileData,
      });

      _currentUserId = userId;
      emit(AuthenticatedState(userId: userId));
    } catch (e) {
      emit(AppFlowErrorState(message: e.toString()));
    }
  }

  /// Sign up with email and password
  Future<void> signUpWithEmail(String email, String password) async {
    try {
      emit(const SplashState()); // Show loading state

      final response = await supabaseClient.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        emit(AppFlowErrorState(message: 'Sign up failed'));
        return;
      }

      // Profile incomplete, user needs to complete it
      emit(ProfileIncompleteState(userId: user.id));
    } catch (e) {
      emit(AppFlowErrorState(message: e.toString()));
    }
  }

  /// Sign in with email and password
  Future<void> loginWithEmail(String email, String password) async {
    try {
      emit(const SplashState()); // Show loading state

      final response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        emit(const UnauthenticatedState());
        return;
      }

      await _checkProfileCompletion(user.id);
    } catch (e) {
      emit(AppFlowErrorState(message: e.toString()));
    }
  }

  /// Generate random nonce for Apple Sign-In
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  /// Generate SHA256 hash of string (for Apple nonce)
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
