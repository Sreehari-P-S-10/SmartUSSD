import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/app_bar_widget.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  bool _hideBalance = false;
  bool _hideAmounts = false;
  bool _pinForExport = false;
  bool _appLock = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _hideBalance = prefs.getBool('privacy_hide_balance') ?? false;
      _hideAmounts = prefs.getBool('privacy_hide_amounts') ?? false;
      _pinForExport = prefs.getBool('privacy_pin_for_export') ?? false;
      _appLock = prefs.getBool('privacy_app_lock') ?? false;
      _loaded = true;
    });
  }

  Future<void> _setPref(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: const SmartUSSDAppBar(
        title: 'Privacy Settings',
        showBack: true,
      ),
      body: _loaded
          ? SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info banner
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: cs.primary.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lock_outline_rounded,
                            color: cs.primary, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'All privacy settings are stored locally on your device. No data is shared externally.',
                            style: AppTextStyles.labelSm
                                .copyWith(color: cs.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Display Privacy
                  _SectionHeader('Display Privacy', Icons.visibility_outlined, cs),
                  _SettingsCard(cs: cs, children: [
                    SwitchListTile(
                      title: Text(
                        'Hide Balance on Home',
                        style: AppTextStyles.labelMd
                            .copyWith(color: cs.onSurface),
                      ),
                      subtitle: Text(
                        'Balance always shows as ₹ •••••••• on the home screen',
                        style: AppTextStyles.labelSm
                            .copyWith(color: cs.onSurfaceVariant),
                      ),
                      value: _hideBalance,
                      activeTrackColor: cs.primary,
                      onChanged: (v) {
                        setState(() => _hideBalance = v);
                        _setPref('privacy_hide_balance', v);
                      },
                    ),
                    _divider(cs),
                    SwitchListTile(
                      title: Text(
                        'Hide Transaction Amounts',
                        style: AppTextStyles.labelMd
                            .copyWith(color: cs.onSurface),
                      ),
                      subtitle: Text(
                        'Replace amounts in transaction list with ₹ ••••',
                        style: AppTextStyles.labelSm
                            .copyWith(color: cs.onSurfaceVariant),
                      ),
                      value: _hideAmounts,
                      activeTrackColor: cs.primary,
                      onChanged: (v) {
                        setState(() => _hideAmounts = v);
                        _setPref('privacy_hide_amounts', v);
                      },
                    ),
                  ]),
                  const SizedBox(height: 20),

                  // Access Control
                  _SectionHeader(
                      'Access Control', Icons.shield_outlined, cs),
                  _SettingsCard(cs: cs, children: [
                    SwitchListTile(
                      title: Text(
                        'Require PIN for Export',
                        style: AppTextStyles.labelMd
                            .copyWith(color: cs.onSurface),
                      ),
                      subtitle: Text(
                        'Ask for PIN before allowing PDF statement export',
                        style: AppTextStyles.labelSm
                            .copyWith(color: cs.onSurfaceVariant),
                      ),
                      value: _pinForExport,
                      activeTrackColor: cs.primary,
                      onChanged: (v) {
                        setState(() => _pinForExport = v);
                        _setPref('privacy_pin_for_export', v);
                      },
                    ),
                    _divider(cs),
                    SwitchListTile(
                      title: Text(
                        'App Lock on Background',
                        style: AppTextStyles.labelMd
                            .copyWith(color: cs.onSurface),
                      ),
                      subtitle: Text(
                        'Require re-authentication when returning from background',
                        style: AppTextStyles.labelSm
                            .copyWith(color: cs.onSurfaceVariant),
                      ),
                      value: _appLock,
                      activeTrackColor: cs.primary,
                      onChanged: (v) {
                        setState(() => _appLock = v);
                        _setPref('privacy_app_lock', v);
                      },
                    ),
                  ]),
                ],
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final ColorScheme cs;

  const _SectionHeader(this.title, this.icon, this.cs);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: cs.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(
            title,
            style: AppTextStyles.labelMd.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  final ColorScheme cs;

  const _SettingsCard({required this.children, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(children: children),
    );
  }
}

Widget _divider(ColorScheme cs) => Divider(
    height: 1,
    color: cs.outlineVariant.withValues(alpha: 0.5),
    indent: 16,
    endIndent: 16);
