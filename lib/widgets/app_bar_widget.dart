import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme/app_text_styles.dart';

class SmartUSSDAppBar extends StatefulWidget implements PreferredSizeWidget {
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
  State<SmartUSSDAppBar> createState() => _SmartUSSDAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _SmartUSSDAppBarState extends State<SmartUSSDAppBar> {
  String _initials = 'U';

  @override
  void initState() {
    super.initState();
    _loadInitials();
  }

  Future<void> _loadInitials() async {
    if (widget.userInitials != null) {
      setState(() => _initials = widget.userInitials!);
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name') ?? '';
    if (mounted && name.isNotEmpty) {
      setState(() => _initials = name[0].toUpperCase());
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AppBar(
      backgroundColor: cs.surface,
      elevation: 0,
      scrolledUnderElevation: 1,
      // Fix ⑤: use context.pop() instead of Navigator.maybePop() for go_router
      leading: widget.showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/home');
                }
              },
              color: cs.onSurfaceVariant,
            )
          : null,
      title: Text(
        widget.title,
        style: AppTextStyles.headlineMd.copyWith(color: cs.onSurface),
      ),
      actions: [
        ...(widget.actions ?? []),
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {},
          color: cs.onSurfaceVariant,
        ),
        // Fix ③: profile icon is now tappable → navigates to /profile
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => context.go('/profile'),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: cs.primaryContainer,
              child: Text(
                _initials,
                style: AppTextStyles.labelSm
                    .copyWith(color: cs.onPrimaryContainer),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
