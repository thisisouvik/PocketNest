import 'package:flutter/material.dart';
import 'package:pocketnest/core/theme/app_theme.dart';
import 'package:pocketnest/core/utils/groq_ai_utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SaveTab extends StatefulWidget {
  const SaveTab({super.key, required this.userId});

  final String userId;

  @override
  State<SaveTab> createState() => _SaveTabState();
}

class _SaveTabState extends State<SaveTab> {
  String _selectedFilter = 'All';
  String _weeklyStrategy =
      'Batch cooking once this week could reduce waste and save around \$18.';
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;

  final List<String> _filterOptions = [
    'All',
    'Groceries',
    'Household',
    'Kids',
    'Utilities',
    'Online',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('profiles')
          .select('*')
          .eq('id', widget.userId)
          .maybeSingle();

      setState(() {
        _userProfile = response;
        _isLoading = false;
      });

      // Generate AI-powered weekly strategy
      _generateWeeklyStrategy();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _generateWeeklyStrategy() async {
    try {
      final strategy = await GroqAIUtils.generateWeeklySavingStrategy(
        userProfile: _userProfile ?? {},
      );
      if (mounted) {
        setState(() {
          _weeklyStrategy = strategy;
        });
      }
    } catch (e) {
      // Use default strategy on error
    }
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
              // Header Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Smarter savings',
                    style: TextStyle(
                      fontFamily: 'Alkalami',
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Here are a few ways you could stretch your money this week.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // Local Opportunity Card
              _SavingsCard(
                title: 'Seasonal produce',
                description:
                    'Seasonal produce is 10% cheaper near you this week. Visit the farmer\'s market on weekends for best selection.',
                icon: Icons.location_on_outlined,
                accentColor: const Color(0xFFE8F5E9),
                hasButton: true,
              ),
              const SizedBox(height: 14),

              // Online Shopping Insight
              _SavingsCard(
                title: 'Essentials discount',
                description:
                    'Your usual shopping platform is running a 15% off essentials sale this week. Stock up on household staples.',
                icon: Icons.shopping_bag_outlined,
                accentColor: const Color(0xFFF3E5F5),
                hasButton: true,
              ),
              const SizedBox(height: 14),

              // AI-Suggested Strategy
              _SavingsCard(
                title: 'Weekly strategy',
                description: _weeklyStrategy,
                icon: Icons.lightbulb_outline,
                accentColor: const Color(0xFFFFF8E1),
                hasButton: false,
              ),
              const SizedBox(height: 20),

              // Quick Filters Section
              const Text(
                'Explore by category',
                style: TextStyle(
                  fontFamily: 'Alkalami',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 38,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _filterOptions.length,
                  itemBuilder: (context, index) {
                    final option = _filterOptions[index];
                    final isSelected = option == _selectedFilter;
                    return Padding(
                      padding: EdgeInsets.only(
                        right: index < _filterOptions.length - 1 ? 8 : 0,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedFilter = option;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primaryColor
                                : const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(20),
                            border: isSelected
                                ? null
                                : Border.all(
                                    color: AppTheme.borderColor,
                                    width: 1,
                                  ),
                          ),
                          child: Center(
                            child: Text(
                              option,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Category-Specific Savings (based on selected filter)
              _buildCategoryContent(),
              const SizedBox(height: 24),

              // Premium Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F7F4),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.borderColor, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 18,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Advanced savings tools',
                          style: TextStyle(
                            fontFamily: 'Alkalami',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Real-time deal scanner, multi-platform comparison, and smart timing alerts help you maximize every rupee.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Premium features coming soon!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                      ),
                      child: const Text(
                        'Learn more',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryContent() {
    final categoryCards = {
      'All': [
        _buildSmallCard(
          'Smart shopping',
          'Plan purchases by comparing prices across 3 stores',
        ),
        _buildSmallCard(
          'Waste reduction',
          'Buy only what you\'ll use this week',
        ),
        _buildSmallCard(
          'Bulk buying tips',
          'Save 20% on frequently used items',
        ),
      ],
      'Groceries': [
        _buildSmallCard(
          'Smart shopping',
          'Plan purchases by comparing prices across 3 stores',
        ),
        _buildSmallCard(
          'Waste reduction',
          'Buy only what you\'ll use this week',
        ),
        _buildSmallCard(
          'Bulk buying tips',
          'Save 20% on frequently used items',
        ),
      ],
      'Household': [
        _buildSmallCard(
          'Quality matters',
          'Buy durable items that last longer',
        ),
        _buildSmallCard(
          'DIY solutions',
          'Simple swaps that save money monthly',
        ),
      ],
      'Kids': [
        _buildSmallCard(
          'Buy secondhand',
          'Kids grow fast — secondhand works great',
        ),
        _buildSmallCard(
          'Budget-friendly',
          'Fun activities that cost next to nothing',
        ),
      ],
      'Utilities': [
        _buildSmallCard(
          'Smart usage',
          'Small habits save significantly over time',
        ),
        _buildSmallCard('Provider review', 'Check if you\'re on the best plan'),
      ],
      'Online': [
        _buildSmallCard('Cart tracking', 'Wait for discounts before you buy'),
        _buildSmallCard('Cashback apps', 'Earn on every purchase you make'),
      ],
    };

    final cards = categoryCards[_selectedFilter] ?? categoryCards['All']!;

    return Column(
      children: List.generate(
        cards.length,
        (index) => Padding(
          padding: EdgeInsets.only(bottom: index < cards.length - 1 ? 10 : 0),
          child: cards[index],
        ),
      ),
    );
  }

  Widget _buildSmallCard(String title, String description) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _SavingsCard extends StatelessWidget {
  const _SavingsCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.hasButton,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;
  final bool hasButton;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: AppTheme.primaryColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Alkalami',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
          if (hasButton) ...[
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('More details coming soon!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
              child: const Text(
                'Learn more →',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
