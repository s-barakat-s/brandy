import 'package:brandy/app/providers/app_ui_providers.dart';
import 'package:brandy/core/navigation/app_routes.dart';
import 'package:brandy/core/theme/app_theme.dart';
import 'package:brandy/features/brands/domain/entities/brand.dart';
import 'package:brandy/features/brands/presentation/providers/brand_providers.dart';
import 'package:brandy/shared/presentation/widgets/app_page_scaffold.dart';
import 'package:brandy/shared/presentation/widgets/empty_state.dart';
import 'package:brandy/shared/presentation/widgets/local_image_provider.dart';
import 'package:brandy/shared/presentation/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BrandsScreen extends ConsumerWidget {
  const BrandsScreen({super.key});

  static const routePath = '/brands';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brandsAsync = ref.watch(brandsProvider);
    final archivedBrandsAsync = ref.watch(archivedBrandsProvider);
    final selectedBrandId = ref.watch(selectedBrandIdProvider);

    return AppPageScaffold(
      title: 'Brands',
      actions: [
        IconButton(
          onPressed: () => context.push(AppRoutes.brandsSettingsPath),
          icon: const Icon(Icons.settings_outlined),
          tooltip: 'Settings',
        ),
      ],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addBrandPath),
        icon: const Icon(Icons.add_business_outlined),
        label: const Text('Add Brand'),
      ),
      body: brandsAsync.when(
        data: (brands) {
          _clearInvalidSelectedBrand(ref, brands, selectedBrandId);

          return archivedBrandsAsync.when(
            data: (archivedBrands) {
              if (brands.isEmpty && archivedBrands.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(AppSpacing.large),
                  child: EmptyState(
                    icon: Icons.storefront_outlined,
                    title: 'Create your first brand',
                    subtitle:
                        'Start with one polished brand workspace, then manage products and stock from there.',
                    action: FilledButton.icon(
                      onPressed: () => context.push(AppRoutes.addBrandPath),
                      icon: const Icon(Icons.add),
                      label: const Text('Create Brand'),
                    ),
                  ),
                );
              }

              return ListView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.large,
                  AppSpacing.large,
                  AppSpacing.large,
                  AppPageScaffold.floatingActionButtonScrollPadding(context),
                ),
                children: [
                  if (brands.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xlarge),
                      child: EmptyState(
                        icon: Icons.archive_outlined,
                        title: 'No active brands',
                        subtitle:
                            'Restore an archived brand or create a new one to reopen your main workspace.',
                        action: FilledButton.icon(
                          onPressed: () => context.push(AppRoutes.addBrandPath),
                          icon: const Icon(Icons.add),
                          label: const Text('Add Brand'),
                        ),
                      ),
                    )
                  else
                    ...brands.map(
                      (brand) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.large),
                        child: _BrandHeroTile(
                          brand: brand,
                          archived: false,
                          isSelected: selectedBrandId == brand.id,
                        ),
                      ),
                    ),
                  if (archivedBrands.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.small),
                    const SectionHeader(
                      title: 'Archived Brands',
                      subtitle:
                          'Stored for reference without appearing in the active workspace.',
                    ),
                    const SizedBox(height: AppSpacing.small),
                    ...archivedBrands.map(
                      (brand) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.large),
                        child: _BrandHeroTile(
                          brand: brand,
                          archived: true,
                          isSelected: false,
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Text('Failed to load archived brands: $error'),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Failed to load brands: $error')),
      ),
    );
  }

  void _clearInvalidSelectedBrand(
    WidgetRef ref,
    List<Brand> brands,
    String? selectedBrandId,
  ) {
    final hasSelected =
        selectedBrandId != null && brands.any((brand) => brand.id == selectedBrandId);
    if (selectedBrandId != null && !hasSelected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(selectedBrandIdProvider.notifier).state = null;
      });
    }
  }
}

class _BrandHeroTile extends ConsumerWidget {
  const _BrandHeroTile({
    required this.brand,
    required this.archived,
    required this.isSelected,
  });

  final Brand brand;
  final bool archived;
  final bool isSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final palette = theme.extension<AppThemeColors>()!;
    final imageProvider = resolveImageProvider(brand.logoPath);

