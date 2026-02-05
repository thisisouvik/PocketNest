import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocketnest/core/navigation/cubit/app_flow_cubit.dart';
import 'package:pocketnest/core/theme/app_theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Logo at top
              SvgPicture.asset(
                'assets/images/branding/appTextLogo.svg',
                height: 50,
              ),
              const SizedBox(height: 48),

              // Animated content
              FadeTransition(
                opacity: _slideAnimation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.2),
                    end: Offset.zero,
                  ).animate(_slideAnimation),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Headline
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Family Finances\n',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            TextSpan(
                              text: 'Simplified',
                              style: TextStyle(
                                fontFamily: 'AkayadKanadaka',
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Welcome Card Container
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBackground,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.borderColor,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Welcome to PocketNest',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Open Your Nest.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Auth Buttons
                      // Continue with Phone
                      _buildAuthButton(
                        context,
                        label: 'Continue with Phone',
                        backgroundColor: AppTheme.buttonDarkColor,
                        textColor: Colors.white,
                        onPressed: () {
                          // TODO: Implement phone auth
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Phone authentication coming soon',
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Continue with Google
                      _buildAuthButton(
                        context,
                        label: 'Continue with Google',
                        backgroundColor: Colors.white,
                        textColor: Colors.black,
                        icon: FontAwesomeIcons.google,
                        onPressed: () {
                          context.read<AppFlowCubit>().loginWithGoogle();
                        },
                      ),
                      const SizedBox(height: 16),

                      // Continue with Apple
                      _buildAuthButton(
                        context,
                        label: 'Continue with Apple',
                        backgroundColor: Colors.black,
                        textColor: Colors.white,
                        icon: FontAwesomeIcons.apple,
                        onPressed: () {
                          context.read<AppFlowCubit>().loginWithApple();
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // Terms & Conditions at bottom
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text.rich(
                      textAlign: TextAlign.center,
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'By continuing, you agree to our ',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          TextSpan(
                            text: 'Terms & Conditions',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryColor,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          TextSpan(
                            text: ' and ',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryColor,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthButton(
    BuildContext context, {
    required String label,
    required Color backgroundColor,
    required Color textColor,
    IconData? icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  FaIcon(
                    icon,
                    color: textColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                ],
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
