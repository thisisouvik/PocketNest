part of 'app_flow_cubit.dart';

abstract class AppFlowState {
  const AppFlowState();
}

class SplashState extends AppFlowState {
  const SplashState();
}

class UnauthenticatedState extends AppFlowState {
  const UnauthenticatedState();
}

class ProfileIncompleteState extends AppFlowState {
  final String userId;
  
  const ProfileIncompleteState({required this.userId});
}

class AuthenticatedState extends AppFlowState {
  final String userId;
  
  const AuthenticatedState({required this.userId});
}

class AppFlowErrorState extends AppFlowState {
  final String message;
  
  const AppFlowErrorState({required this.message});
}
