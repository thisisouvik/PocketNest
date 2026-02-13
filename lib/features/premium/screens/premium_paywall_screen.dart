import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pocketnest/core/services/revenuecat_service.dart';
import 'package:pocketnest/core/theme/app_theme.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PremiumPaywallScreen extends StatefulWidget {
  const PremiumPaywallScreen({super.key, this.source});

  final String? source;

  @override
  State<PremiumPaywallScreen> createState() => _PremiumPaywallScreenState();
}

class _PremiumPaywallScreenState extends State<PremiumPaywallScreen> {
  bool _isLoading = true;
  bool _isPurchasing = false;
  String? _errorMessage;
  List<Package> _packages = [];
  Package? _selectedPackage;

  @override
  void initState() {
    super.initState();
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final offerings = await RevenueCatService.getOfferings();
      final current = offerings.current;
      final packages = current?.availablePackages ?? <Package>[];
      final ordered = _orderPackages(packages);

      setState(() {
        _packages = ordered;
        _selectedPackage = ordered.isNotEmpty ? ordered.first : null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Could not load plans. Try again.';
        _isLoading = false;
      });
    }
  }

  List<Package> _orderPackages(List<Package> packages) {
    const order = ['monthly', 'three_month', 'yearly'];
    final ordered = <Package>[];
    for (final id in order) {
      ordered.addAll(
        packages.where((pkg) => pkg.storeProduct.identifier == id),
      );
    }
    for (final pkg in packages) {
      if (!ordered.contains(pkg)) {
        ordered.add(pkg);
      }
    }
    return ordered;
  }

  bool _isBestValue(Package package) {
    return package.storeProduct.identifier == 'three_month';
  }

  String _tagText(Package package) {
    if (package.storeProduct.identifier == 'three_month') {
      return 'Three-month value purchase';
    }
    return '';
  }

  String _planTitle(Package package) {
    switch (package.storeProduct.identifier) {
      case 'monthly':
        return 'Monthly';
      case 'three_month':
        return 'Three Month';
      case 'yearly':
        return 'Yearly';
      default:
        return package.storeProduct.title;
    }
  }

  String _planFrequency(Package package) {
    switch (package.storeProduct.identifier) {
      case 'monthly':
        return 'Billed monthly';
      case 'three_month':
        return 'Billed every 3 months';
      case 'yearly':
        return 'Billed yearly';
      default:
        return 'Cancel anytime';
    }
  }

  String _offerText(Package package) {
    switch (package.storeProduct.identifier) {
      case 'monthly':
        return 'Offer: \$9.99 per month';
      case 'three_month':
        return 'Offer: \$24.99 for 3 months';
      case 'yearly':
        return 'Offer: 10-15% savings vs monthly';
      default:
        return 'Offer available';
    }
  }

  Future<void> _purchaseSelected() async {
    if (_selectedPackage == null) return;

    setState(() {
      _isPurchasing = true;
    });

    try {
      final result = await RevenueCatService.purchasePackage(_selectedPackage!);
      if (!mounted) return;

      final unlocked = result.customerInfo.entitlements.active.containsKey(
        RevenueCatService.premiumEntitlementId,
      );
      if (unlocked) {
        await RevenueCatService.refreshCustomerInfo();
        if (!mounted) return;
        Navigator.of(context).pop(true);
        return;
      }

      setState(() {
        _isPurchasing = false;
      });
    } on PlatformException catch (e) {
      if (!mounted) return;
      setState(() {
        _isPurchasing = false;
      });
      final message = e.code.contains('purchase_cancelled')
          ? 'Purchase cancelled.'
          : 'Purchase failed. Try again.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isPurchasing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Purchase failed. Try again.')),
      );
    }
  }

  Future<void> _restorePurchases() async {
    try {
      final info = await RevenueCatService.restorePurchases();
      if (!mounted) return;
      final unlocked = info.entitlements.active.containsKey(
        RevenueCatService.premiumEntitlementId,
      );
      if (unlocked) {
        await RevenueCatService.refreshCustomerInfo();
        if (!mounted) return;
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No active subscription found.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Restore failed. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Upgrade to PocketNest Premium',
          style: TextStyle(
            fontFamily: 'Alkalami',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Take full control of your financial confidence.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            const _ValueStackCard(
              items: [
                _ValueStackItem(
                  icon: Icons.analytics_outlined,
                  title: 'Advanced Financial Analytics',
                  subtitle:
                      'Deeper insights into your money behavior patterns.',
                ),
                _ValueStackItem(
                  icon: Icons.psychology_outlined,
                  title: 'Confidence Forecast Engine',
                  subtitle: 'Predict financial stability trends.',
                ),
                _ValueStackItem(
                  icon: Icons.assessment_outlined,
                  title: 'Strategic Growth Reports',
                  subtitle: 'Executive-level financial summaries.',
                ),
                _ValueStackItem(
                  icon: Icons.lock_open_outlined,
                  title: 'Unlimited Tracking',
                  subtitle: 'Remove all financial limits.',
                ),
                _ValueStackItem(
                  icon: Icons.support_agent_outlined,
                  title: 'Priority Support',
                  subtitle: 'Priority help when you need it most.',
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (_isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryColor,
                    ),
                  ),
                ),
              )
            else if (_errorMessage != null)
              Expanded(
                child: Center(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: _packages.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final pkg = _packages[index];
                    final product = pkg.storeProduct;
                    return _PlanCard(
                      title: _planTitle(pkg),
                      subtitle: _planFrequency(pkg),
                      note: 'Cancel anytime',
                      offer: _offerText(pkg),
                      price: product.priceString,
                      isSelected: pkg == _selectedPackage,
                      isBestValue: _isBestValue(pkg),
                      tagText: _tagText(pkg),
                      accent: AppTheme.primaryColor,
                      gold: AppTheme.accentColor,
                      textPrimary: AppTheme.textPrimary,
                      textSecondary: AppTheme.textSecondary,
                      background: AppTheme.cardBackground,
                      onTap: () {
                        setState(() {
                          _selectedPackage = pkg;
                        });
                      },
                    );
                  },
                ),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isPurchasing ? null : _purchaseSelected,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _isPurchasing ? 'Processing...' : 'Unlock Premium Access',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _restorePurchases,
              child: const Text(
                'Restore Purchase',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 6),
            const _TrustFooter(textColor: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.subtitle,
    required this.note,
    required this.offer,
    required this.price,
    required this.isSelected,
    required this.isBestValue,
    required this.tagText,
    required this.accent,
    required this.gold,
    required this.textPrimary,
    required this.textSecondary,
    required this.background,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String note;
  final String offer;
  final String price;
  final bool isSelected;
  final bool isBestValue;
  final String tagText;
  final Color accent;
  final Color gold;
  final Color textPrimary;
  final Color textSecondary;
  final Color background;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? accent : Colors.white12,
            width: isSelected ? 1.4 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: accent.withOpacity(0.22),
                blurRadius: 18,
                offset: const Offset(0, 6),
              )
            else
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                      if (isBestValue && tagText.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: gold.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: gold.withOpacity(0.6)),
                          ),
                          child: Text(
                            tagText,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: gold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    offer,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    note,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              price,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ValueStackItem {
  const _ValueStackItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;
}

class _ValueStackCard extends StatelessWidget {
  const _ValueStackCard({required this.items});

  final List<_ValueStackItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        children: items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(item.icon, size: 18, color: AppTheme.primaryColor),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.subtitle,
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
              ),
            )
            .toList(),
      ),
    );
  }
}

class _TrustFooter extends StatelessWidget {
  const _TrustFooter({required this.textColor});

  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Text(
      'Secure payments • Cancel anytime • Managed by App Store / Play Store',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: 10,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
    );
  }
}
