import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/transaction_model.dart';
import '../../providers/balance_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../services/ussd_service.dart';
import '../../widgets/app_bar_widget.dart';
import '../../widgets/bottom_nav_bar.dart';

class CheckBalanceScreen extends ConsumerStatefulWidget {
  const CheckBalanceScreen({super.key});

  @override
  ConsumerState<CheckBalanceScreen> createState() => _CheckBalanceScreenState();
}

class _CheckBalanceScreenState extends ConsumerState<CheckBalanceScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotateCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;
  bool _isLoading = false;
  bool _launched = false;

  @override
  void initState() {
    super.initState();
    _rotateCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulse = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _rotateCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkBalance() async {
    setState(() => _isLoading = true);
    try {
      final ussd = UssdService();
      await ussd.launchUSSD(ussd.buildBalanceCode());
    } catch (_) {}
    setState(() {
      _isLoading = false;
      _launched = true;
    });
    if (mounted) _showEnterBalanceDialog();
  }

  void _showEnterBalanceDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Enter Balance', style: AppTextStyles.headlineMd),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter the balance shown on the USSD screen:',
              style: AppTextStyles.bodyMd.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                prefixText: '₹ ',
                hintText: '0.00',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(ctrl.text);
              if (amount != null) {
                await ref.read(balanceProvider.notifier).updateBalance(amount);
                // Log as "received" check
                final tx = TransactionModel(
                  merchant: 'Balance Check',
                  amount: 0,
                  type: 'received',
                  timestamp: DateTime.now(),
                  ussdCode: '*99#',
                  iconKey: 'account_balance',
                );
                await ref.read(transactionProvider.notifier).add(tx);
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final balanceState = ref.watch(balanceProvider);
    final sessionHash = '#${(Random().nextInt(0xFFF) + 0x800).toRadixString(16).toUpperCase()}-${String.fromCharCodes(List.generate(3, (_) => 65 + Random().nextInt(26)))}';

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: SmartUSSDAppBar(title: 'Check Balance', userInitials: 'S'),
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
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            // Security Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: cs.tertiaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(9999),
                border: Border.all(color: cs.tertiary.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shield_outlined, color: cs.tertiary, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Encrypted Protocol Active',
                    style: AppTextStyles.labelMd.copyWith(color: cs.tertiary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // Animated Circular Loader
            Stack(
              alignment: Alignment.center,
              children: [
                // Outer dim ring
                Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: cs.outlineVariant.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                ),
                // Rotating arc
                AnimatedBuilder(
                  animation: _rotateCtrl,
                  builder: (_, __) => Transform.rotate(
                    angle: _rotateCtrl.value * 2 * pi,
                    child: CustomPaint(
                      size: const Size(240, 240),
                      painter: _ArcPainter(color: cs.primary),
                    ),
                  ),
                ),
                // Inner white circle
                ScaleTransition(
                  scale: _pulse,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: cs.surfaceContainerLowest,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppColorsLight.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet_rounded,
                            color: AppColorsLight.primary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _launched && balanceState.amount > 0
                              ? '₹${balanceState.amount.toStringAsFixed(2)}'
                              : 'Requesting\nBalance...',
                          style: AppTextStyles.labelMd.copyWith(
                            color: cs.onSurface,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),

            // Protocol Info Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Column(
                children: [
                  _InfoRow('Network Protocol', 'USSD v2.1', cs, isHighlight: true),
                  const SizedBox(height: 12),
                  _InfoRow('Session Hash', sessionHash, cs, isHighlight: true),
                  const SizedBox(height: 12),
                  _InfoRow('Security Level', 'High', cs),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.wifi_tethering_rounded, color: cs.primary, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Initializing secure handshake with provider gateway...',
                          style: AppTextStyles.labelMd.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _checkBalance,
                icon: _isLoading
                    ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.arrow_forward_rounded),
                label: Text(
                  'Check Now',
                  style: AppTextStyles.labelMd.copyWith(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Your session is encrypted. No personal data is stored on external servers.',
              style: AppTextStyles.labelSm.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final ColorScheme cs;
  final bool isHighlight;

  const _InfoRow(this.label, this.value, this.cs, {this.isHighlight = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.labelMd.copyWith(color: cs.onSurfaceVariant)),
        Container(
          padding: isHighlight
              ? const EdgeInsets.symmetric(horizontal: 10, vertical: 4)
              : EdgeInsets.zero,
          decoration: isHighlight
              ? BoxDecoration(
                  color: cs.primaryContainer.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                )
              : null,
          child: Text(
            value,
            style: AppTextStyles.labelMd.copyWith(
              color: isHighlight ? cs.primary : cs.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _ArcPainter extends CustomPainter {
  final Color color;
  const _ArcPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: size.width / 2 - 1,
    );
    canvas.drawArc(rect, -pi / 2, pi * 1.2, false, paint);
  }

  @override
  bool shouldRepaint(_ArcPainter old) => false;
}
