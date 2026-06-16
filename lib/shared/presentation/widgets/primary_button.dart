import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.leading,
    this.isFullWidth = true,
    this.isBusy = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? leading;
  final bool isFullWidth;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final effectiveChild = isBusy
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : leading;

    final button = effectiveChild == null
        ? FilledButton(
            onPressed: isBusy ? null : onPressed,
            child: Text(label),
          )
        : FilledButton.icon(
            onPressed: isBusy ? null : onPressed,
            icon: effectiveChild,
            label: Text(label),
          );

    if (isFullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }

    return button;
  }
}
