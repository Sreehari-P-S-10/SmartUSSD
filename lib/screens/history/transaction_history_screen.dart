import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/date_formatter.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/app_bar_widget.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/transaction_tile.dart';

class TransactionHistoryScreen extends ConsumerStatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  ConsumerState<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState
    extends ConsumerState<TransactionHistoryScreen> {
  String _searchQuery = '';
  String _activeFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final allTx = ref.watch(transactionProvider);

    final filtered = allTx.where((tx) {
      final matchesFilter = _activeFilter == 'all' || tx.type == _activeFilter;
      final matchesSearch = _searchQuery.isEmpty ||
          tx.merchant.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList();

    // Group by date
    final Map<String, List<dynamic>> grouped = {};
    for (final tx in filtered) {
      final key = DateFormatter.formatDate(tx.timestamp);
      grouped[key] = [...(grouped[key] ?? []), tx];
    }

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: SmartUSSDAppBar(title: 'Transaction History', showBack: false, userInitials: 'S'),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTap: (i) {
          switch (i) {
            case 0: context.go('/home'); break;
            case 1: break;
            case 2: context.go('/contacts'); break;
            case 3: context.go('/profile'); break;
          }
        },
      ),
      body: Column(
        children: [
          // Search + Filter (sticky)
          Container(
            color: cs.surface,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Column(
              children: [
                // Search
                TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Search transactions...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: cs.surfaceContainerLowest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: cs.outlineVariant),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: cs.outlineVariant),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: cs.primary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
                const SizedBox(height: 12),
                // Filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', 'all', _activeFilter, cs,
                          () => setState(() => _activeFilter = 'all')),
                      const SizedBox(width: 8),
                      _buildFilterChip('Sent', 'sent', _activeFilter, cs,
                          () => setState(() => _activeFilter = 'sent')),
                      const SizedBox(width: 8),
                      _buildFilterChip('Received', 'received', _activeFilter, cs,
                          () => setState(() => _activeFilter = 'received')),
                      const SizedBox(width: 8),
                      _buildFilterChip('Failed', 'failed', _activeFilter, cs,
                          () => setState(() => _activeFilter = 'failed')),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Transaction list
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.receipt_long_outlined,
                            size: 64, color: cs.outlineVariant),
                        const SizedBox(height: 16),
                        Text('No transactions found',
                            style: AppTextStyles.bodyMd.copyWith(
                              color: cs.onSurfaceVariant,
                            )),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    children: grouped.entries.map((entry) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
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
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

Widget _buildFilterChip(
    String label, String value, String active, ColorScheme cs, VoidCallback onTap) {
  final isActive = active == value;
  return GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? cs.primary : cs.surfaceContainer,
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(
          color: isActive ? cs.primary : cs.outlineVariant,
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelMd.copyWith(
          color: isActive ? cs.onPrimary : cs.onSurfaceVariant,
          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    ),
  );
}
