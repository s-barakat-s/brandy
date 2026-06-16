import 'package:brandy/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

enum AppCardTone {
  standard,
  subtle,
  highlight,
}

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.xlarge),
    this.margin,
    this.onTap,
    this.tone = AppCardTone.standard,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final AppCardTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final palette = theme.extension<AppThemeColors>()!;

    final color = switch (tone) {
      AppCardTone.standard => theme.cardTheme.color ?? scheme.surfaceContainerHigh,
      AppCardTone.subtle => scheme.surfaceContainer,
      AppCardTone.highlight => palette.hero,
    };

    final borderColor = switch (tone) {
      AppCardTone.highlight => scheme.tertiary.withValues(alpha: 0.32),
      _ => scheme.outlineVariant,
    };

    return Card(
      margin: margin ?? EdgeInsets.zero,
      color: color,
      elevation: 0,
      shadowColor: theme.cardTheme.shadowColor,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        side: BorderSide(color: borderColor),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
