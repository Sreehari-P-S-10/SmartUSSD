import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as fc;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/contact_model.dart';
import '../../providers/contact_provider.dart';
import '../../widgets/app_bar_widget.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/contact_avatar.dart';

class SavedContactsScreen extends ConsumerStatefulWidget {
  const SavedContactsScreen({super.key});

  @override
  ConsumerState<SavedContactsScreen> createState() => _SavedContactsScreenState();
}

class _SavedContactsScreenState extends ConsumerState<SavedContactsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final contacts = ref.watch(contactProvider);
    final favorites = contacts.where((c) => c.isFavorite).toList();

    final filtered = _searchQuery.isEmpty
        ? contacts
        : contacts.where((c) =>
            c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            c.phone.contains(_searchQuery)).toList();

    // Group alphabetically
    final Map<String, List<ContactModel>> grouped = {};
    for (final c in filtered) {
      final key = c.name[0].toUpperCase();
      grouped[key] = [...(grouped[key] ?? []), c];
    }
    final sortedKeys = grouped.keys.toList()..sort();

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: SmartUSSDAppBar(
        title: 'Saved Contacts',
        showBack: false,
        actions: [
          // Feature ⑦: Import from device phonebook
          IconButton(
            icon: const Icon(Icons.contacts_outlined),
            tooltip: 'Import from Phone',
            onPressed: () => _importFromPhone(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddContactSheet(context),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        child: const Icon(Icons.add_rounded),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTap: (i) {
          switch (i) {
            case 0: context.go('/home'); break;
            case 1: context.go('/history'); break;
            case 2: break;
            case 3: context.go('/profile'); break;
          }
        },
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search saved contacts...',
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
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              children: [
                // Favorites
                if (favorites.isNotEmpty && _searchQuery.isEmpty) ...[
                  Text(
                    'FAVORITES',
                    style: AppTextStyles.labelSm.copyWith(
                      color: cs.secondary,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: favorites.map((c) => Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: GestureDetector(
                          onTap: () => context.go('/send'),
                          child: Column(
                            children: [
                              ContactAvatar(
                                contact: c,
                                size: 64,
                                showBorder: true,
                                onTap: () => context.go('/send'),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                c.name.split(' ').first,
                                style: AppTextStyles.labelSm.copyWith(
                                  color: cs.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // All Contacts
                ...sortedKeys.map((letter) {
                  final group = grouped[letter]!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          letter,
                          style: AppTextStyles.labelMd.copyWith(
                            color: cs.outline,
                            fontWeight: FontWeight.w700,
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
                          children: group.asMap().entries.map((e) {
                            final contact = e.value;
                            final isLast = e.key == group.length - 1;
                            return Column(
                              children: [
                                ListTile(
                                  leading: ContactAvatar(contact: contact, size: 44),
                                  title: Text(
                                    contact.name,
                                    style: AppTextStyles.labelMd.copyWith(
                                      color: cs.onSurface,
                                    ),
                                  ),
                                  subtitle: Text(
                                    contact.phone,
                                    style: AppTextStyles.labelSm.copyWith(
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.send_rounded, size: 20),
                                        color: cs.primary,
                                        onPressed: () => context.go('/send'),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          contact.isFavorite
                                              ? Icons.star_rounded
                                              : Icons.star_border_rounded,
                                          size: 20,
                                          color: contact.isFavorite
                                              ? Colors.amber
                                              : cs.onSurfaceVariant,
                                        ),
                                        onPressed: () {
                                          HapticFeedback.lightImpact();
                                          ref
                                              .read(contactProvider.notifier)
                                              .toggleFavorite(contact);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                if (!isLast)
                                  Divider(
                                    height: 1,
                                    color: cs.outlineVariant.withValues(alpha: 0.3),
                                    indent: 72,
                                  ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddContactSheet(BuildContext context) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
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
            Text('Add New Contact', style: AppTextStyles.headlineMd),
            const SizedBox(height: 20),
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: 'Full Name',
                prefixIcon: const Icon(Icons.person_outline_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: const Icon(Icons.phone_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (nameCtrl.text.isNotEmpty && phoneCtrl.text.isNotEmpty) {
                    await ref.read(contactProvider.notifier).add(
                      ContactModel(
                        name: nameCtrl.text.trim(),
                        phone: phoneCtrl.text.trim(),
                      ),
                    );
                    if (ctx.mounted) Navigator.pop(ctx);
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Save Contact'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Feature ⑦ — Import contacts from device phonebook.
  /// Uses flutter_contacts package. Works locally; no data leaves the device.
  Future<void> _importFromPhone(BuildContext context) async {
    // Request READ_CONTACTS permission
    final granted = await fc.FlutterContacts.requestPermission(readonly: true);
    if (!granted) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contacts permission denied. Enable in Settings.'),
          ),
        );
      }
      return;
    }

    // Fetch all device contacts with phone numbers
    final deviceContacts = await fc.FlutterContacts.getContacts(
      withProperties: true,
    );
    final withPhone = deviceContacts
        .where((c) => c.phones.isNotEmpty)
        .toList();

    if (!context.mounted) return;

    if (withPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No contacts with phone numbers found.')),
      );
      return;
    }

    // Show selection dialog
    final selected = <String>{};
    final cs = Theme.of(context).colorScheme;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          maxChildSize: 0.95,
          builder: (_, scrollCtrl) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Import from Phone (${withPhone.length})',
                        style: AppTextStyles.headlineMd,
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        // Save selected contacts
                        int count = 0;
                        for (final c in withPhone) {
                          if (selected.contains(c.id)) {
                            final phone = c.phones.first.number
                                .replaceAll(RegExp(r'\s+'), '');
                            await ref.read(contactProvider.notifier).add(
                              ContactModel(
                                name: c.displayName,
                                phone: phone,
                              ),
                            );
                            count++;
                          }
                        }
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  '$count contact${count == 1 ? '' : 's'} imported successfully'),
                            ),
                          );
                        }
                      },
                      child: Text(
                        'Import ${selected.length > 0 ? "(${selected.length})" : ""}',
                        style: TextStyle(
                          color: selected.isEmpty ? cs.outline : cs.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  controller: scrollCtrl,
                  itemCount: withPhone.length,
                  itemBuilder: (_, i) {
                    final c = withPhone[i];
                    final phone = c.phones.first.number;
                    final isChecked = selected.contains(c.id);
                    return CheckboxListTile(
                      value: isChecked,
                      onChanged: (_) {
                        setModalState(() {
                          if (isChecked) {
                            selected.remove(c.id);
                          } else {
                            selected.add(c.id);
                          }
                        });
                      },
                      title: Text(
                        c.displayName,
                        style: AppTextStyles.labelMd.copyWith(
                            color: cs.onSurface),
                      ),
                      subtitle: Text(
                        phone,
                        style: AppTextStyles.labelSm.copyWith(
                            color: cs.onSurfaceVariant),
                      ),
                      activeColor: cs.primary,
                      controlAffinity: ListTileControlAffinity.leading,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
