import 'package:flutter/material.dart';
import 'package:pocketnest/core/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GrowTab extends StatefulWidget {
  const GrowTab({super.key, required this.userId});

  final String userId;

  @override
  State<GrowTab> createState() => _GrowTabState();
}

class _GrowTabState extends State<GrowTab> {
  bool _isLoading = true;
  Map<String, dynamic>? _onboardingData;
  List<Map<String, dynamic>> _roadmapSteps = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final supabase = Supabase.instance.client;

      // Load onboarding data
      final onboardingResponse = await supabase
          .from('onboarding_responses')
          .select('responses')
          .eq('user_id', widget.userId)
          .maybeSingle();

      setState(() {
        _onboardingData = onboardingResponse?['responses'];
        _roadmapSteps = _generateRoadmapSteps();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _generateRoadmapSteps() {
    return [
      {
        'title': 'Build emergency buffer',
        'description': 'Start with one month of essentials.',
        'icon': Icons.shield_outlined,
        'completed': false,
      },
      {
        'title': 'Clear high-interest debt',
        'description': 'Reduce costly obligations first.',
        'icon': Icons.trending_down,
        'completed': false,
      },
      {
        'title': 'Start steady investing',
        'description': 'Begin with small, consistent amounts.',
        'icon': Icons.show_chart,
        'completed': false,
      },
      {
        'title': 'Automate savings',
        'description': 'Set up automatic transfers monthly.',
        'icon': Icons.schedule,
        'completed': false,
      },
      {
        'title': 'Review quarterly',
        'description': 'Check progress every three months.',
        'icon': Icons.calendar_today_outlined,
        'completed': false,
      },
    ];
  }

  String _getRiskLevel() {
    if (_onboardingData == null) return 'Balanced';

    final riskPreference = _onboardingData!['growth_preference']?['value'];
    if (riskPreference == 'Safe and steady') return 'Conservative';
    if (riskPreference == 'Taking chances for bigger gains')
      return 'Adventurous';
    return 'Balanced';
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

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Grow',
                style: TextStyle(
                  fontFamily: 'Alkalami',
                  fontSize: 28,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Build financial strength, your way.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 22),

              // Section 1: Growth Snapshot
              _GrowthSnapshotCard(riskLevel: _getRiskLevel()),
              const SizedBox(height: 20),

              // Section 2: Safe Growth Roadmap
              const Text(
                'Your roadmap',
                style: TextStyle(
                  fontFamily: 'Alkalami',
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              ..._roadmapSteps.map(
                (step) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _RoadmapStepCard(
                    title: step['title'],
                    description: step['description'],
                    icon: step['icon'],
                    completed: step['completed'],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Section 3: Wealth Learning Bites
              const Text(
                'Learn the basics',
                style: TextStyle(
                  fontFamily: 'Alkalami',
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              _LearningBiteCard(
                title: 'What is compounding?',
                duration: '2 min read',
                icon: Icons.auto_graph,
              ),
              const SizedBox(height: 8),
              _LearningBiteCard(
                title: 'Why diversification protects you',
                duration: '3 min read',
                icon: Icons.pie_chart_outline,
              ),
              const SizedBox(height: 8),
              _LearningBiteCard(
                title: 'How risk changes with time',
                duration: '2 min read',
                icon: Icons.timeline,
              ),
              const SizedBox(height: 24),

              // Section 4: Premium Blueprint
              _PremiumBlueprintPreview(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// Growth Snapshot Card
class _GrowthSnapshotCard extends StatelessWidget {
  const _GrowthSnapshotCard({required this.riskLevel});

  final String riskLevel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your growth snapshot',
            style: TextStyle(
              fontFamily: 'Alkalami',
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 14),

          // Emergency Fund Status
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  size: 18,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Emergency buffer',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Getting started',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Risk Comfort Level
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.speed,
                  size: 18,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Risk comfort',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      riskLevel,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: 0.25,
              minHeight: 6,
              backgroundColor: AppTheme.borderColor.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppTheme.primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Supportive Message
          Text(
            "You're building steadily. Small consistency matters.",
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// Roadmap Step Card
class _RoadmapStepCard extends StatelessWidget {
  const _RoadmapStepCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.completed,
  });

  final String title;
  final String description;
  final IconData icon;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: completed
                  ? const Color(0xFFE8F5E9)
                  : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              completed ? Icons.check_circle : icon,
              size: 18,
              color: completed
                  ? AppTheme.primaryColor
                  : AppTheme.textSecondary.withOpacity(0.6),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Learning Bite Card
class _LearningBiteCard extends StatelessWidget {
  const _LearningBiteCard({
    required this.title,
    required this.duration,
    required this.icon,
  });

  final String title;
  final String duration;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Learning content coming soon!'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF3E5F5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: AppTheme.primaryColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    duration,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

// Premium Blueprint Preview
class _PremiumBlueprintPreview extends StatelessWidget {
  const _PremiumBlueprintPreview();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F0),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFE0B2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB74D),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.diamond, size: 12, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'Premium',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Icon(
                Icons.lock_outline,
                size: 18,
                color: AppTheme.textSecondary.withOpacity(0.6),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Your life-stage growth blueprint',
            style: TextStyle(
              fontFamily: 'Alkalami',
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'See how your savings could be structured based on your age, goals, and comfort with risk.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Includes:',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          _PremiumFeatureItem(
            icon: Icons.pie_chart_outline,
            text: 'Allocation overview based on life stage',
          ),
          const SizedBox(height: 6),
          _PremiumFeatureItem(
            icon: Icons.show_chart,
            text: 'Growth projection calculator',
          ),
          const SizedBox(height: 6),
          _PremiumFeatureItem(
            icon: Icons.lightbulb_outline,
            text: 'AI-powered strategy explanation',
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Premium features coming soon!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Unlock Blueprint',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
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

// Premium Feature Item
class _PremiumFeatureItem extends StatelessWidget {
  const _PremiumFeatureItem({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFFFF9800)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
