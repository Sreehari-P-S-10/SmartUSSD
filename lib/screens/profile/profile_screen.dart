import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/database/database_helper.dart';
import '../../providers/auth_provider.dart';
import '../../providers/contact_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/bottom_nav_bar.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String _name = '';
  String _phone = '';
  bool _biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    // Task 6: Read real name and phone from SharedPreferences (set at registration)
    final prefs = await SharedPreferences.getInstance();
    final authNotifier = ref.read(authProvider.notifier);
    final bio = await authNotifier.isBiometricEnabled();
    if (mounted) {
      setState(() {
        _name = prefs.getString('user_name') ?? '';
        _phone = prefs.getString('user_phone') ?? '';
        _biometricEnabled = bio;
      });
    }
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
                            _name.isNotEmpty ? _name[0].toUpperCase() : '?',
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
                  Text(
                    _name.isNotEmpty ? _name : 'Your Name',
                    style: AppTextStyles.headlineLgMobile.copyWith(color: cs.onSurface),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _phone.isNotEmpty ? _phone : 'Your Phone',
                    style: AppTextStyles.bodyMd.copyWith(color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: 12),
                  // Task 5: Only show ✓ Verified chip (bank chip removed)
                  _ProfileChip('✓ Verified',
                      cs.secondaryContainer.withValues(alpha: 0.4), cs.onSecondaryContainer),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Task 2: Single full-width stat card (Reward Points removed)
            _ProfileStatCard('$txCount', 'Transactions', cs),
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
              // Task 3: Biometric toggle with proper feedback
              SwitchListTile(
                title: Text('Biometric Authentication',
                    style: AppTextStyles.labelMd.copyWith(color: cs.onSurface)),
                value: _biometricEnabled,
                activeTrackColor: cs.primary,
                onChanged: (v) async {
                  if (v) {
                    // Turning ON: verify device has biometrics enrolled
                    final available =
                        await ref.read(authProvider.notifier).isBiometricAvailable();
                    if (!available) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'No biometrics found on device. Enroll fingerprint/face in Android Settings first.',
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                      return; // revert — don't update state
                    }
                  } else {
                    // Turning OFF: inform user
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Biometric login disabled. Use PIN to log in.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                  setState(() => _biometricEnabled = v);
                  await ref.read(authProvider.notifier).setBiometricEnabled(v);
                },
              ),
              _profileDivider(cs),
              // Task 4: Privacy Settings navigates to real page
              ListTile(
                title: Text('Privacy Settings',
                    style: AppTextStyles.labelMd.copyWith(color: cs.onSurface)),
                trailing: Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
                onTap: () => context.push('/privacy'),
              ),
            ]),
            const SizedBox(height: 16),

            // Task 7: "Account Info" (renamed from "Payment Settings")
            // Task 5 + 7: Preferred Bank and Transaction Limits removed — only Linked Phone remains
            _ProfileSectionHeader('Account Info', Icons.credit_card_outlined, cs),
            _ProfileSettingsCard(cs: cs, children: [
              ListTile(
                title: Text('Linked Phone Number',
                    style: AppTextStyles.labelMd.copyWith(color: cs.onSurface)),
                subtitle: Text(
                  _phone.isNotEmpty ? _phone : 'Not set',
                  style: AppTextStyles.labelSm.copyWith(color: cs.onSurfaceVariant),
                ),
                trailing: Icon(Icons.lock_outline_rounded, color: cs.onSurfaceVariant, size: 18),
              ),
            ]),
            const SizedBox(height: 16),

            // Task 8: Font Size removed — only Dark Mode + App Language remain
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

            // Task 10: Sign Out with confirmation dialog
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _confirmSignOut(context),
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

  // Task 9: Reset App — also clears contacts, SharedPreferences, navigates to /register
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
              // Clear SharedPreferences (registration + settings)
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              // Clear Riverpod contact state in memory
              ref.read(contactProvider.notifier).clearAll();
              if (ctx.mounted) {
                Navigator.pop(ctx);
                context.go('/register');
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

  // Task 10: Sign Out — confirmation dialog, clears SharedPreferences + PIN, goes to /register
  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out?'),
        content: const Text(
          'You will be signed out and need to re-enter your name, '
          'phone number, and carrier to use the app again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              // Clear registration data from SharedPreferences
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              // Clear PIN from secure storage
              await ref.read(authProvider.notifier).clearPin();
              // Reset Riverpod auth state
              ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/register');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Sign Out'),
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
      width: double.infinity,
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
