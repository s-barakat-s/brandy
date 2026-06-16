import 'package:brandy/app/providers/app_ui_providers.dart';
import 'package:brandy/core/navigation/app_routes.dart';
import 'package:brandy/core/theme/app_theme.dart';
import 'package:brandy/features/brands/domain/entities/brand.dart';
import 'package:brandy/features/brands/presentation/providers/brand_providers.dart';
import 'package:brandy/features/products/domain/entities/product.dart';
import 'package:brandy/features/products/presentation/providers/product_providers.dart';
import 'package:brandy/shared/presentation/widgets/app_card.dart';
import 'package:brandy/shared/presentation/widgets/app_page_scaffold.dart';
import 'package:brandy/shared/presentation/widgets/empty_state.dart';
import 'package:brandy/shared/presentation/widgets/main_shell_scaffold.dart';
import 'package:brandy/shared/presentation/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BrandDashboardScreen extends ConsumerWidget {
  const BrandDashboardScreen({
    super.key,
    this.brandId,
    this.showShell = false,
  });

  final String? brandId;
  final bool showShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brandsAsync = ref.watch(brandsProvider);
    final selectedBrandId = ref.watch(selectedBrandIdProvider);

    return brandsAsync.when(
      data: (brands) {
        final currentBrandId = _resolveBrandId(ref, brands, selectedBrandId);

        if (brandId != null && brandId != selectedBrandId) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(selectedBrandIdProvider.notifier).state = brandId;
          });
        }

        final selectedBrand = currentBrandId == null
            ? null
            : brands.where((brand) => brand.id == currentBrandId).firstOrNull;
        final useShell = showShell && currentBrandId != null;

        final body = currentBrandId == null
            ? Padding(
                padding: const EdgeInsets.all(AppSpacing.large),
                child: EmptyState(
                  icon: Icons.space_dashboard_outlined,
                  title: 'Choose a brand first',
                  subtitle:
                      'Pick or create a brand from the Brands screen to view its inventory summary.',
                  action: FilledButton.icon(
                    onPressed: () => context.go(AppRoutes.brandsPath),
                    icon: const Icon(Icons.storefront_outlined),
                    label: const Text('Go to Brands'),
                  ),
                ),
              )
            : _OverviewContent(
                brandId: currentBrandId,
                brands: brands,
                isStandalone: !useShell,
              );

        if (useShell) {
          return MainShellScaffold(
            title: 'Overview',
            brandId: currentBrandId,
            currentIndex: 2,
            body: body,
          );
        }

        return AppPageScaffold(
          title: selectedBrand?.name ?? 'Overview',
          body: body,
        );
      },
      loading: () => showShell && brandId != null
          ? MainShellScaffold(
              title: 'Overview',
              brandId: brandId!,
              currentIndex: 2,
              body: const Center(child: CircularProgressIndicator()),
            )
          : const AppPageScaffold(
              title: 'Overview',
              body: Center(child: CircularProgressIndicator()),
            ),
      error: (error, _) => showShell && brandId != null
          ? MainShellScaffold(
              title: 'Overview',
              brandId: brandId!,
              currentIndex: 2,
              body: Center(child: Text('Failed to load brands: $error')),
            )
          : AppPageScaffold(
              title: 'Overview',
              body: Center(child: Text('Failed to load brands: $error')),
            ),
    );
  }

  String? _resolveBrandId(
    WidgetRef ref,
    List<Brand> brands,
    String? selectedBrandId,
  ) {
    if (brandId != null) {
      return brandId;
    }
    if (selectedBrandId != null) {
      final hasSelected = brands.any((brand) => brand.id == selectedBrandId);
      if (hasSelected) {
        return selectedBrandId;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(selectedBrandIdProvider.notifier).state = null;
      });
    }

    return null;
  }
}

class _OverviewContent extends ConsumerWidget {
  const _OverviewContent({
    required this.brandId,
    required this.brands,
    required this.isStandalone,
  });

  final String brandId;
  final List<Brand> brands;
  final bool isStandalone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brandAsync = ref.watch(brandByIdProvider(brandId));
    final productsAsync = ref.watch(productsByBrandProvider(brandId));
    final mediaQuery = MediaQuery.of(context);
    final bottomContentPadding = isStandalone
        ? AppSpacing.large + mediaQuery.padding.bottom
        : MainShellScaffold.scrollPadding(context);

    return brandAsync.when(
      data: (brand) {
        if (brand == null) {
          return const Center(child: Text('Brand not found.'));
        }

        return productsAsync.when(
          data: (products) {
            final totalProducts = products.length;
            final totalItems = products.fold<int>(
              0,
              (sum, product) => sum + product.currentQuantity,
            );
            final outOfStock = products
                .where((product) => product.currentQuantity == 0)
                .length;
            final categoryCounts = _buildCategoryCounts(products);

            return ListView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.large,
                AppSpacing.large,
                AppSpacing.large,
                bottomContentPadding,
              ),
              children: [
                const SectionHeader(
                  title: 'Inventory Summary',
                  subtitle: 'A quick snapshot of products, units, and stock status.',
                ),
                Wrap(
                  spacing: AppSpacing.medium,
                  runSpacing: AppSpacing.medium,
                  children: [
                    SizedBox(
                      width: 170,
                      child: _SummaryCard(
                        label: 'Products',
                        value: '$totalProducts',
                        icon: Icons.inventory_2_outlined,
                      ),
                    ),
                    SizedBox(
                      width: 170,
                      child: _SummaryCard(
                        label: 'Items',
                        value: '$totalItems',
                        icon: Icons.stacked_bar_chart_outlined,
                      ),
                    ),
                    SizedBox(
                      width: 170,
                      child: _SummaryCard(
                        label: 'Out of Stock',
                        value: '$outOfStock',
                        icon: Icons.remove_shopping_cart_outlined,
                        emphasize: outOfStock > 0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xlarge),
                const SectionHeader(
                  title: 'By Category',
                  subtitle: 'How many products are currently assigned to each category.',
                ),
                if (categoryCounts.isEmpty)
                  const AppCard(
                    child: Text('No product categories available yet.'),
                  )
                else
                  AppCard(
                    child: Column(
                      children: categoryCounts.entries.map((entry) {
                        final isLast = entry.key == categoryCounts.keys.last;
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: isLast ? 0 : AppSpacing.medium,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  entry.key,
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                              Text(
                                '${entry.value}',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text('Failed to load products: $error'),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Failed to load brand: $error')),
    );
  }

  Map<String, int> _buildCategoryCounts(List<Product> products) {
    final counts = <String, int>{};
    for (final product in products) {
      final category = product.category.trim().isEmpty ? 'Uncategorized' : product.category.trim();
      counts.update(category, (value) => value + 1, ifAbsent: () => 1);
    }

    final sortedEntries = counts.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return {for (final entry in sortedEntries) entry.key: entry.value};
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      tone: emphasize ? AppCardTone.highlight : AppCardTone.standard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: AppSpacing.large),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: AppSpacing.small),
          Text(value, style: Theme.of(context).textTheme.headlineSmall),
        ],
      ),
    );
  }
}



