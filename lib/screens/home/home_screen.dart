import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../providers/balance_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/quick_action_card.dart';

/// Load user initials from SharedPreferences (set during registration).
Future<String> _getInitial() async {
  final prefs = await SharedPreferences.getInstance();
  final name = prefs.getString('user_name') ?? '';
  return name.isNotEmpty ? name[0].toUpperCase() : 'U';
}

/// Load time-appropriate greeting with user's name.
Future<String> _getGreeting() async {
  final prefs = await SharedPreferences.getInstance();
  final name = prefs.getString('user_name') ?? '';
  final hour = DateTime.now().hour;
  final greet = hour < 12
      ? 'Good Morning'
      : hour < 17
          ? 'Good Afternoon'
          : 'Good Evening';
  return name.isNotEmpty ? '$greet $name' : greet;
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final balanceState = ref.watch(balanceProvider);
    final transactions = ref.watch(transactionProvider);
    final lastTx = transactions.isNotEmpty
        ? (transactions..sort((a, b) => b.timestamp.compareTo(a.timestamp))).first
        : null;

    return Scaffold(
      backgroundColor: cs.surface,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxScrolled) => [
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: cs.surface,
            elevation: 0,
            scrolledUnderElevation: 1,
            shadowColor: cs.outlineVariant,
            titleSpacing: 16,
            title: Row(
              children: [
                // Fix ③: profile avatar tap → go to /profile
                GestureDetector(
                  onTap: () => context.go('/profile'),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: cs.primaryContainer,
                    child: FutureBuilder<String>(
                      future: _getInitial(),
                      builder: (context, snap) => Text(
                        snap.data ?? 'U',
                        style: AppTextStyles.labelMd.copyWith(
                          color: cs.onPrimaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'SmartUSSD',
                  style: AppTextStyles.headlineMd.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
                color: cs.onSurfaceVariant,
              ),
            ],
          ),
        ],
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome — name loaded from SharedPreferences
              Text(
                'Welcome back,',
                style: AppTextStyles.labelMd.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 4),
              FutureBuilder<String>(
                future: _getGreeting(),
                builder: (context, snap) => Text(
                  snap.data ?? 'Good Morning',
                  style: AppTextStyles.headlineLgMobile.copyWith(color: cs.onSurface),
                ),
              ),
              const SizedBox(height: 24),

              // Balance + Last Transaction
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 600;
                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: _BalanceCard(balanceState: balanceState, ref: ref)),
                        const SizedBox(width: 16),
                        Expanded(child: _LastTransactionCard(tx: lastTx, cs: cs)),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      _BalanceCard(balanceState: balanceState, ref: ref),
                      const SizedBox(height: 16),
                      _LastTransactionCard(tx: lastTx, cs: cs),
                    ],
                  );
                },
              ),
              const SizedBox(height: 28),

              // Quick Actions
              Text(
                'QUICK ACTIONS',
                style: AppTextStyles.labelSm.copyWith(
                  color: cs.onSurfaceVariant,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.3,
                children: [
                  // Fix ②: Use gradient-decorated container for dark-mode visibility
                  QuickActionCard(
                    icon: Icons.send_rounded,
                    label: 'Send Money',
                    backgroundColor: const Color(0xFF3949AB),
                    iconColor: Colors.white,
                    textColor: Colors.white,
                    // Fix ⑤: push keeps back-stack so back arrow works
                    onTap: () { HapticFeedback.lightImpact(); context.push('/send'); },
                  ),
                  QuickActionCard(
                    icon: Icons.account_balance_rounded,
                    label: 'Check Balance',
                    backgroundColor: cs.secondaryContainer,
                    iconColor: cs.onSecondaryContainer,
                    textColor: cs.onSecondaryContainer,
                    onTap: () { HapticFeedback.lightImpact(); context.push('/balance'); },
                  ),
                  QuickActionCard(
                    icon: Icons.receipt_long_rounded,
                    label: 'Mini Statement',
                    backgroundColor: cs.tertiaryContainer.withValues(alpha: 0.4),
                    iconColor: cs.tertiary,
                    textColor: cs.tertiary,
                    onTap: () { HapticFeedback.lightImpact(); context.push('/statement'); },
                  ),
                  QuickActionCard(
                    icon: Icons.contacts_rounded,
                    label: 'Saved Contacts',
                    backgroundColor: cs.surfaceContainerHigh,
                    iconColor: cs.primary,
                    textColor: cs.onSurface,
                    onTap: () { HapticFeedback.lightImpact(); context.push('/contacts'); },
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Fix ④: Refer & Earn Banner — commented out (preserved for future use)
              // _ReferBanner(cs: cs),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0,
        onTap: (i) {
          switch (i) {
            case 0: break;
            case 1: context.go('/history'); break;
            case 2: context.go('/contacts'); break;
            case 3: context.go('/profile'); break;
          }
        },
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final BalanceState balanceState;
  final WidgetRef ref;

  const _BalanceCard({required this.balanceState, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColorsLight.primary, Color(0xFF3949AB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColorsLight.primary.withValues(alpha: 0.28),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Balance',
                    style: AppTextStyles.labelMd.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    color: Colors.white.withValues(alpha: 0.4),
                    size: 28,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      balanceState.isVisible
                          ? CurrencyFormatter.format(balanceState.amount)
                          : '₹ ••••••••',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ref.read(balanceProvider.notifier).toggleVisibility();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        balanceState.isVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _Pill('Primary Account'),
                  const SizedBox(width: 8),
                  _Pill('Active'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  const _Pill(this.label);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSm.copyWith(color: Colors.white),
      ),
    );
  }
}

class _LastTransactionCard extends StatelessWidget {
  final dynamic tx;
  final ColorScheme cs;

  const _LastTransactionCard({required this.tx, required this.cs});

  @override
  Widget build(BuildContext context) {
    if (tx == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Center(
          child: Text(
            'No transactions yet',
            style: AppTextStyles.labelMd.copyWith(color: cs.onSurfaceVariant),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Last Transaction',
            style: AppTextStyles.labelMd.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: cs.secondaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.shopping_bag_outlined,
                    color: cs.onSecondaryContainer, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.merchant,
                      style: AppTextStyles.labelMd.copyWith(color: cs.onSurface),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      DateFormatter.formatRelative(tx.timestamp),
                      style: AppTextStyles.labelSm.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            CurrencyFormatter.format(tx.amount),
            style: AppTextStyles.headlineMd.copyWith(color: cs.onSurface),
          ),
          const SizedBox(height: 4),
          Text(
            tx.type == 'failed' ? 'Failed' : 'Success',
            style: AppTextStyles.labelSm.copyWith(
              color: tx.type == 'failed' ? cs.error : cs.tertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReferBanner extends StatelessWidget {
  final ColorScheme cs;
  const _ReferBanner({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cs.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Refer & Earn ₹100',
                  style: AppTextStyles.headlineMd.copyWith(
                    color: cs.onSecondaryContainer,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Invite friends and earn rewards in your bank account.',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: cs.onSecondaryContainer.withValues(alpha: 0.8),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.primary,
              foregroundColor: cs.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Invite'),
          ),
        ],
      ),
    );
  }
}
