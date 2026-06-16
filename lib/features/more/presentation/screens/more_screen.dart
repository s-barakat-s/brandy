import 'package:brandy/app/providers/app_ui_providers.dart';
import 'package:brandy/core/theme/app_theme.dart';
import 'package:brandy/shared/presentation/widgets/app_card.dart';
import 'package:brandy/shared/presentation/widgets/app_page_scaffold.dart';
import 'package:brandy/shared/presentation/widgets/main_shell_scaffold.dart';
import 'package:brandy/shared/presentation/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({
    super.key,
    this.brandId,
  });

  final String? brandId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final selectedBrandId = ref.watch(selectedBrandIdProvider);

    if (brandId != null && brandId != selectedBrandId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(selectedBrandIdProvider.notifier).state = brandId;
      });
    }

    final bottomPadding = brandId != null
        ? MainShellScaffold.scrollPadding(context)
        : AppSpacing.large + MediaQuery.paddingOf(context).bottom;

    final body = ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.large,
        AppSpacing.large,
        AppSpacing.large,
        bottomPadding,
      ),
      children: [
        const SectionHeader(
          title: 'Appearance',
          subtitle: 'Switch between light, dark, and system-driven themes.',
        ),
        AppCard(
          tone: AppCardTone.highlight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Theme mode', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.medium),
              SegmentedButton<ThemeMode>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(
                    value: ThemeMode.system,
                    icon: Icon(Icons.brightness_auto_outlined),
                    label: Text('System'),
                  ),
                  ButtonSegment(
                    value: ThemeMode.light,
                    icon: Icon(Icons.light_mode_outlined),
                    label: Text('Light'),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    icon: Icon(Icons.dark_mode_outlined),
                    label: Text('Dark'),
                  ),
                ],
                selected: {themeMode},
                onSelectionChanged: (selection) {
                  ref.read(themeModeProvider.notifier).state = selection.first;
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xlarge),
        const SectionHeader(
          title: 'Workspace',
          subtitle: 'A quick look at what this app is optimized for.',
        ),
        const AppCard(
          child: Column(
            children: [
              _MoreListTile(
                icon: Icons.offline_bolt_outlined,
                title: 'Local-first inventory',
                subtitle: 'Your brands, products, and stock movements stay available offline.',
              ),
              SizedBox(height: AppSpacing.medium),
              _MoreListTile(
                icon: Icons.palette_outlined,
                title: 'Warm premium theme',
                subtitle: 'Light and dark themes share the same brown, sand, and cream identity.',
              ),
              SizedBox(height: AppSpacing.medium),
              _MoreListTile(
                icon: Icons.dashboard_customize_outlined,
                title: 'Focused navigation',
                subtitle: 'Overview, products, and settings stay reachable from the bottom bar.',
              ),
            ],
          ),
        ),
      ],
    );

    if (brandId != null) {
      return MainShellScaffold(
        title: 'Settings',
        brandId: brandId!,
        currentIndex: 3,
        body: body,
      );
    }

    return AppPageScaffold(
      title: 'Settings',
      body: body,
    );
  }
}

class _MoreListTile extends StatelessWidget {
  const _MoreListTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: scheme.tertiary.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: scheme.primary),
        ),
        const SizedBox(width: AppSpacing.medium),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}


