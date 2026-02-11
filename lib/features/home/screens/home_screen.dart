import 'package:flutter/material.dart';
import 'package:pocketnest/core/theme/app_theme.dart';
import 'package:pocketnest/core/utils/groq_ai_utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.userId});

  final String userId;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          transitionBuilder: (child, animation) {
            final offset = Tween<Offset>(
              begin: const Offset(0.04, 0),
              end: Offset.zero,
            ).animate(animation);
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(position: offset, child: child),
            );
          },
          child: _buildTab(context, _currentIndex),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textSecondary,
        selectedLabelStyle: const TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.savings_outlined),
            label: 'Save',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.trending_up), label: 'Grow'),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups_outlined),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Me',
          ),
        ],
      ),
    );
  }

  Widget _buildTab(BuildContext context, int index) {
    switch (index) {
      case 0:
        return _HomeTab(key: ValueKey('home_tab'), userId: widget.userId);
      case 1:
        return const _PlaceholderTab(
          key: ValueKey('save_tab'),
          label: 'Save ideas are coming here.',
        );
      case 2:
        return const _PlaceholderTab(
          key: ValueKey('grow_tab'),
          label: 'Grow tools are coming here.',
        );
      case 3:
        return const _PlaceholderTab(
          key: ValueKey('community_tab'),
          label: 'Community space is coming here.',
        );
      default:
        return const _PlaceholderTab(
          key: ValueKey('me_tab'),
          label: 'Your profile will appear here.',
        );
    }
  }
}

class _HomeTab extends StatefulWidget {
  const _HomeTab({super.key, required this.userId});

  final String userId;

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  String _userName = 'Friend';
  String _dailyTip = 'You\'re doing amazing! 💚';
  String _cardTitle = 'Today\'s focus';
  String _cardDescription = 'Let us make one gentle plan.';
  bool _skippedOnboarding = false;
  Map<String, dynamic>? _onboardingData;
  List<Map<String, String>> _helpfulIdeas = [];
  double _progressValue = 0.0;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    await Future.wait([_loadUserData(), _loadOnboardingData()]);

