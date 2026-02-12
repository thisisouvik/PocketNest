import 'package:flutter/material.dart';
import 'package:pocketnest/core/theme/app_theme.dart';
import 'package:pocketnest/features/onboarding/screens/onboarding_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key, required this.userId});

  final String userId;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  bool _isLoading = true;
  Map<String, dynamic>? _profile;
  Map<String, dynamic>? _onboardingData;
  bool _notificationsEnabled = true;
  bool _autoRefreshEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final supabase = Supabase.instance.client;
      final profileResponse = await supabase
          .from('profiles')
          .select('*')
          .eq('id', widget.userId)
          .maybeSingle();

      final onboardingResponse = await supabase
          .from('onboarding_responses')
          .select('responses')
          .eq('user_id', widget.userId)
          .maybeSingle();

      setState(() {
        _profile = profileResponse;
        _onboardingData = onboardingResponse?['responses'] != null
            ? Map<String, dynamic>.from(onboardingResponse?['responses'])
            : null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _openOnboarding() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OnboardingScreen(userId: widget.userId),
      ),
    );
    _loadProfileData();
  }

  String _getDisplayName() {
    final profileName = _profile?['full_name']?.toString().trim() ?? '';
    if (profileName.isNotEmpty) return profileName;
    final profileEmail = _profile?['email']?.toString().trim() ?? '';
    if (profileEmail.isNotEmpty) return profileEmail;
    return 'Friend';
  }

  String _getEmail() {
    return _profile?['email']?.toString().trim() ?? 'Not set';
  }

  bool _isPremium() {
    final value = _profile?['is_premium'];
    return value is bool ? value : false;
  }

  String _getOnboardingValue(String key) {
    if (_onboardingData == null) return 'Not set';
    final entry = _onboardingData![key];
    if (entry is Map && entry['value'] != null) {
      final text = entry['value'].toString().trim();
      return text.isEmpty ? 'Not set' : text;
    }
    final text = entry?.toString().trim() ?? '';
    return text.isEmpty ? 'Not set' : text;
  }

  int _completedProfileCount() {
    if (_onboardingData == null) return 0;
    const keys = [
      'money_stretch',
      'time_available',
      'shopping_style',
      'who_for',
      'money_feelings',
      'growth_preference',
    ];
    var count = 0;
    for (final key in keys) {
      final entry = _onboardingData![key];
      String value = '';
      if (entry is Map && entry['value'] != null) {
        value = entry['value'].toString().trim();
      } else if (entry != null) {
        value = entry.toString().trim();
      }
      if (value.isNotEmpty) {
        count += 1;
      }
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
        ),
      );
    }

    final completedCount = _completedProfileCount();
    const totalCount = 6;
    final completionValue = (completedCount / totalCount).clamp(0.0, 1.0);
    final hasAnyProfile = completedCount > 0;
    final onboardingCompleted =
        (_profile?['onboarding_completed'] == true) || completionValue >= 1.0;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Profile',
                style: TextStyle(
                  fontFamily: 'Alkalami',
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Your calm control center.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 18),
              _SectionCard(
                title: 'Account Overview',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getDisplayName(),
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getEmail(),
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_isPremium())
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF8F0),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFFFFE0B2),
                              ),
                            ),
                            child: const Text(
                              'Premium',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Edit account soon.')),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: AppTheme.borderColor.withOpacity(0.6),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Edit Account',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Your Financial Profile',
                subtitle: 'This helps personalize your insights.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!hasAnyProfile)
                      _ProfileSetupBanner(
                        title: 'Complete your financial profile',
                        body:
                            'Set up your preferences to receive more personalized guidance.',
                        buttonText: 'Continue setup',
                        onPressed: _openOnboarding,
                      )
                    else if (!onboardingCompleted)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Profile ${(completionValue * 100).round()}% complete',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: completionValue,
                              minHeight: 6,
                              backgroundColor: AppTheme.borderColor.withOpacity(
                                0.25,
                              ),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppTheme.primaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _openOnboarding,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Finish setup',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          _ProfileRow(
                            label: 'Household size',
                            value: _getOnboardingValue('who_for'),
                          ),
                          _ProfileRow(
                            label: 'Risk comfort level',
                            value: _getOnboardingValue('growth_preference'),
                          ),
                          _ProfileRow(
                            label: 'Time available',
                            value: _getOnboardingValue('time_available'),
                          ),
                          _ProfileRow(
                            label: 'Shopping style',
                            value: _getOnboardingValue('shopping_style'),
                          ),
                          _ProfileRow(
                            label: 'Financial focus area',
                            value: _getOnboardingValue('money_stretch'),
                            isLast: true,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Update anytime - your recommendations adjust automatically.',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Your Plan',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_isPremium())
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Premium active',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _ActionRow(
                            label: 'Manage subscription',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Manage subscription soon.'),
                                ),
                              );
                            },
                          ),
                          _ActionRow(
                            label: 'Restore purchase',
                            isLast: true,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Restore purchase soon.'),
                                ),
                              );
                            },
                          ),
                        ],
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'You are currently on the Free plan.',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Premium details soon.'),
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: AppTheme.borderColor.withOpacity(0.6),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Explore Premium',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'App Settings',
                child: Column(
                  children: [
                    _ToggleRow(
                      label: 'Notifications',
                      value: _notificationsEnabled,
                      onChanged: (value) {
                        setState(() {
                          _notificationsEnabled = value;
                        });
                      },
                    ),
                    _ToggleRow(
                      label: 'Data refresh preference',
                      value: _autoRefreshEnabled,
                      onChanged: (value) {
                        setState(() {
                          _autoRefreshEnabled = value;
                        });
                      },
                    ),
                    _ActionRow(
                      label: 'Privacy Policy',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Privacy policy soon.')),
                        );
                      },
                    ),
                    _ActionRow(
                      label: 'Terms & Conditions',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Terms soon.')),
                        );
                      },
                    ),
                    _ActionRow(
                      label: 'About PocketNest',
                      isLast: true,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('About page soon.')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, this.subtitle, required this.child});

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Alkalami',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _ProfileSetupBanner extends StatelessWidget {
  const _ProfileSetupBanner({
    required this.title,
    required this.body,
    required this.buttonText,
    required this.onPressed,
  });

  final String title;
  final String body;
  final String buttonText;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Edit profile field soon.')),
        );
      },
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: AppTheme.textSecondary,
              ),
            ],
          ),
          if (!isLast) ...[
            const SizedBox(height: 10),
            Divider(color: AppTheme.borderColor.withOpacity(0.3), height: 1),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.label,
    required this.onTap,
    this.isLast = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: AppTheme.textSecondary,
              ),
            ],
          ),
          if (!isLast) ...[
            const SizedBox(height: 10),
            Divider(color: AppTheme.borderColor.withOpacity(0.3), height: 1),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppTheme.primaryColor,
            ),
          ],
        ),
        const SizedBox(height: 6),
        Divider(color: AppTheme.borderColor.withOpacity(0.3), height: 1),
        const SizedBox(height: 6),
      ],
    );
  }
}
