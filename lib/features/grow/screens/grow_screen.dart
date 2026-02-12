import 'package:flutter/material.dart';
import 'package:pocketnest/core/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GrowTab extends StatefulWidget {
  const GrowTab({super.key, required this.userId});

  final String userId;

  @override
  State<GrowTab> createState() => _GrowTabState();
}

class _GrowTabState extends State<GrowTab> with TickerProviderStateMixin {
  bool _isLoading = true;
  Map<String, dynamic>? _onboardingData;
  final List<_RoadmapStage> _journeyStages = [];
  int? _expandedStageIndex;
  final Map<int, int?> _expandedItemIndex = {};

  @override
  void initState() {
    super.initState();
    _initJourneyStages();
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
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _initJourneyStages() {
    _journeyStages
      ..clear()
      ..addAll([
        _RoadmapStage(
          title: 'Stage 1 — Build Your Foundation',
          subtitle: 'Strengthen your financial base before growing further.',
          items: [
            _RoadmapItem(
              title: 'Build emergency buffer',
              description: 'Aim for one month of essentials to start.',
            ),
            _RoadmapItem(
              title: 'Understand your risk comfort',
              description: 'Know what level helps you sleep well.',
            ),
            _RoadmapItem(
              title: 'Clear high-interest debt',
              description: 'Reduce costly balances before investing more.',
            ),
            _RoadmapItem(
              title: 'Track your monthly surplus',
              description: 'Spot the amount you can grow consistently.',
            ),
          ],
          accentColor: const Color(0xFFE8F5E9),
        ),
        _RoadmapStage(
          title: 'Stage 2 — Steady Growth',
          subtitle: 'Begin structured long-term wealth building.',
          items: [
            _RoadmapItem(
              title: 'Start steady investing',
              description: 'Small, consistent contributions add up.',
            ),
            _RoadmapItem(
              title: 'Learn diversification basics',
              description: 'Spread risk to keep growth steadier.',
            ),
            _RoadmapItem(
              title: 'Automate savings',
              description: 'Set transfers that happen without effort.',
            ),
            _RoadmapItem(
              title: 'Review quarterly',
              description: 'Check your plan every three months.',
            ),
          ],
          accentColor: const Color(0xFFE3F2FD),
        ),
        _RoadmapStage(
          title: 'Stage 3 — Strategic Optimization',
          subtitle: 'Advanced planning and long-term optimization tools.',
          items: [
            _RoadmapItem(
              title: 'Asset allocation refinement',
              description: 'Tune your mix for your life stage.',
            ),
            _RoadmapItem(
              title: 'Tax efficiency awareness',
              description: 'Learn which moves may reduce drag.',
            ),
            _RoadmapItem(
              title: 'Goal-based wealth modeling',
              description: 'Align growth to specific life goals.',
            ),
            _RoadmapItem(
              title: 'Long-term rebalancing strategy',
              description: 'Keep your plan aligned over time.',
            ),
          ],
          accentColor: const Color(0xFFF3E5F5),
          isPremium: true,
        ),
      ]);
  }

  double _stageProgress(int index) {
    if (index < 0 || index >= _journeyStages.length) return 0;
    final items = _journeyStages[index].items;
    if (items.isEmpty) return 0;
    final completed = items.where((item) => item.completed).length;
    return completed / items.length;
  }

  bool _isStage2Unlocked() => _stageProgress(0) >= 0.75;

  void _toggleStageExpanded(int index) {
    setState(() {
      if (_expandedStageIndex == index) {
        _expandedStageIndex = null;
      } else {
        _expandedStageIndex = index;
      }
      _expandedItemIndex.clear();
    });
  }

  void _toggleItemExpanded(int stageIndex, int itemIndex) {
    setState(() {
      final current = _expandedItemIndex[stageIndex];
      if (current == itemIndex) {
        _expandedItemIndex.remove(stageIndex);
      } else {
        _expandedItemIndex[stageIndex] = itemIndex;
      }
    });
  }

  void _toggleItemCompleted(int stageIndex, int itemIndex) {
    setState(() {
      _journeyStages[stageIndex].items[itemIndex].completed =
          !_journeyStages[stageIndex].items[itemIndex].completed;
    });
  }

  String _getRiskLevel() {
    if (_onboardingData == null) return 'Balanced';

    final riskPreference = _onboardingData!['growth_preference']?['value'];
    if (riskPreference == 'Safe and steady') return 'Conservative';
    if (riskPreference == 'Taking chances for bigger gains')
      return 'Adventurous';
    return 'Balanced';
  }

  Widget _buildGrowthJourneySection() {
    if (_journeyStages.length < 3) {
      return const SizedBox.shrink();
    }
    final stage2Unlocked = _isStage2Unlocked();

    return Column(
      children: [
        _buildRoadmapStageCard(
          stageIndex: 0,
          stage: _journeyStages[0],
          isExpanded: _expandedStageIndex == 0,
          isLocked: false,
          showProgress: true,
        ),
        if (stage2Unlocked)
          _buildStageSupportBanner()
        else
          const SizedBox(height: 10),
        _buildRoadmapStageCard(
          stageIndex: 1,
          stage: _journeyStages[1],
          isExpanded: _expandedStageIndex == 1,
          isLocked: !stage2Unlocked,
          showProgress: false,
          lockMessage: 'Complete most of Stage 1 to unlock.',
        ),
        const SizedBox(height: 10),
        _buildRoadmapStageCard(
          stageIndex: 2,
          stage: _journeyStages[2],
          isExpanded: _expandedStageIndex == 2,
          isLocked: false,
          showProgress: false,
          isPremium: true,
        ),
      ],
    );
  }

  Widget _buildStageSupportBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.spa_outlined, color: AppTheme.primaryColor),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              "You've built strong foundations. Ready for the next step?",
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => _toggleStageExpanded(1),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            ),
            child: const Text(
              'Explore Stage 2',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoadmapStageCard({
    required int stageIndex,
    required _RoadmapStage stage,
    required bool isExpanded,
    required bool isLocked,
    required bool showProgress,
    bool isPremium = false,
    String? lockMessage,
  }) {
    final content = Container(
      padding: const EdgeInsets.all(14),
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
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: stage.accentColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  stage.title,
                  style: const TextStyle(
                    fontFamily: 'Alkalami',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              if (isPremium)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB74D),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Premium',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              const SizedBox(width: 6),
              AnimatedRotation(
                turns: isExpanded ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  Icons.expand_more,
                  size: 20,
                  color: AppTheme.textSecondary.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            stage.subtitle,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppTheme.textSecondary,
            ),
          ),
          if (showProgress) ...[
            const SizedBox(height: 10),
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              tween: Tween<double>(begin: 0, end: _stageProgress(stageIndex)),
              builder: (context, value, child) => ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 6,
                  backgroundColor: AppTheme.borderColor.withOpacity(0.25),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryColor,
                  ),
                ),
              ),
            ),
          ],
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: isExpanded
                ? Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Column(
                      children: List.generate(
                        stage.items.length,
                        (index) => _buildChecklistItem(
                          stageIndex: stageIndex,
                          itemIndex: index,
                          item: stage.items[index],
                          isInteractive: !isPremium,
                          isPreview: isPremium,
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          if (isPremium && isExpanded)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Advanced growth coming soon!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Unlock Advanced Growth',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    final card = GestureDetector(
      onTap: () => _toggleStageExpanded(stageIndex),
      child: content,
    );

    if (!isLocked) {
      return card;
    }

    return Stack(
      children: [
        Opacity(opacity: 0.7, child: AbsorbPointer(child: card)),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.cardBackground.withOpacity(0.6),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  lockMessage ?? 'Complete most of Stage 1 to unlock.',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChecklistItem({
    required int stageIndex,
    required int itemIndex,
    required _RoadmapItem item,
    required bool isInteractive,
    required bool isPreview,
  }) {
    final isExpanded = _expandedItemIndex[stageIndex] == itemIndex;
    final isCompleted = item.completed;

    final content = Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: isInteractive
                ? () => _toggleItemExpanded(stageIndex, itemIndex)
                : null,
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? const Color(0xFFE8F5E9)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isCompleted
                          ? AppTheme.primaryColor
                          : AppTheme.borderColor,
                      width: 1.4,
                    ),
                  ),
                  child: isCompleted
                      ? const Icon(
                          Icons.check,
                          size: 14,
                          color: AppTheme.primaryColor,
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.title,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  isInteractive && isExpanded
                      ? Icons.expand_less
                      : Icons.expand_more,
                  size: 18,
                  color: AppTheme.textSecondary.withOpacity(0.7),
                ),
              ],
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: isInteractive && isExpanded
                ? Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.description,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextButton.icon(
                          onPressed: isInteractive
                              ? () =>
                                    _toggleItemCompleted(stageIndex, itemIndex)
                              : null,
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.primaryColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                          ),
                          icon: Icon(
                            isCompleted
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            size: 16,
                          ),
                          label: Text(
                            isCompleted ? 'Marked done' : 'Mark as done',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );

    if (!isPreview) {
      return content;
    }

    return Opacity(opacity: 0.55, child: content);
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

              // Section 2: Growth Journey
              const Text(
                'Your Growth Journey',
                style: TextStyle(
                  fontFamily: 'Alkalami',
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'A steady path toward financial strength.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              _buildGrowthJourneySection(),
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

class _RoadmapStage {
  _RoadmapStage({
    required this.title,
    required this.subtitle,
    required this.items,
    required this.accentColor,
    this.isPremium = false,
  });

  final String title;
  final String subtitle;
  final List<_RoadmapItem> items;
  final Color accentColor;
  final bool isPremium;
}

class _RoadmapItem {
  _RoadmapItem({required this.title, required this.description})
    : completed = false;

  final String title;
  final String description;
  bool completed;
}
