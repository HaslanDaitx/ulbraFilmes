import 'package:flutter/material.dart';

import '../theme/colors.dart';

class AppFilledButton extends StatelessWidget {
  const AppFilledButton({
    required this.text,
    required this.onPressed,
    this.icon,
    super.key,
  });

  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final child = Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold),
    );

    if (icon == null) {
      return FilledButton(
        style: _style,
        onPressed: onPressed,
        child: child,
      );
    }

    return FilledButton.icon(
      style: _style,
      onPressed: onPressed,
      icon: Icon(icon),
      label: child,
    );
  }

  ButtonStyle get _style {
    return FilledButton.styleFrom(
      backgroundColor: AppColors.verdePrincipal,
      foregroundColor: AppColors.dourado,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 14,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }
}