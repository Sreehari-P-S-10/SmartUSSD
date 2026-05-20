import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/carrier_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Simple registration screen: Name + Phone + Carrier selection.
///
/// No real OTP verification yet.
/// TODO (Firebase): Replace this screen with Firebase Phone Auth when ready.
/// Steps for Firebase upgrade:
///   1. Create a Firebase project at console.firebase.google.com
///   2. Enable "Phone" under Authentication > Sign-in methods
///   3. Download google-services.json → place in android/app/
///   4. Add firebase_core + firebase_auth to pubspec.yaml
///   5. Replace _submitRegistration() with FirebaseAuth.instance.verifyPhoneNumber()
///   6. Add an OTP input screen (OtpVerifyScreen) between this and pin-setup

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String _selectedCarrier = 'airtel';
  bool _isLoading = false;
  int _step = 0; // 0 = name+phone, 1 = carrier selection

  late AnimationController _slideCtrl;
  late Animation<Offset> _slideIn;

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    )..forward();
    _slideIn = Tween<Offset>(begin: const Offset(0.2, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_formKey.currentState!.validate()) {
      setState(() => _step = 1);
      _slideCtrl.forward(from: 0);
    }
  }

  Future<void> _submitRegistration() async {
    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _nameCtrl.text.trim());
    await prefs.setString('user_phone', _phoneCtrl.text.trim());
    await prefs.setString('user_carrier', _selectedCarrier);
    await prefs.setBool('is_registered', true);
    setState(() => _isLoading = false);
    if (mounted) context.go('/pin-setup');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SlideTransition(
            position: _slideIn,
            child: _step == 0
                ? _buildStep0(cs)
                : _buildStep1(cs),
          ),
        ),
      ),
    );
  }

  // ── Step 0: Name + Phone ─────────────────────────────────────────────────

  Widget _buildStep0(ColorScheme cs) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          // Logo
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColorsLight.primary, Color(0xFF3949AB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(Icons.account_balance_wallet_rounded,
                  color: Colors.white, size: 40),
            ),
          ),
          const SizedBox(height: 32),
          Text('Create Account',
              style: AppTextStyles.headlineLgMobile.copyWith(color: cs.onSurface)),
          const SizedBox(height: 8),
          Text(
            'Set up your SmartUSSD profile to get started.',
            style: AppTextStyles.bodyMd.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 36),

          // Name field
          _FieldLabel('Full Name', cs),
          TextFormField(
            controller: _nameCtrl,
            textCapitalization: TextCapitalization.words,
            keyboardType: TextInputType.name,
            decoration: _inputDecoration(
                'e.g. Sreehari P S', Icons.person_outline_rounded, cs),
            validator: (v) => (v == null || v.trim().length < 2)
                ? 'Enter your full name'
                : null,
          ),
          const SizedBox(height: 20),

          // Phone field
          _FieldLabel('Mobile Number', cs),
          TextFormField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: _inputDecoration('10-digit number', Icons.phone_outlined, cs)
                .copyWith(prefixText: '+91  ', counterText: ''),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Enter your phone number';
              if (v.trim().length != 10) return 'Enter a valid 10-digit number';
              return null;
            },
          ),
          const SizedBox(height: 36),

          // Step indicator
          _StepIndicator(current: 0, total: 2, cs: cs),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nextStep,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Next — Choose Your Carrier',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 1: Carrier Selection ─────────────────────────────────────────────

  Widget _buildStep1(ColorScheme cs) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          // Back to step 0
          GestureDetector(
            onTap: () {
              setState(() => _step = 0);
              _slideCtrl.forward(from: 0);
            },
            child: Row(children: [
              Icon(Icons.arrow_back_rounded, color: cs.primary, size: 20),
              const SizedBox(width: 6),
              Text('Back', style: AppTextStyles.labelMd.copyWith(color: cs.primary)),
            ]),
          ),
          const SizedBox(height: 24),
          Text('Select Your SIM Carrier',
              style: AppTextStyles.headlineLgMobile.copyWith(color: cs.onSurface)),
          const SizedBox(height: 8),
          Text(
            'This determines how payments are initiated.\nJio uses 123PAY voice call; others use USSD (*99#).',
            style: AppTextStyles.bodyMd.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 28),

          // Carrier options
          ...supportedCarriers.map((carrier) {
            final isSelected = _selectedCarrier == carrier.key;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _selectedCarrier = carrier.key);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? cs.primaryContainer.withValues(alpha: 0.3)
                        : cs.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? cs.primary : cs.outlineVariant,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(carrier.emoji,
                          style: const TextStyle(fontSize: 28)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(carrier.displayName,
                                style: AppTextStyles.labelMd.copyWith(
                                  color: cs.onSurface,
                                  fontWeight: FontWeight.w700,
                                )),
                            if (carrier.usesIvr)
                              Text(
                                'Uses ${carrier.ivrLabel} (Voice Call)',
                                style: AppTextStyles.labelSm.copyWith(
                                  color: cs.tertiary,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            else
                              Text(
                                'Uses USSD (*99#)',
                                style: AppTextStyles.labelSm.copyWith(
                                    color: cs.onSurfaceVariant),
                              ),
                          ],
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? cs.primary : Colors.transparent,
                          border: Border.all(
                            color: isSelected ? cs.primary : cs.outlineVariant,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white, size: 14)
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          // JIO info banner
          if (_selectedCarrier == 'jio') ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cs.tertiaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.tertiary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: cs.tertiary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'For Jio, payments use NPCI\'s 123PAY IVR.\nYou\'ll call 08045163666 and follow voice instructions.',
                      style: AppTextStyles.labelSm.copyWith(color: cs.tertiary),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 32),
          _StepIndicator(current: 1, total: 2, cs: cs),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _submitRegistration,
              icon: _isLoading
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.arrow_forward_rounded),
              label: Text(
                'Continue — Set Your PIN',
                style: AppTextStyles.labelMd.copyWith(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon, ColorScheme cs) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: cs.onSurfaceVariant),
      filled: true,
      fillColor: cs.surfaceContainerLowest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.error),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  final ColorScheme cs;
  const _FieldLabel(this.label, this.cs);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(label,
            style: AppTextStyles.labelMd
                .copyWith(color: cs.onSurface, fontWeight: FontWeight.w600)),
      );
}

class _StepIndicator extends StatelessWidget {
  final int current;
  final int total;
  final ColorScheme cs;
  const _StepIndicator(
      {required this.current, required this.total, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final active = i == current;
        final done = i < current;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < total - 1 ? 8 : 0),
            height: 4,
            decoration: BoxDecoration(
              color: (active || done) ? cs.primary : cs.outlineVariant,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        );
      }),
    );
  }
}
