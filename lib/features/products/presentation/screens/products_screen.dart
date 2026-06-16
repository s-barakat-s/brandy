import 'package:brandy/app/providers/app_ui_providers.dart';
import 'package:brandy/core/navigation/app_routes.dart';
import 'package:brandy/core/theme/app_theme.dart';
import 'package:brandy/features/brands/domain/entities/brand.dart';
import 'package:brandy/features/brands/presentation/providers/brand_providers.dart';
import 'package:brandy/features/products/domain/entities/product.dart';
import 'package:brandy/features/products/presentation/providers/product_providers.dart';
import 'package:brandy/shared/presentation/widgets/app_page_scaffold.dart';
import 'package:brandy/shared/presentation/widgets/empty_state.dart';
import 'package:brandy/shared/presentation/widgets/local_image_provider.dart';
import 'package:brandy/shared/presentation/widgets/main_shell_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({
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

        final floatingActionButton = currentBrandId == null
            ? null
            : FloatingActionButton.extended(
                onPressed: () => context.push(AppRoutes.addProductPath(currentBrandId)),
                icon: const Icon(Icons.add),
                label: const Text('Add Product'),
              );

        final body = currentBrandId == null
            ? Padding(
                padding: const EdgeInsets.all(AppSpacing.large),
                child: EmptyState(
                  icon: Icons.inventory_2_outlined,
                  title: 'No brand selected',
                  subtitle:
                      'Choose a brand first so products stay tied to the right workspace.',
                  action: FilledButton.icon(
                    onPressed: () => context.go(AppRoutes.brandsPath),
                    icon: const Icon(Icons.storefront_outlined),
                    label: const Text('Choose Brand'),
                  ),
                ),
              )
            : _BrandProductBrowser(
                brandId: currentBrandId,
                brandName: selectedBrand?.name ?? 'Products',
                bottomScrollPadding: useShell
                    ? MainShellScaffold.scrollPadding(
                        context,
                        hasFloatingActionButton: floatingActionButton != null,
                      )
                    : AppPageScaffold.floatingActionButtonScrollPadding(context),
              );

        if (useShell) {
          return MainShellScaffold(
            title: 'Products',
            brandId: currentBrandId,
            currentIndex: 1,
            body: body,
            floatingActionButton: floatingActionButton,
          );
        }

        return AppPageScaffold(
          title: selectedBrand == null
              ? 'Products'
              : '${selectedBrand.name} Products',
          body: body,
          floatingActionButton: floatingActionButton,
        );
      },
      loading: () => showShell && brandId != null
          ? MainShellScaffold(
              title: 'Products',
              brandId: brandId!,
              currentIndex: 1,
              body: const Center(child: CircularProgressIndicator()),
            )
          : const AppPageScaffold(
              title: 'Products',
              body: Center(child: CircularProgressIndicator()),
            ),
      error: (error, _) => showShell && brandId != null
          ? MainShellScaffold(
              title: 'Products',
              brandId: brandId!,
              currentIndex: 1,
              body: Center(child: Text('Failed to load brands: $error')),
            )
          : AppPageScaffold(
              title: 'Products',
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

class _BrandProductBrowser extends ConsumerStatefulWidget {
  const _BrandProductBrowser({
    required this.brandId,
    required this.brandName,
    required this.bottomScrollPadding,
  });

  final String brandId;
  final String brandName;
  final double bottomScrollPadding;

  @override
  ConsumerState<_BrandProductBrowser> createState() =>
      _BrandProductBrowserState();
}

class _BrandProductBrowserState extends ConsumerState<_BrandProductBrowser> {
  static const String _allCategory = 'All';

  late final TextEditingController _searchController;
  String _searchQuery = '';
  String _selectedCategory = _allCategory;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_handleSearchChanged);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_handleSearchChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsByBrandProvider(widget.brandId));

    return productsAsync.when(
      data: (products) {
        final categories = _buildCategories(products);
        final activeCategory = categories.contains(_selectedCategory)
            ? _selectedCategory
            : _allCategory;
        if (activeCategory != _selectedCategory) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _selectedCategory = activeCategory;
              });
            }
          });
        }

        final filteredProducts = products.where((product) {
          final matchesSearch = product.name.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
          final matchesCategory =
              activeCategory == _allCategory ||
              product.category.trim() == activeCategory;
          return matchesSearch && matchesCategory;
        }).toList();

        return LayoutBuilder(
          builder: (context, constraints) {
            final columns = switch (constraints.maxWidth) {
              >= 900 => 4,
              >= 700 => 3,
              >= 360 => 2,
              _ => 1,
            };

            final tileWidth =
                (constraints.maxWidth - ((columns - 1) * AppSpacing.large)) /
                columns;
            final tileHeight = switch (columns) {
              1 => tileWidth.clamp(272.0, 320.0),
              2 => (tileWidth * 1.45).clamp(238.0, 290.0),
              _ => (tileWidth * 1.22).clamp(250.0, 320.0),
            };

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.large,
                    AppSpacing.large,
                    AppSpacing.large,
                    AppSpacing.large,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${products.length} products ready to browse',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: AppSpacing.large),
                        TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: 'Search products',
                            prefixIcon: Icon(Icons.search_rounded),
                          ),
                          textInputAction: TextInputAction.search,
                        ),
                        const SizedBox(height: AppSpacing.large),
                        SizedBox(
                          height: 42,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: categories.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: AppSpacing.small),
                            itemBuilder: (context, index) {
                              final category = categories[index];
                              final isSelected = category == activeCategory;
                              return ChoiceChip(
                                label: Text(category),
                                selected: isSelected,
                                onSelected: (_) {
                                  setState(() {
                                    _selectedCategory = category;
                                  });
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: AppSpacing.large),
                      ],
                    ),
                  ),
                ),
                if (products.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.large,
                        0,
                        AppSpacing.large,
                        widget.bottomScrollPadding,
                      ),
                      child: EmptyState(
                        icon: Icons.inventory_2_outlined,
                        title: 'No products yet',
                        subtitle:
                            'This brand does not have any products yet. Add a product to start browsing inventory here.',
                        action: FilledButton.icon(
                          onPressed: () => context.push(
                            AppRoutes.addProductPath(widget.brandId),
                          ),
                          icon: const Icon(Icons.add),
                          label: const Text('Add Product'),
                        ),
                      ),
                    ),
                  )
                else if (filteredProducts.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.large,
                        0,
                        AppSpacing.large,
                        widget.bottomScrollPadding,
                      ),
                      child: const EmptyState(
                        icon: Icons.search_off_rounded,
                        title: 'No matching products',
                        subtitle:
                            'Try a different search term or switch back to another category.',
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.large,
                      0,
                      AppSpacing.large,
                      widget.bottomScrollPadding,
                    ),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _ProductTile(
                          brandId: widget.brandId,
                          product: filteredProducts[index],
                        ),
                        childCount: filteredProducts.length,
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        mainAxisSpacing: AppSpacing.large,
                        crossAxisSpacing: AppSpacing.large,
                        mainAxisExtent: tileHeight,
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) =>
          Center(child: Text('Failed to load products: $error')),
    );
  }

  List<String> _buildCategories(List<Product> products) {
    final categories =
        products
            .map((product) => product.category.trim())
            .where((category) => category.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    return <String>[_allCategory, ...categories];
  }

  void _handleSearchChanged() {
    final nextQuery = _searchController.text.trim();
    if (nextQuery == _searchQuery) {
      return;
    }

    setState(() {
      _searchQuery = nextQuery;
    });
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({required this.brandId, required this.product});

  final String brandId;
  final Product product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final palette = theme.extension<AppThemeColors>()!;
    final imageProvider = resolveImageProvider(product.imagePath);
    final currency = NumberFormat.currency(symbol: r'$');
    final contentColor = theme.brightness == Brightness.dark
        ? scheme.surfaceContainerLow
        : scheme.surfaceContainerLowest;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shadowColor: palette.shadowSoft,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.45)),
      ),
      child: InkWell(
        onTap: () =>
            context.push(AppRoutes.productDetailsPath(brandId, product.id)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 1.35,
              child: DecoratedBox(
                decoration: BoxDecoration(color: scheme.surfaceContainer),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (imageProvider != null)
                      Image(image: imageProvider, fit: BoxFit.cover)
                    else
                      _ProductPlaceholder(name: product.name),
                    Positioned(
                      top: AppSpacing.medium,
                      right: AppSpacing.medium,
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: theme.brightness == Brightness.dark
                              ? Colors.black.withValues(alpha: 0.34)
                              : Colors.white.withValues(alpha: 0.92),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '${product.currentQuantity}',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: scheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: AppSpacing.medium,
                      bottom: AppSpacing.medium,
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 74),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.brightness == Brightness.dark
                              ? Colors.black.withValues(alpha: 0.34)
                              : Colors.white.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          product.code,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: scheme.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: contentColor,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.large,
                  AppSpacing.medium,
                  AppSpacing.large,
                  AppSpacing.medium,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _descriptionPreview(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurface.withValues(alpha: 0.72),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product.category,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: scheme.onSurface.withValues(alpha: 0.55),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              currency.format(product.sellingPrice),
                              maxLines: 1,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: scheme.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              currency.format(product.purchasePrice),
                              maxLines: 1,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: scheme.onSurface.withValues(alpha: 0.45),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _descriptionPreview() {
    final notes = product.notes.trim();
    if (notes.isEmpty) {
      return 'No details added';
    }

    final words = notes.split(RegExp(r'\s+'));
    final preview = words.take(4).join(' ');
    return words.length > 4 ? '$preview...' : preview;
  }
}

class _ProductPlaceholder extends StatelessWidget {
  const _ProductPlaceholder({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.surfaceContainerHighest,
            scheme.tertiary.withValues(alpha: 0.38),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -14,
            bottom: -28,
            child: Text(
              name.characters.first.toUpperCase(),
              style: theme.textTheme.displaySmall?.copyWith(
                fontSize: 112,
                color: scheme.onSurface.withValues(alpha: 0.08),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Center(
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.photo_outlined,
                color: scheme.primary,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }
}









