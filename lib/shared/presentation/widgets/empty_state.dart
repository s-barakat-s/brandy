import 'package:brandy/core/theme/app_theme.dart';
import 'package:brandy/shared/presentation/widgets/app_card.dart';
import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return AppCard(
      tone: AppCardTone.subtle,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: scheme.tertiary.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(24),
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 34,
              color: scheme.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.large),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          if (action != null) ...[
            const SizedBox(height: AppSpacing.xlarge),
            action!,
          ],
        ],
      ),
    );
  }
}
