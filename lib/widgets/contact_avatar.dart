import 'package:flutter/material.dart';
import '../core/theme/app_text_styles.dart';
import '../data/models/contact_model.dart';

class ContactAvatar extends StatelessWidget {
  final ContactModel contact;
  final double size;
  final bool showBorder;
  final bool isSelected;
  final VoidCallback? onTap;

  const ContactAvatar({
    super.key,
    required this.contact,
    this.size = 56,
    this.showBorder = false,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size + (isSelected ? 6 : 0),
        height: size + (isSelected ? 6 : 0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? cs.primary : (showBorder ? cs.primary : Colors.transparent),
            width: isSelected ? 3 : 2,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(isSelected ? 3 : 0),
          child: CircleAvatar(
            radius: size / 2,
            backgroundColor: cs.primaryContainer,
            child: Text(
              contact.initials,
              style: AppTextStyles.headlineMd.copyWith(
                color: cs.onPrimaryContainer,
                fontSize: size * 0.32,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
