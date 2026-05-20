import 'package:flutter/material.dart';
import '../core/theme/app_text_styles.dart';

class SmartUSSDAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;
  final List<Widget>? actions;
  final String? userInitials;

  const SmartUSSDAppBar({
    super.key,
    required this.title,
    this.showBack = true,
    this.actions,
    this.userInitials,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AppBar(
      backgroundColor: cs.surface,
      elevation: 0,
      scrolledUnderElevation: 1,
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.of(context).maybePop(),
              color: cs.onSurfaceVariant,
            )
          : null,
      title: Text(
        title,
        style: AppTextStyles.headlineMd.copyWith(color: cs.onSurface),
      ),
      actions: [
        ...(actions ?? []),
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {},
          color: cs.onSurfaceVariant,
        ),
        if (userInitials != null)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: cs.primaryContainer,
              child: Text(
                userInitials!,
                style: AppTextStyles.labelSm.copyWith(color: cs.onPrimaryContainer),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
