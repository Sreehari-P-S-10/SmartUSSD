import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (i) {
        HapticFeedback.lightImpact();
        onTap(i);
      },
      backgroundColor: cs.surface,
      elevation: 3,
      indicatorColor: cs.secondaryContainer,
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded, color: cs.primary),
          label: 'Home',
        ),
        NavigationDestination(
          icon: const Icon(Icons.history_outlined),
          selectedIcon: Icon(Icons.history_rounded, color: cs.primary),
          label: 'History',
        ),
        NavigationDestination(
          icon: const Icon(Icons.contacts_outlined),
          selectedIcon: Icon(Icons.contacts_rounded, color: cs.primary),
          label: 'Contacts',
        ),
        NavigationDestination(
          icon: const Icon(Icons.person_outline_rounded),
          selectedIcon: Icon(Icons.person_rounded, color: cs.primary),
          label: 'Profile',
        ),
      ],
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    );
  }
}