    // After loading data, generate AI recommendations
    await _generateAIContent();
  }

  Future<void> _loadUserData() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('profiles')
          .select('full_name, email')
          .eq('id', widget.userId)
          .maybeSingle();

      final authUser = supabase.auth.currentUser;
      final authName =
          (authUser?.userMetadata?['full_name'] ??
                  authUser?.userMetadata?['name'] ??
                  authUser?.userMetadata?['fullName'] ??
                  '')
              .toString()
              .trim();

      final profileName = response?['full_name']?.toString().trim() ?? '';
      final profileEmail = response?['email']?.toString().trim() ?? '';

      final resolvedName = profileName.isNotEmpty
          ? profileName
          : (authName.isNotEmpty
                ? authName
                : (profileEmail.isNotEmpty
                      ? profileEmail
                      : (authUser?.email?.split('@').first ?? 'Friend')));

      if (response != null && profileName.isEmpty && authName.isNotEmpty) {
        await supabase
            .from('profiles')
            .update({'full_name': authName})
            .eq('id', widget.userId);
      }

      setState(() {
        _userName = resolvedName;
      });
    } catch (e) {
      // Keep default 'Friend'
    }
  }

  Future<void> _loadOnboardingData() async {
    try {
      final supabase = Supabase.instance.client;

      // Check if user has onboarding responses
      final response = await supabase
          .from('onboarding_responses')
          .select('responses')
          .eq('user_id', widget.userId)
          .maybeSingle();

      if (response != null && response['responses'] != null) {
        // User completed onboarding
        setState(() {
          _onboardingData = Map<String, dynamic>.from(response['responses']);
          _skippedOnboarding = false;
        });
      } else {
        // User either skipped or never saw onboarding
        setState(() {
          _skippedOnboarding = true;
          _onboardingData = null;
        });
      }
    } catch (e) {
      setState(() {
        _skippedOnboarding = true;
      });
    }
  }

  Future<void> _generateAIContent() async {
    try {
      // Generate tip
      final tip = await GroqAIUtils.generateDailyTip(
        userName: _userName,
        onboardingData: _onboardingData,
        skippedOnboarding: _skippedOnboarding,
      );

      // Generate card title and description
      final title = await GroqAIUtils.generateCardTitle(
        onboardingData: _onboardingData,
        skippedOnboarding: _skippedOnboarding,
      );

      final description = await GroqAIUtils.generateCardDescription(
        onboardingData: _onboardingData,
        skippedOnboarding: _skippedOnboarding,
      );

      // Generate 2-3 helpful ideas based on onboarding
      final ideas = _generateHelpfulIdeas();

      // Calculate progress (simulated)
      final progress = _calculateProgress();

      setState(() {
        _dailyTip = tip;
        _cardTitle = title;
        _cardDescription = description;
        _helpfulIdeas = ideas;
        _progressValue = progress;
      });
    } catch (e) {
      // Error handled silently, display defaults
    }
  }

  List<Map<String, String>> _generateHelpfulIdeas() {
    final ideas = <Map<String, String>>[];

    if (_onboardingData != null) {
      // Based on groceries/money stretch concern
      if (_onboardingData!['money_stretch']?['value'] == 'stretch') {
        ideas.add({
          'title': 'Grocery Hack',
          'body': 'List staples by meal. Cuts impulse spending.',
        });
      }

      // Based on time available
      if (_onboardingData!['time_available']?['value'] == 'limited') {
        ideas.add({
          'title': '5-Min Check-in',
          'body': 'Quick spend review before bed.',
        });
      }

      // Based on who they're saving for
      if (_onboardingData!['who_for'] != null) {
        late String forWho;
        try {
          forWho = _onboardingData!['who_for']?['value'] ?? 'family';
        } catch (_) {
          forWho = 'family';
        }
        ideas.add({
          'title': 'Gentle Goal',
          'body': 'One small step toward your $forWho goal today.',
        });
      }

      // If less than 3 ideas, add generic fallbacks
      if (ideas.isEmpty) {
        ideas.add({
          'title': 'Daily Check-in',
          'body': 'Notice one money moment today.',
        });
      }
      if (ideas.length < 2) {
        ideas.add({
          'title': 'Comfort Zone',
          'body': 'Learn at your pace. No rush.',
        });
      }
      if (ideas.length < 3) {
        ideas.add({
          'title': 'Small Win',
          'body': 'One good choice is enough.',
        });
      }
    } else {
      // Generic ideas for skip users
      ideas.add({
        'title': 'Grocery Smart',
        'body': 'Plan meals → saves money & time.',
      });
      ideas.add({
        'title': 'Progress Track',
        'body': 'One small money choice today.',
      });
      ideas.add({
        'title': 'Comfort Zone',
        'body': 'Learn at your pace. No rush.',
      });
    }

    return ideas.take(3).toList();
  }

  double _calculateProgress() {
    // Simulated progress calculation
    // In real app: fetch from DB
    return 0.43; // ~3 of 7 tasks
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Good Morning, $_userName!',
            style: const TextStyle(
              fontFamily: 'Alkalami',
              fontSize: 26,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _dailyTip,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 22),
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _cardTitle,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _cardDescription,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _SectionCard(
            accent: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Small win for today',
                  style: TextStyle(
                    fontFamily: 'Alkalami',
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _cardDescription,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.savings_outlined,
                      size: 18,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Small, consistent steps build confidence',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Start',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'A few gentle ideas',
                  style: TextStyle(
                    fontFamily: 'Alkalami',
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  'Updated today',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 130,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _helpfulIdeas.length,
              itemBuilder: (context, index) {
                final idea = _helpfulIdeas[index];
                return Padding(
                  padding: EdgeInsets.only(
                    right: index < _helpfulIdeas.length - 1 ? 12 : 0,
                  ),
                  child: _HelpfulIdeaCard(
                    title: idea['title']!,
                    body: idea['body']!,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your gentle progress',
                  style: TextStyle(
                    fontFamily: 'Alkalami',
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${(_progressValue * 100).toStringAsFixed(0)}% of your weekly check-ins done',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _progressValue,
                    minHeight: 6,
                    backgroundColor: AppTheme.borderColor.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      'View details →',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
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

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child, this.accent = false});

  final Widget child;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: accent ? const Color(0xFFF4EFEA) : AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _HelpfulIdeaCard extends StatelessWidget {
  const _HelpfulIdeaCard({required this.title, required this.body, Key? key})
    : super(key: key);

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              body,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ignore: unused_element
class _MiniCard extends StatelessWidget {
  const _MiniCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
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
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }
}
