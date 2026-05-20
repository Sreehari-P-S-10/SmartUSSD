import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../providers/transaction_provider.dart';
import '../../services/pdf_export_service.dart';
import '../../widgets/app_bar_widget.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/transaction_tile.dart';

class MiniStatementScreen extends ConsumerWidget {
  const MiniStatementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final allTx = ref.watch(transactionProvider);
    final recent = allTx.take(10).toList();

    final totalReceived = recent
        .where((t) => t.isReceived)
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalSent = recent
        .where((t) => t.isSent)
        .fold(0.0, (sum, t) => sum + t.amount);

    // Group by date
    final Map<String, List<dynamic>> grouped = {};
    for (final tx in recent) {
      final dateKey = DateFormatter.formatDate(tx.timestamp);
      grouped[dateKey] = [...(grouped[dateKey] ?? []), tx];
    }

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: SmartUSSDAppBar(title: 'Mini Statement', userInitials: 'S'),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0,
        onTap: (i) {
          switch (i) {
            case 0: context.go('/home'); break;
            case 1: context.go('/history'); break;
            case 2: context.go('/contacts'); break;
            case 3: context.go('/profile'); break;
          }
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Grid
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.trending_up_rounded,
                    iconColor: cs.tertiary,
                    iconBg: cs.tertiaryContainer.withValues(alpha: 0.3),
                    label: 'Income',
                    value: CurrencyFormatter.format(totalReceived),
                    badge: '+12% vs last month',
                    badgeColor: cs.tertiary,
                    badgeBg: cs.tertiaryContainer.withValues(alpha: 0.2),
                    cs: cs,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.trending_down_rounded,
                    iconColor: cs.error,
                    iconBg: cs.errorContainer.withValues(alpha: 0.3),
                    label: 'Total Spent',
                    value: CurrencyFormatter.format(totalSent),
                    badge: '${recent.where((t) => t.isSent).length} transactions',
                    badgeColor: cs.onSurfaceVariant,
                    badgeBg: cs.surfaceContainerHigh,
                    cs: cs,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Fix ③: Real PDF export
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  try {
                    final prefs = await SharedPreferences.getInstance();
                    final name = prefs.getString('user_name') ?? 'Account Holder';
                    await PdfExportService.exportTransactions(
                      recent,
                      userName: name,
                    );
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Export failed: $e')),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.download_rounded),
                label: const Text('Export as PDF'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: cs.primary,
                  side: BorderSide(color: cs.primary.withValues(alpha: 0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Transactions grouped by date
            ...grouped.entries.map((entry) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    entry.key.toUpperCase(),
                    style: AppTextStyles.labelSm.copyWith(
                      color: cs.outline,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: Column(
                    children: entry.value.asMap().entries.map((e) {
                      final isLast = e.key == entry.value.length - 1;
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: TransactionTile(transaction: e.value),
                          ),
                          if (!isLast)
                            Divider(
                              height: 1,
                              color: cs.outlineVariant.withValues(alpha: 0.3),
                              indent: 12,
                              endIndent: 12,
                            ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            )),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor, iconBg, badgeColor, badgeBg;
  final String label, value, badge;
  final ColorScheme cs;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.value,
    required this.badge,
    required this.badgeColor,
    required this.badgeBg,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 10),
          Text(label, style: AppTextStyles.labelSm.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text(value,
              style: AppTextStyles.headlineMd.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w800,
              )),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(9999),
            ),
            child: Text(badge,
                style: AppTextStyles.labelSm.copyWith(color: badgeColor, fontSize: 10)),
          ),
        ],
      ),
    );
  }
}
