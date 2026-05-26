import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';

class PinLoginScreen extends ConsumerStatefulWidget {
  const PinLoginScreen({super.key});

  @override
  ConsumerState<PinLoginScreen> createState() => _PinLoginScreenState();
}

class _PinLoginScreenState extends ConsumerState<PinLoginScreen>
    with SingleTickerProviderStateMixin {
  String _pin = '';
  String? _errorMsg;
  bool _showBiometric = false;
  late AnimationController _shakeController;
  Timer? _lockoutTimer;
  int _lockoutRemaining = 0;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    final notifier = ref.read(authProvider.notifier);
    final available = await notifier.isBiometricAvailable();
    final enabled = await notifier.isBiometricEnabled();
    final shouldShow = available && enabled;
    if (mounted) setState(() => _showBiometric = shouldShow);
    if (shouldShow) _tryBiometric();
  }

  Future<void> _tryBiometric() async {
    final success = await ref.read(authProvider.notifier).loginWithBiometrics();
    if (success && mounted) context.go('/home');
  }

  void _onDigit(String digit) {
    final auth = ref.read(authProvider);
    if (auth.isInLockout) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _errorMsg = null;
      if (_pin.length < 6) _pin += digit;
    });
    if (_pin.length == 6) _verifyPin();
  }

  void _onBackspace() {
    HapticFeedback.lightImpact();
    setState(() {
      _errorMsg = null;
      if (_pin.isNotEmpty) _pin = _pin.substring(0, _pin.length - 1);
    });
  }

  Future<void> _verifyPin() async {
    final success = await ref.read(authProvider.notifier).loginWithPin(_pin);
    if (success) {
      if (mounted) context.go('/home');
    } else {
      HapticFeedback.heavyImpact();
      _shakeController.forward(from: 0);
      final auth = ref.read(authProvider);
      if (auth.isInLockout) {
        _startLockoutTimer();
        setState(() {
          _pin = '';
          _errorMsg = 'Too many attempts. Locked for 30 seconds.';
        });
      } else {
        setState(() {
          _pin = '';
          _errorMsg = 'Incorrect PIN. ${3 - auth.failedAttempts} attempts left.';
        });
      }
    }
  }

  void _startLockoutTimer() {
    _lockoutTimer?.cancel();
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final auth = ref.read(authProvider);
      if (!auth.isInLockout) {
        _lockoutTimer?.cancel();
        if (mounted) setState(() => _lockoutRemaining = 0);
      } else {
        if (mounted) setState(() => _lockoutRemaining = auth.lockoutSecondsRemaining);
      }
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _lockoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final auth = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColorsLight.primary, Color(0xFF3949AB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Welcome Back',
                style: AppTextStyles.headlineLgMobile.copyWith(color: cs.onSurface),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your PIN to continue',
                style: AppTextStyles.bodyMd.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 40),
              // PIN dots
              AnimatedBuilder(
                animation: _shakeController,
                builder: (context, child) {
                  final offset = _shakeController.isAnimating
                      ? ((_shakeController.value * 6) % 1 > 0.5 ? 10.0 : -10.0) *
                          (1 - _shakeController.value)
                      : 0.0;
                  return Transform.translate(
                    offset: Offset(offset, 0),
                    child: child,
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(6, (i) {
                    final filled = i < _pin.length;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: filled ? AppColorsLight.primary : Colors.transparent,
                        border: Border.all(
                          color: filled ? AppColorsLight.primary : cs.outlineVariant,
                          width: 2,
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 16),
              if (_errorMsg != null)
                Text(
                  auth.isInLockout && _lockoutRemaining > 0
                      ? 'Locked for $_lockoutRemaining seconds'
                      : _errorMsg!,
                  style: AppTextStyles.labelMd.copyWith(color: cs.error),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 40),
              // Keypad
              _Keypad(
                onDigit: _onDigit,
                onBackspace: _onBackspace,
                disabled: auth.isInLockout,
              ),
              // Biometric button — only shown when biometrics are enabled in settings
              if (_showBiometric) ...[
                const SizedBox(height: 24),
                TextButton.icon(
                  onPressed: _tryBiometric,
                  icon: const Icon(Icons.fingerprint_rounded, size: 28),
                  label: Text(
                    'Use Biometrics',
                    style: AppTextStyles.labelMd,
                  ),
                  style: TextButton.styleFrom(foregroundColor: cs.primary),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Keypad extends StatelessWidget {
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final bool disabled;

  const _Keypad({
    required this.onDigit,
    required this.onBackspace,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    const keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', 'back'],
    ];

    return Column(
      children: keys.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((key) {
              if (key.isEmpty) return const SizedBox(width: 90);
              if (key == 'back') {
                return _KeyButton(
                  child: const Icon(Icons.backspace_outlined, size: 22),
                  onTap: onBackspace,
                  disabled: disabled,
                );
              }
              return _KeyButton(
                child: Text(key, style: AppTextStyles.headlineMd),
                onTap: () => onDigit(key),
                disabled: disabled,
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}

class _KeyButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final bool disabled;

  const _KeyButton({required this.child, required this.onTap, this.disabled = false});

  @override
  State<_KeyButton> createState() => _KeyButtonState();
}

class _KeyButtonState extends State<_KeyButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTapDown: widget.disabled ? null : (_) => _ctrl.forward(),
      onTapUp: widget.disabled
          ? null
          : (_) {
              _ctrl.reverse();
              widget.onTap();
            },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Opacity(
          opacity: widget.disabled ? 0.4 : 1.0,
          child: Container(
            width: 80,
            height: 72,
            margin: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Center(child: widget.child),
          ),
        ),
      ),
    );
  }
}
