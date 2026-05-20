import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';

class PinSetupScreen extends ConsumerStatefulWidget {
  const PinSetupScreen({super.key});

  @override
  ConsumerState<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends ConsumerState<PinSetupScreen>
    with SingleTickerProviderStateMixin {
  String _pin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  String? _errorMsg;
  late AnimationController _shakeController;
  late Animation<double> _shake;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shake = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onDigit(String digit) {
    HapticFeedback.mediumImpact();
    setState(() {
      _errorMsg = null;
      if (_isConfirming) {
        if (_confirmPin.length < 6) _confirmPin += digit;
      } else {
        if (_pin.length < 6) _pin += digit;
      }
    });
    if (!_isConfirming && _pin.length == 6) {
      Future.delayed(const Duration(milliseconds: 150), () {
        setState(() => _isConfirming = true);
      });
    }
    if (_isConfirming && _confirmPin.length == 6) {
      _validatePin();
    }
  }

  void _onBackspace() {
    HapticFeedback.lightImpact();
    setState(() {
      _errorMsg = null;
      if (_isConfirming && _confirmPin.isNotEmpty) {
        _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
      } else if (!_isConfirming && _pin.isNotEmpty) {
        _pin = _pin.substring(0, _pin.length - 1);
      }
    });
  }

  Future<void> _validatePin() async {
    if (_pin == _confirmPin) {
      await ref.read(authProvider.notifier).setupPin(_pin);
      if (mounted) context.go('/home');
    } else {
      HapticFeedback.heavyImpact();
      _shakeController.forward(from: 0);
      setState(() {
        _errorMsg = 'PINs do not match. Try again.';
        _confirmPin = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final currentPin = _isConfirming ? _confirmPin : _pin;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Header
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColorsLight.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  color: AppColorsLight.primary,
                  size: 36,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _isConfirming ? 'Confirm Your PIN' : 'Create Your PIN',
                style: AppTextStyles.headlineLgMobile.copyWith(color: cs.onSurface),
              ),
              const SizedBox(height: 8),
              Text(
                _isConfirming
                    ? 'Re-enter the 6-digit PIN you just created'
                    : 'Set a 6-digit PIN to secure your account',
                style: AppTextStyles.bodyMd.copyWith(color: cs.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              // PIN dots
              AnimatedBuilder(
                animation: _shake,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_shakeController.isAnimating ? _shake.value * ((_shake.value ~/ 1) % 2 == 0 ? 1 : -1) : 0, 0),
                    child: child,
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(6, (i) {
                    final filled = i < currentPin.length;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: filled ? AppColorsLight.primary : Colors.transparent,
                        border: Border.all(
                          color: filled
                              ? AppColorsLight.primary
                              : cs.outlineVariant,
                          width: 2,
                        ),
                      ),
                    );
                  }),
                ),
              ),
              if (_errorMsg != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMsg!,
                  style: AppTextStyles.labelMd.copyWith(color: cs.error),
                ),
              ],
              const SizedBox(height: 48),
              // Keypad
              _Keypad(
                onDigit: _onDigit,
                onBackspace: _onBackspace,
              ),
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

  const _Keypad({required this.onDigit, required this.onBackspace});

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
                );
              }
              return _KeyButton(
                child: Text(
                  key,
                  style: AppTextStyles.headlineMd,
                ),
                onTap: () => onDigit(key),
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

  const _KeyButton({required this.child, required this.onTap});

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
    _scale = Tween<double>(begin: 1.0, end: 0.88).animate(
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
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
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
    );
  }
}


