import 'package:flutter/material.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/currency_formatter.dart';
import '../core/utils/date_formatter.dart';
import '../data/models/transaction_model.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
  });

  IconData _iconForKey(String? key) {
    switch (key) {
      case 'bolt': return Icons.bolt_rounded;
      case 'work': return Icons.work_rounded;
      case 'movie': return Icons.movie_rounded;
      case 'person': return Icons.person_rounded;
      case 'atm': return Icons.atm_rounded;
      case 'shopping_bag': return Icons.shopping_bag_rounded;
      default: return Icons.receipt_long_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isReceived = transaction.isReceived;
    final isFailed = transaction.isFailed;

    final amountColor = isReceived
        ? cs.tertiary
        : isFailed
            ? cs.error
            : cs.error;

    final iconBg = isReceived
        ? cs.tertiaryContainer.withValues(alpha: 0.3)
        : isFailed
            ? cs.errorContainer.withValues(alpha: 0.3)
            : cs.errorContainer.withValues(alpha: 0.3);

    final iconColor = isReceived
        ? cs.tertiary
        : isFailed
            ? cs.error
            : cs.error;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_iconForKey(transaction.iconKey), color: iconColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.merchant,
                    style: AppTextStyles.labelMd.copyWith(color: cs.onSurface),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormatter.formatTime(transaction.timestamp),
                    style: AppTextStyles.labelSm.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isReceived ? '+' : '-'}${CurrencyFormatter.format(transaction.amount)}',
                  style: AppTextStyles.labelMd.copyWith(
                    color: amountColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                _StatusChip(type: transaction.type),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String type;
  const _StatusChip({required this.type});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Color bg;
    Color text;
    String label;

    switch (type) {
      case 'received':
        bg = cs.tertiaryContainer.withValues(alpha: 0.3);
        text = cs.tertiary;
        label = 'SUCCESS';
        break;
      case 'failed':
        bg = cs.errorContainer.withValues(alpha: 0.3);
        text = cs.error;
        label = 'FAILED';
        break;
      default:
        bg = cs.errorContainer.withValues(alpha: 0.2);
        text = cs.error;
        label = 'SENT';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSm.copyWith(color: text, fontSize: 10),
      ),
    );
  }
}
