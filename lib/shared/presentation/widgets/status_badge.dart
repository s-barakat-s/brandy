import 'package:brandy/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

enum StatusBadgeType {
  inStock,
  lowStock,
  outOfStock,
  archived,
  info,
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.type,
  });

  final String label;
  final StatusBadgeType type;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final palette = theme.extension<AppThemeColors>()!;
    final styles = _stylesFor(scheme, palette);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: styles.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.medium,
          vertical: AppSpacing.small,
        ),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: styles.foreground,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  _BadgeColors _stylesFor(ColorScheme scheme, AppThemeColors palette) {
    return switch (type) {
      StatusBadgeType.inStock => _BadgeColors(
          background: palette.success.withValues(alpha: 0.18),
          foreground: palette.success,
        ),
      StatusBadgeType.lowStock => _BadgeColors(
          background: palette.warning.withValues(alpha: 0.18),
          foreground: palette.warning,
        ),
      StatusBadgeType.outOfStock => _BadgeColors(
          background: scheme.error.withValues(alpha: 0.16),
          foreground: scheme.error,
        ),
      StatusBadgeType.archived => _BadgeColors(
          background: palette.muted,
          foreground: palette.onMuted,
        ),
      StatusBadgeType.info => _BadgeColors(
          background: scheme.tertiary.withValues(alpha: 0.20),
          foreground: scheme.primary,
        ),
    };
  }
}

class _BadgeColors {
  const _BadgeColors({
    required this.background,
    required this.foreground,
  });

  final Color background;
  final Color foreground;
}
