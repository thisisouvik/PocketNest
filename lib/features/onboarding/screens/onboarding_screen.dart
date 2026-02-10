import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pocketnest/core/theme/app_theme.dart';
import 'package:pocketnest/core/utils/app_assets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.userId, this.onCompleted});

  final String userId;
  final Future<void> Function()? onCompleted;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final PageController _pageController = PageController();
  final List<int?> _selectedIndex = List<int?>.filled(_questions.length, null);
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _goToNext() async {
    if (_currentIndex < _questions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
      return;
    }

    await _saveResponses();

    if (widget.onCompleted != null) {
      await widget.onCompleted!();
      return;
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: const _OnboardingDoneScreen(),
          );
        },
      ),
    );
  }

  Future<void> _skip() async {

    if (widget.onCompleted != null) {
      await widget.onCompleted!();
      return;
    }

    Navigator.of(context).pop();
  }

  Map<String, dynamic> _buildResponses() {
    final Map<String, dynamic> responses = {};

    for (var i = 0; i < _questions.length; i++) {
      final selected = _selectedIndex[i];
      if (selected == null) {
        continue;
      }

      final question = _questions[i];
      responses[question.id] = {
        'index': selected,
        'value': question.options[selected],
      };
    }

    return responses;
  }

  Future<void> _saveResponses() async {
    final payload = _buildResponses();
    if (payload.isEmpty) {
      return;
    }

    await _supabase.from('onboarding_responses').upsert({
      'user_id': widget.userId,
      'responses': payload,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            SvgPicture.asset(AppAssets.appTextLogo, height: 36),
            const SizedBox(height: 16),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _questions.length,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final question = _questions[index];
                  return _QuestionPage(
                    question: question,
                    selectedIndex: _selectedIndex[index],
                    onSelect: (value) async {
                      setState(() {
                        _selectedIndex[index] = value;
                      });
                      await _saveResponses();
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () async {
                      await _skip();
                    },
                    child: Text(
                      'Skip for now',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () async {
                      await _goToNext();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      elevation: 6,
                      shadowColor: Colors.black.withOpacity(0.18),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _currentIndex == _questions.length - 1
                              ? 'Finish'
                              : 'Next',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionPage extends StatelessWidget {
  const _QuestionPage({
    required this.question,
    required this.selectedIndex,
    required this.onSelect,
  });

  final _OnboardingQuestion question;
  final int? selectedIndex;
  final Future<void> Function(int) onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 18),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question.title,
                  style: const TextStyle(
                    fontFamily: 'Alkalami',
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 18),
                ...List.generate(question.options.length, (index) {
                  final isSelected = selectedIndex == index;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => onSelect(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primaryColor.withOpacity(0.08)
                              : AppTheme.backgroundColor,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.primaryColor.withOpacity(0.5)
                                : AppTheme.borderColor.withOpacity(0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                question.options[index],
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeInOut,
                              height: 22,
                              width: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? AppTheme.primaryColor
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.primaryColor
                                      : AppTheme.borderColor,
                                  width: 1.5,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      size: 14,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingQuestion {
  const _OnboardingQuestion({
    required this.id,
    required this.title,
    required this.options,
  });

  final String id;
  final String title;
  final List<String> options;
}

const List<_OnboardingQuestion> _questions = [
  _OnboardingQuestion(
    id: 'money_stretch',
    title: 'Where does your money feel most stretched right now?',
    options: [
      'Everyday essentials',
      'Childcare or schooling',
      'Housing and utilities',
      'Debt payments',
      'Saving for the future',
    ],
  ),
  _OnboardingQuestion(
    id: 'time_available',
    title: 'On a typical day, how much time can you give to money tasks?',
    options: [
      'Just a few minutes',
      'Around 10-15 minutes',
      'About 30 minutes',
      'A full hour when needed',
    ],
  ),
  _OnboardingQuestion(
    id: 'shopping_style',
    title: 'Which best describes how you usually shop?',
    options: [
      'Mostly planned with a list',
      'Mix of planned and spontaneous',
      'Often last-minute',
      'I shop when there is a good deal',
    ],
  ),
  _OnboardingQuestion(
    id: 'who_for',
    title: 'Who are you usually managing money for?',
    options: [
      'Just me',
      'Me and my partner',
      'My family and kids',
      'A wider household or relatives',
    ],
  ),
  _OnboardingQuestion(
    id: 'money_feelings',
    title: 'How do you feel about managing money right now?',
    options: [
      'Calm and in control',
      'A bit unsure but willing',
      'Often overwhelmed',
      'I avoid it when I can',
    ],
  ),
  _OnboardingQuestion(
    id: 'growth_preference',
    title: 'When it comes to growing your money, you prefer…',
    options: [
      'Safe and steady',
      'A balanced mix of growth and safety',
      'Learning more before deciding',
      'Taking chances for bigger gains',
    ],
  ),
];

class _OnboardingDoneScreen extends StatelessWidget {
  const _OnboardingDoneScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Center(
        child: Text(
          'You are ready to begin.',
          style: TextStyle(
            fontFamily: 'Playfair Display',
            fontSize: 26,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }
}
