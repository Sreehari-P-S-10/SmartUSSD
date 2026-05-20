import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/ussd_codes.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/database/database_helper.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/bottom_nav_bar.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String _name = 'Sreehari';
  String _phone = '+91 98765 43210';
  String _bank = 'Global Federal Bank';
  bool _biometricEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final db = DatabaseHelper();
    final profile = await db.getProfile();
    if (profile != null && mounted) {
      setState(() {
        _name = profile['name'] as String? ?? 'Sreehari';
        _phone = profile['phone'] as String? ?? '+91 98765 43210';
        _bank = profile['bank'] as String? ?? 'Global Federal Bank';
      });
    }
    final authNotifier = ref.read(authProvider.notifier);
    final bio = await authNotifier.isBiometricEnabled();
    if (mounted) setState(() => _biometricEnabled = bio);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final txCount = ref.watch(transactionProvider).length;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        title: Text('Profile', style: AppTextStyles.headlineMd.copyWith(color: cs.onSurface)),
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
            color: cs.onSurfaceVariant,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 3,
        onTap: (i) {
          switch (i) {
            case 0: context.go('/home'); break;
            case 1: context.go('/history'); break;
            case 2: context.go('/contacts'); break;
            case 3: break;
          }
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF24389C), Color(0xFF3949AB)],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: cs.primary, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            _name.isNotEmpty ? _name[0].toUpperCase() : 'S',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: cs.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: cs.surface, width: 2),
                          ),
                          child: const Icon(Icons.edit_rounded, color: Colors.white, size: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(_name,
                      style: AppTextStyles.headlineLgMobile.copyWith(color: cs.onSurface)),
                  const SizedBox(height: 4),
                  Text(_phone,
                      style: AppTextStyles.bodyMd.copyWith(color: cs.onSurfaceVariant)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ProfileChip('🏦 $_bank',
                          cs.tertiaryContainer.withValues(alpha: 0.3), cs.tertiary),
                      const SizedBox(width: 8),
                      _ProfileChip('✓ Verified',
                          cs.secondaryContainer.withValues(alpha: 0.4), cs.onSecondaryContainer),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Stats Row
            Row(
              children: [
                Expanded(child: _ProfileStatCard('$txCount', 'Transactions', cs)),
                const SizedBox(width: 12),
                Expanded(child: _ProfileStatCard('2.4k', 'Reward Points', cs)),
              ],
            ),
            const SizedBox(height: 24),

            // Security & Privacy
            _ProfileSectionHeader('Security & Privacy', Icons.shield_outlined, cs),
            _ProfileSettingsCard(cs: cs, children: [
              ListTile(
                title: Text('Change Login PIN',
                    style: AppTextStyles.labelMd.copyWith(color: cs.onSurface)),
                trailing: Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
                onTap: () => context.go('/pin-setup'),
              ),
              _profileDivider(cs),
              SwitchListTile(
                title: Text('Biometric Authentication',
                    style: AppTextStyles.labelMd.copyWith(color: cs.onSurface)),
                value: _biometricEnabled,
                activeTrackColor: cs.primary,
                onChanged: (v) async {
                  setState(() => _biometricEnabled = v);
                  await ref.read(authProvider.notifier).setBiometricEnabled(v);
                },
              ),
              _profileDivider(cs),
              ListTile(
                title: Text('Privacy Settings',
                    style: AppTextStyles.labelMd.copyWith(color: cs.onSurface)),
                trailing: Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
                onTap: () {},
              ),
            ]),
            const SizedBox(height: 16),

            // Payment Settings
            _ProfileSectionHeader('Payment Settings', Icons.credit_card_outlined, cs),
            _ProfileSettingsCard(cs: cs, children: [
              ListTile(
                title: Text('Preferred Bank',
                    style: AppTextStyles.labelMd.copyWith(color: cs.onSurface)),
                subtitle: Text(_bank,
                    style: AppTextStyles.labelSm.copyWith(color: cs.onSurfaceVariant)),
                trailing: Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
                onTap: () => _showBankPicker(context),
              ),
              _profileDivider(cs),
              ListTile(
                title: Text('Linked Phone Number',
                    style: AppTextStyles.labelMd.copyWith(color: cs.onSurface)),
                subtitle:
                    Text(_phone, style: AppTextStyles.labelSm.copyWith(color: cs.onSurfaceVariant)),
                trailing: Icon(Icons.lock_outline_rounded, color: cs.onSurfaceVariant, size: 18),
              ),
              _profileDivider(cs),
              ListTile(
                title: Text('Transaction Limits',
                    style: AppTextStyles.labelMd.copyWith(color: cs.onSurface)),
                trailing: Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
                onTap: () {},
              ),
            ]),
            const SizedBox(height: 16),

            // Appearance
            _ProfileSectionHeader('Appearance', Icons.palette_outlined, cs),
            _ProfileSettingsCard(cs: cs, children: [
              SwitchListTile(
                title: Text('Dark Mode',
                    style: AppTextStyles.labelMd.copyWith(color: cs.onSurface)),
                value: isDark,
                activeTrackColor: cs.primary,
                onChanged: (_) => ref.read(themeProvider.notifier).toggle(),
              ),
              _profileDivider(cs),
              ListTile(
                title: Text('Font Size',
                    style: AppTextStyles.labelMd.copyWith(color: cs.onSurface)),
                trailing: Text('Medium',
                    style: AppTextStyles.labelMd.copyWith(color: cs.primary)),
              ),
              _profileDivider(cs),
              ListTile(
                title: Text('App Language',
                    style: AppTextStyles.labelMd.copyWith(color: cs.onSurface)),
                trailing: Text('English',
                    style: AppTextStyles.labelMd.copyWith(color: cs.primary)),
              ),
            ]),
            const SizedBox(height: 16),

            // Danger Zone
            _ProfileSectionHeader('Danger Zone', Icons.warning_amber_outlined, cs,
                color: cs.error),
            _ProfileSettingsCard(cs: cs, children: [
              ListTile(
                title: Text('Clear Transaction History',
                    style: AppTextStyles.labelMd.copyWith(color: cs.error)),
                leading: Icon(Icons.delete_outline_rounded, color: cs.error),
                onTap: () => _confirmClearHistory(context),
              ),
              _profileDivider(cs),
              ListTile(
                title: Text('Reset App',
                    style: AppTextStyles.labelMd.copyWith(color: cs.error)),
                leading: Icon(Icons.restore_rounded, color: cs.error),
                onTap: () => _confirmReset(context),
              ),
            ]),
            const SizedBox(height: 16),

            // Sign Out
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  ref.read(authProvider.notifier).logout();
                  context.go('/login');
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Sign Out'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: cs.error,
                  side: BorderSide(color: cs.error.withValues(alpha: 0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
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

  void _showBankPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          Text('Select Your Bank', style: AppTextStyles.headlineMd),
          const SizedBox(height: 8),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: indianBanks
                  .map((b) => ListTile(
                        title: Text(b, style: AppTextStyles.labelMd),
                        trailing: _bank == b
                            ? Icon(Icons.check_rounded,
                                color: Theme.of(ctx).colorScheme.primary)
                            : null,
                        onTap: () async {
                          setState(() => _bank = b);
                          await DatabaseHelper().updateProfile({'bank': b});
                          if (ctx.mounted) Navigator.pop(ctx);
                        },
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _confirmClearHistory(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear History?'),
        content: const Text('This will permanently delete all transaction records.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await ref.read(transactionProvider.notifier).clearAll();
              if (ctx.mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset App?'),
        content:
            const Text('This will wipe all data and reset the app to factory defaults.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await DatabaseHelper().resetDatabase();
              if (ctx.mounted) {
                Navigator.pop(ctx);
                context.go('/pin-setup');
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

// ─── Helper Widgets ───────────────────────────────────────────────────────────

class _ProfileSectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final ColorScheme cs;
  final Color? color;

  const _ProfileSectionHeader(this.title, this.icon, this.cs, {this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color ?? cs.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(
            title,
            style: AppTextStyles.labelMd.copyWith(
              color: color ?? cs.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSettingsCard extends StatelessWidget {
  final List<Widget> children;
  final ColorScheme cs;

  const _ProfileSettingsCard({required this.children, required this.cs});

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

Widget _profileDivider(ColorScheme cs) => Divider(
    height: 1,
    color: cs.outlineVariant.withValues(alpha: 0.5),
    indent: 16,
    endIndent: 16);

class _ProfileChip extends StatelessWidget {
  final String label;
  final Color bg, text;

  const _ProfileChip(this.label, this.bg, this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(9999)),
      child: Text(label, style: AppTextStyles.labelSm.copyWith(color: text)),
    );
  }
}

class _ProfileStatCard extends StatelessWidget {
  final String value, label;
  final ColorScheme cs;

  const _ProfileStatCard(this.value, this.label, this.cs);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.headlineMd.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.labelSm.copyWith(color: cs.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
