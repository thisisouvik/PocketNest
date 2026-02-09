import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocketnest/core/navigation/cubit/app_flow_cubit.dart';
import 'package:pocketnest/core/theme/app_theme.dart';
import 'package:pocketnest/core/utils/app_assets.dart';

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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final sheetHeight = constraints.maxHeight * 0.62;

            return Stack(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 20,
                      left: 24,
                      right: 24,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(AppAssets.appTextLogo, height: 44),
                        const SizedBox(height: 14),
                        Column(
                          children: [
                            Text(
                              'Family Finances',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Alkalami',
                                fontSize: 34,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              'Simplified',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'AkayaKanadaka',
                                fontSize: 34,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    height: sheetHeight,
                    width: double.infinity,
                    child: FadeTransition(
                      opacity: _slideAnimation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.12),
                          end: Offset.zero,
                        ).animate(_slideAnimation),
                        child: _NestSheet(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(24, 44, 24, 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Welcome to the PocketNest',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Open Your Nest',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 28),
                                _buildAuthButton(
                                  context,
                                  label: 'Continue with Phone',
                                  backgroundColor: AppTheme.buttonDarkColor,
                                  textColor: Colors.white,
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Phone authentication coming soon',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 14),
                                _buildAuthButton(
                                  context,
                                  label: 'Continue with Google',
                                  backgroundColor: Colors.white,
                                  textColor: Colors.black,
                                  icon: FontAwesomeIcons.google,
                                  onPressed: () {
                                    context
                                        .read<AppFlowCubit>()
                                        .loginWithGoogle();
                                  },
                                ),
                                const SizedBox(height: 14),
                                _buildAuthButton(
                                  context,
                                  label: 'Continue with Apple',
                                  backgroundColor: Colors.black,
                                  textColor: Colors.white,
                                  icon: FontAwesomeIcons.apple,
                                  onPressed: () {
                                    context
                                        .read<AppFlowCubit>()
                                        .loginWithApple();
                                  },
                                ),
                                const SizedBox(height: 18),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                  ),
                                  child: Text.rich(
                                    textAlign: TextAlign.center,
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text:
                                              'By continuing, you agree to our ',
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
                                            decoration:
                                                TextDecoration.underline,
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
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
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
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: backgroundColor == Colors.white
            ? Border.all(color: AppTheme.borderColor.withOpacity(0.6))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  FaIcon(icon, color: textColor, size: 20),
                  const SizedBox(width: 12),
                ],
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
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

class _NestSheet extends StatelessWidget {
  const _NestSheet({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PhysicalShape(
      color: AppTheme.cardBackground,
      elevation: 6,
      shadowColor: Colors.black.withOpacity(0.12),
      clipper: const _NestClipper(curveDepth: 44),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          border: Border.all(
            color: AppTheme.borderColor.withOpacity(0.7),
            width: 1,
          ),
        ),
        child: child,
      ),
    );
  }
}

class _NestClipper extends CustomClipper<Path> {
  const _NestClipper({required this.curveDepth});

  final double curveDepth;

  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.quadraticBezierTo(size.width / 2, curveDepth * 2, size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_NestClipper oldClipper) {
    return oldClipper.curveDepth != curveDepth;
  }
}
