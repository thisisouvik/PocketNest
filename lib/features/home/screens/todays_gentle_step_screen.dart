import 'package:flutter/material.dart';
import 'package:pocketnest/core/theme/app_theme.dart';

class TodaysGentleStepScreen extends StatefulWidget {
  const TodaysGentleStepScreen({
    super.key,
    this.onboardingData,
    this.skippedOnboarding = false,
  });

  final Map<String, dynamic>? onboardingData;
  final bool skippedOnboarding;

  @override
  State<TodaysGentleStepScreen> createState() => _TodaysGentleStepScreenState();
}

class _TodaysGentleStepScreenState extends State<TodaysGentleStepScreen> {
  late final _GentleTask _task;
  late List<bool> _stepChecks;
  bool _completed = false;
  final TextEditingController _reflectionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _task = _selectTask();
    _stepChecks = List<bool>.filled(_task.steps.length, false);
  }

  @override
  void dispose() {
    _reflectionController.dispose();
    super.dispose();
  }

  bool get _allChecked => _stepChecks.every((step) => step);

  void _markCompleted() {
    setState(() {
      _completed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        title: const Text(
          'Today\'s Gentle Step',
          style: TextStyle(
            fontFamily: 'Alkalami',
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'One small action can make a difference.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _task.title,
                    style: TextStyle(
                      fontFamily: 'Alkalami',
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _task.savings,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _task.description,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...List.generate(
                    _task.steps.length,
                    (index) => _ChecklistRow(
                      label: _task.steps[index],
                      value: _stepChecks[index],
                      onChanged: (value) {
                        setState(() {
                          _stepChecks[index] = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reflection (optional)',
                    style: TextStyle(
                      fontFamily: 'Alkalami',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _reflectionController,
                    decoration: InputDecoration(
                      hintText: _task.reflectionHint,
                      hintStyle: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                      filled: true,
                      fillColor: AppTheme.cardBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _completed
                  ? _buildCompletedSection(context)
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _allChecked ? _markCompleted : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Mark as Completed',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedSection(BuildContext context) {
    return Column(
      children: [
        AnimatedScale(
          scale: _completed ? 1.0 : 0.9,
          duration: const Duration(milliseconds: 250),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: const [
                Icon(Icons.check_circle, color: AppTheme.primaryColor),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Well done. Small steps build strong habits.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 0,
            ),
            child: const Text(
              'Back to Home',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  _GentleTask _selectTask() {
    if (widget.skippedOnboarding || widget.onboardingData == null) {
      return _GentleTask.defaultTask;
    }

    final data = widget.onboardingData!;
    final moneyStretch = _getValue(data, 'money_stretch');
    final timeAvailable = _getValue(data, 'time_available');
    final shoppingStyle = _getValue(data, 'shopping_style');
    final growthPreference = _getValue(data, 'growth_preference');

    if (moneyStretch == 'Everyday essentials' ||
        moneyStretch == 'Housing and utilities') {
      return _GentleTask.grocerySwap;
    }

    if (timeAvailable == 'Just a few minutes') {
      return _GentleTask.quickBillCheck;
    }

    if (shoppingStyle == 'Often last-minute') {
      return _GentleTask.planOneMeal;
    }

    if (growthPreference == 'Learning more before deciding') {
      return _GentleTask.learnOneTerm;
    }

    return _GentleTask.defaultTask;
  }

  String _getValue(Map<String, dynamic> data, String key) {
    final entry = data[key];
    if (entry is Map && entry['value'] != null) {
      return entry['value'].toString();
    }
    return entry?.toString() ?? '';
  }
}

class _GentleTask {
  const _GentleTask({
    required this.title,
    required this.savings,
    required this.description,
    required this.steps,
    required this.reflectionHint,
  });

  final String title;
  final String savings;
  final String description;
  final List<String> steps;
  final String reflectionHint;

  static const _GentleTask grocerySwap = _GentleTask(
    title: 'Swap one grocery item today',
    savings: 'Estimated savings: \$6 this week',
    description:
        'Choose one regularly purchased item and check a lower-cost option.',
    steps: [
      'Identify one item you buy often',
      'Compare price with a similar option',
      'Choose the lower-cost alternative',
    ],
    reflectionHint: 'What did you switch?',
  );

  static const _GentleTask quickBillCheck = _GentleTask(
    title: 'Review one recurring bill',
    savings: 'Estimated savings: \$5 this week',
    description: 'Open one bill and check for a small fee or plan adjustment.',
    steps: [
      'Pick one bill you pay monthly',
      'Check for small fees or upgrades',
      'Note one possible savings tweak',
    ],
    reflectionHint: 'Which bill did you review?',
  );

  static const _GentleTask planOneMeal = _GentleTask(
    title: 'Plan one low-cost meal',
    savings: 'Estimated savings: \$7 this week',
    description: 'Pick one simple meal and list just the essentials you need.',
    steps: [
      'Choose one meal for the week',
      'List only the needed ingredients',
      'Skip extras you already have',
    ],
    reflectionHint: 'What meal did you plan?',
  );

  static const _GentleTask learnOneTerm = _GentleTask(
    title: 'Learn one money term',
    savings: 'Estimated savings: \$4 this week',
    description:
        'Pick one term you hear often and learn its simple definition.',
    steps: [
      'Choose one term you hear often',
      'Read a short, simple definition',
      'Write one sentence in your words',
    ],
    reflectionHint: 'Which term did you learn?',
  );

  static const _GentleTask defaultTask = _GentleTask(
    title: 'Track one small spend',
    savings: 'Estimated savings: \$3 this week',
    description:
        'Notice one small expense today and record it to build awareness.',
    steps: [
      'Pick one small purchase today',
      'Write down the amount',
      'Decide if it felt worth it',
    ],
    reflectionHint: 'What did you notice today?',
  );
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Checkbox(
              value: value,
              onChanged: (checked) => onChanged(checked ?? false),
              activeColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