    return SizedBox(
      height: archived ? 184 : 224,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Material(
          color: archived ? scheme.surfaceContainerHigh : palette.brandHeader,
          child: InkWell(
            onTap: archived ? null : () => _openBrand(context, ref),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (imageProvider != null)
                  DecoratedBox(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                else
                  _BrandPlaceholder(
                    brand: brand,
                    archived: archived,
                  ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: archived
                          ? [
                              palette.overlaySoft,
                              palette.overlayStrong.withValues(alpha: 0.82),
                            ]
                          : [
                              palette.overlaySoft,
                              palette.overlayStrong,
                            ],
                    ),
                  ),
                ),
                if (archived)
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.14),
                    ),
                  ),
                Positioned(
                  top: AppSpacing.large,
                  left: AppSpacing.large,
                  child: _TilePill(
                    label: archived
                        ? 'Archived'
                        : isSelected
                            ? 'Current workspace'
                            : brand.type.trim().isEmpty ? 'Brand' : brand.type,
                    icon: archived
                        ? Icons.archive_outlined
                        : isSelected
                            ? Icons.check_circle_outline
                            : Icons.label_outline,
                  ),
                ),
                Positioned(
                  top: AppSpacing.medium,
                  right: AppSpacing.medium,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: PopupMenuButton<_BrandAction>(
                      tooltip: 'Brand actions',
                      icon: const Icon(Icons.more_horiz, color: Colors.white),
                      onSelected: (action) => _handleAction(context, ref, action),
                      itemBuilder: (context) {
                        if (archived) {
                          return const [
                            PopupMenuItem(
                              value: _BrandAction.restore,
                              child: Text('Restore'),
                            ),
                          ];
                        }

                        return const [
                          PopupMenuItem(
                            value: _BrandAction.open,
                            child: Text('Open workspace'),
                          ),
                          PopupMenuItem(
                            value: _BrandAction.edit,
                            child: Text('Edit brand'),
                          ),
                          PopupMenuItem(
                            value: _BrandAction.archive,
                            child: Text('Archive'),
                          ),
                        ];
                      },
                    ),
                  ),
                ),
                Positioned(
                  left: AppSpacing.large,
                  right: AppSpacing.large,
                  bottom: AppSpacing.large,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!archived && brand.type.trim().isNotEmpty) ...[
                              Text(
                                brand.type,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.86),
                                ),
                              ),
                              const SizedBox(height: 6),
                            ],
                            Text(
                              brand.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (brand.description.trim().isNotEmpty) ...[
                              const SizedBox(height: AppSpacing.small),
                              Text(
                                brand.description,
                                maxLines: archived ? 2 : 3,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.84),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (!archived) ...[
                        const SizedBox(width: AppSpacing.medium),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openBrand(BuildContext context, WidgetRef ref) {
    ref.read(selectedBrandIdProvider.notifier).state = brand.id;
    context.push(AppRoutes.brandProductsPath(brand.id));
  }

  Future<void> _handleAction(
    BuildContext context,
    WidgetRef ref,
    _BrandAction action,
  ) async {
    switch (action) {
      case _BrandAction.open:
        _openBrand(context, ref);
        return;
      case _BrandAction.edit:
        await context.push(AppRoutes.editBrandPath(brand.id));
        return;
      case _BrandAction.archive:
        await ref.read(archiveBrandProvider)(brand.id);
        return;
      case _BrandAction.restore:
        await ref.read(restoreBrandProvider)(brand.id);
        return;
    }
  }
}

class _BrandPlaceholder extends StatelessWidget {
  const _BrandPlaceholder({
    required this.brand,
    required this.archived,
  });

  final Brand brand;
  final bool archived;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppThemeColors>()!;
    final scheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: archived
              ? [
                  scheme.surfaceContainerHighest,
                  scheme.surfaceContainerHigh,
                ]
              : [
                  palette.brandHeader,
                  scheme.tertiary.withValues(alpha: 0.88),
                ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -14,
            bottom: -34,
            child: Text(
              brand.name.characters.first.toUpperCase(),
              style: theme.textTheme.displaySmall?.copyWith(
                fontSize: 120,
                color: Colors.white.withValues(alpha: 0.12),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Positioned(
            top: 24,
            right: 24,
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.image_outlined,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TilePill extends StatelessWidget {
  const _TilePill({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.medium,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

enum _BrandAction {
  open,
  edit,
  archive,
  restore,
}




