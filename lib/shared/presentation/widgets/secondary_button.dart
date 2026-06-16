import 'package:flutter/material.dart';

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.leading,
    this.isFullWidth = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? leading;
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    Widget button;
    if (leading == null) {
      button = ElevatedButton(
        onPressed: onPressed,
        child: Text(label),
      );
    } else {
      button = ElevatedButton.icon(
        onPressed: onPressed,
        icon: leading!,
        label: Text(label),
      );
    }

    if (isFullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }

    return button;
  }
}
