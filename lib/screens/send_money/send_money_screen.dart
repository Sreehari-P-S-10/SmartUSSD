import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/contact_model.dart';
import '../../data/models/transaction_model.dart';
import '../../providers/contact_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../services/ussd_service.dart';
import '../../widgets/app_bar_widget.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/contact_avatar.dart';

class SendMoneyScreen extends ConsumerStatefulWidget {
  const SendMoneyScreen({super.key});

  @override
  ConsumerState<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends ConsumerState<SendMoneyScreen> {
  ContactModel? _selectedContact;
  final TextEditingController _amountCtrl = TextEditingController();
  final TextEditingController _noteCtrl = TextEditingController();
  bool _isLaunching = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendMoney() async {
    if (_selectedContact == null) {
      _showSnack('Please select a recipient');
      return;
    }
    final amount = double.tryParse(_amountCtrl.text);
    if (amount == null || amount <= 0) {
      _showSnack('Please enter a valid amount');
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _isLaunching = true);

    try {
      final ussdService = UssdService();
      final code = ussdService.buildSendMoneyCode(
        _selectedContact!.phone,
        amount.toStringAsFixed(0),
      );
      await ussdService.launchUSSD(code);
    } catch (_) {}

    setState(() => _isLaunching = false);
    if (mounted) _showResultSheet(amount);
  }

  void _showResultSheet(double amount) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Was the transaction successful?',
                style: AppTextStyles.headlineMd),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _logTransaction(amount, 'failed');
                    },
                    icon: const Icon(Icons.close_rounded),
                    label: const Text('Failed'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                      side: BorderSide(
                          color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _logTransaction(amount, 'sent');
                    },
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Success'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _logTransaction(double amount, String type) async {
    final tx = TransactionModel(
      merchant: _selectedContact!.name,
      amount: amount,
      type: type,
      timestamp: DateTime.now(),
      ussdCode: UssdService().buildSendMoneyCode(
        _selectedContact!.phone,
        amount.toStringAsFixed(0),
      ),
      iconKey: 'person',
    );
    await ref.read(transactionProvider.notifier).add(tx);
    if (mounted) {
      _showSnack(type == 'sent' ? 'Transaction logged as success!' : 'Transaction logged as failed');
      context.go('/home');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final contacts = ref.watch(contactProvider);
    final favorites = contacts.where((c) => c.isFavorite).toList();

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: SmartUSSDAppBar(
        title: 'Send Money',
        userInitials: 'S',
      ),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Favorite Contacts
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Favorite Contacts',
                    style: AppTextStyles.headlineMd.copyWith(color: cs.onSurface)),
                TextButton(
                  onPressed: () => context.go('/contacts'),
                  child: Text('View All',
                      style: AppTextStyles.labelMd.copyWith(color: cs.primary)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  // Add New
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () => context.go('/contacts'),
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: cs.outline,
                              width: 1.5,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Icon(Icons.add_rounded, color: cs.primary),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text('Add New',
                          style: AppTextStyles.labelSm.copyWith(
                            color: cs.onSurfaceVariant,
                          )),
                    ],
                  ),
                  const SizedBox(width: 16),
                  ...favorites.map((c) => Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Column(
                      children: [
                        ContactAvatar(
                          contact: c,
                          size: 60,
                          showBorder: true,
                          isSelected: _selectedContact?.id == c.id,
                          onTap: () => setState(() => _selectedContact = c),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          c.name.split(' ').first,
                          style: AppTextStyles.labelSm.copyWith(
                            color: _selectedContact?.id == c.id
                                ? cs.primary
                                : cs.onSurfaceVariant,
                            fontWeight: _selectedContact?.id == c.id
                                ? FontWeight.w700
                                : FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Form Card
            Container(
              decoration: BoxDecoration(
                color: cs.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cs.outlineVariant),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Selected recipient
                  if (_selectedContact != null) ...[
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: cs.primaryContainer,
                          child: Text(
                            _selectedContact!.initials,
                            style: AppTextStyles.labelMd.copyWith(
                              color: cs.onPrimaryContainer,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Sending to',
                                style: AppTextStyles.labelSm
                                    .copyWith(color: cs.onSurfaceVariant)),
                            Text(
                              _selectedContact!.name,
                              style: AppTextStyles.labelMd.copyWith(
                                color: cs.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => setState(() => _selectedContact = null),
                          child: Text('Change',
                              style: AppTextStyles.labelMd.copyWith(color: cs.primary)),
                        ),
                      ],
                    ),
                    const Divider(height: 28),
                  ],

                  // Amount
                  Text('Enter Amount',
                      style: AppTextStyles.labelMd.copyWith(color: cs.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: cs.outlineVariant),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Text('₹ ',
                            style: AppTextStyles.headlineMd.copyWith(
                              color: cs.primary,
                              fontWeight: FontWeight.w800,
                            )),
                        Expanded(
                          child: TextField(
                            controller: _amountCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: AppTextStyles.headlineMd.copyWith(
                              color: cs.primary,
                              fontWeight: FontWeight.w800,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: '0',
                              hintStyle: AppTextStyles.headlineMd.copyWith(
                                color: cs.onSurfaceVariant.withValues(alpha: 0.4),
                              ),
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Quick amounts
                  Row(
                    children: ['+₹500', '+₹1000', '+₹2000'].map((a) {
                      final val = a.replaceAll(RegExp(r'[^0-9]'), '');
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: OutlinedButton(
                            onPressed: () {
                              final current = double.tryParse(_amountCtrl.text) ?? 0;
                              _amountCtrl.text = (current + double.parse(val)).toStringAsFixed(0);
                              setState(() {});
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: cs.primary,
                              side: BorderSide(color: cs.outlineVariant),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(a, style: AppTextStyles.labelSm),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Security info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.tertiaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.shield_outlined, color: cs.tertiary, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Secure USSD Transfer',
                            style: AppTextStyles.labelMd.copyWith(color: cs.tertiary)),
                        Text(
                          'This transaction will be initiated via a secure offline USSD protocol (*99#). No internet connection is required.',
                          style: AppTextStyles.labelSm.copyWith(
                            color: cs.tertiary.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // CTA
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLaunching ? null : _sendMoney,
                icon: _isLaunching
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.lock_rounded, size: 20),
                label: Text(
                  _amountCtrl.text.isNotEmpty && double.tryParse(_amountCtrl.text) != null
                      ? 'Confirm & Pay ${CurrencyFormatter.format(double.parse(_amountCtrl.text))}'
                      : 'Confirm & Pay',
                  style: AppTextStyles.labelMd.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
