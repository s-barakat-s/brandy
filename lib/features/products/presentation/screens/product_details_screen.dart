import 'package:brandy/core/navigation/app_routes.dart';
import 'package:brandy/core/theme/app_theme.dart';
import 'package:brandy/features/products/domain/entities/product.dart';
import 'package:brandy/features/products/presentation/providers/product_providers.dart';
import 'package:brandy/features/stock_movements/domain/entities/stock_movement_type.dart';
import 'package:brandy/features/stock_movements/presentation/providers/stock_movement_providers.dart';
import 'package:brandy/shared/presentation/widgets/app_card.dart';
import 'package:brandy/shared/presentation/widgets/app_page_scaffold.dart';
import 'package:brandy/shared/presentation/widgets/local_image_provider.dart';
import 'package:brandy/shared/presentation/widgets/section_header.dart';
import 'package:brandy/shared/presentation/widgets/status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ProductDetailsScreen extends ConsumerWidget {
  const ProductDetailsScreen({
    super.key,
    required this.brandId,
    required this.productId,
  });

  final String brandId;
  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productByIdProvider(productId));
    final movementsAsync = ref.watch(
      stockMovementsByProductProvider(productId),
    );
    final currency = NumberFormat.currency(symbol: r'$');
    final dateFormat = DateFormat('MMM d, y � h:mm a');

    return productAsync.when(
      data: (product) {
        if (product == null) {
          return const AppPageScaffold(
            title: 'Product',
            body: Center(child: Text('Product not found.')),
          );
        }

        final theme = Theme.of(context);
        final scheme = theme.colorScheme;
        final palette = theme.extension<AppThemeColors>()!;
        final imageProvider = resolveImageProvider(product.imagePath);
        final bottomInset = MediaQuery.of(context).padding.bottom;
        final hasSupplier =
            product.supplierName.trim().isNotEmpty ||
            product.supplierPhone.trim().isNotEmpty ||
            product.sourceAddress.trim().isNotEmpty;

        return AppPageScaffold(
          title: product.name,
          bottomNavigationBar: SafeArea(
            top: false,
            minimum: const EdgeInsets.fromLTRB(
              AppSpacing.large,
              AppSpacing.small,
              AppSpacing.large,
              AppSpacing.large,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: scheme.outlineVariant),
                boxShadow: [
                  BoxShadow(
                    color: palette.shadowSoft,
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.medium),
                child: Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => context.push(
                          AppRoutes.addMovementPath(brandId, productId),
                        ),
                        icon: const Icon(Icons.swap_horiz_rounded),
                        label: const Text('Stock Movement'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.medium),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => context.push(
                          AppRoutes.editProductPath(brandId, productId),
                        ),
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Edit Product'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: ListView(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.large,
              AppSpacing.large,
              AppSpacing.large,
              132 + bottomInset,
            ),
            children: [
              _HeroImageCard(
                product: product,
                imageProvider: imageProvider,
                statusLabel: _statusLabel(product),
                statusType: _statusType(product),
              ),
              const SizedBox(height: AppSpacing.xlarge),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.small),
                        Text(
                          'A polished look at pricing, stock, and product details.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.72),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.medium),
                  StatusBadge(
                    label: _statusLabel(product),
                    type: _statusType(product),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.large),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 720
                      ? 3
                      : constraints.maxWidth >= 420
                      ? 2
                      : 1;
                  final itemWidth =
                      (constraints.maxWidth -
                          ((columns - 1) * AppSpacing.medium)) /
                      columns;

                  return Wrap(
                    spacing: AppSpacing.medium,
                    runSpacing: AppSpacing.medium,
                    children: [
                      SizedBox(
                        width: itemWidth,
                        child: _MetricCard(
                          icon: Icons.inventory_2_outlined,
                          label: 'Current Stock',
                          value: '${product.currentQuantity}',
                          emphasize: true,
                        ),
                      ),
                      SizedBox(
                        width: itemWidth,
                        child: _MetricCard(
                          icon: Icons.qr_code_rounded,
                          label: 'Product Code',
                          value: product.code,
                        ),
                      ),
                      SizedBox(
                        width: itemWidth,
                        child: _MetricCard(
                          icon: Icons.category_outlined,
                          label: 'Category',
                          value: product.category.trim().isEmpty
                              ? 'Uncategorized'
                              : product.category,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xlarge),
              const SectionHeader(
                title: 'Pricing',
                subtitle:
                    'Selling price takes priority while cost remains easy to compare.',
              ),
              AppCard(
                tone: AppCardTone.highlight,
                child: Row(
                  children: [
                    Expanded(
                      child: _PriceBlock(
                        label: 'Selling Price',
                        value: currency.format(product.sellingPrice),
                        emphasize: true,
                      ),
                    ),
                    SizedBox(
                      height: 74,
                      child: VerticalDivider(color: scheme.outlineVariant),
                    ),
                    Expanded(
                      child: _PriceBlock(
                        label: 'Purchase Price',
                        value: currency.format(product.purchasePrice),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xlarge),
              const SectionHeader(
                title: 'Product Details',
                subtitle:
                    'Core inventory and catalog information for this item.',
              ),
              AppCard(
                child: Column(
                  children: [
                    _DetailTile(
                      icon: Icons.warning_amber_rounded,
                      label: 'Low-stock threshold',
                      value: '${product.lowStockThreshold}',
                    ),
                    _DetailTile(
                      icon: Icons.event_available_rounded,
                      label: 'Created',
                      value: dateFormat.format(product.createdAt),
                    ),
                    _DetailTile(
                      icon: Icons.update_rounded,
                      label: 'Last updated',
                      value: dateFormat.format(product.updatedAt),
                      isLast: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xlarge),
              const SectionHeader(
                title: 'Notes & Description',
                subtitle: 'Readable details added for this product.',
              ),
              AppCard(
                child: Text(
                  product.notes.trim().isEmpty
                      ? 'No additional details were added for this product yet.'
                      : product.notes,
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                ),
              ),
              if (hasSupplier) ...[
                const SizedBox(height: AppSpacing.xlarge),
                const SectionHeader(
                  title: 'Supplier',
                  subtitle: 'Source information linked to this product.',
                ),
                AppCard(
                  child: Column(
                    children: [
                      _DetailTile(
                        icon: Icons.store_outlined,
                        label: 'Supplier',
                        value: product.supplierName.trim().isEmpty
                            ? 'Not provided'
                            : product.supplierName,
                      ),
                      _DetailTile(
                        icon: Icons.call_outlined,
                        label: 'Phone',
                        value: product.supplierPhone.trim().isEmpty
                            ? 'Not provided'
                            : product.supplierPhone,
                      ),
                      _DetailTile(
                        icon: Icons.location_on_outlined,
                        label: 'Address',
                        value: product.sourceAddress.trim().isEmpty
                            ? 'Not provided'
                            : product.sourceAddress,
                        isLast: true,
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xlarge),
              const SectionHeader(
                title: 'Movement History',
                subtitle:
                    'Recent stock changes with before and after quantities.',
              ),
              movementsAsync.when(
                data: (movements) {
                  if (movements.isEmpty) {
                    return const AppCard(
                      child: Text('No stock movements recorded yet.'),
                    );
                  }

                  return Column(
                    children: movements.map((movement) {
                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppSpacing.medium,
                        ),
                        child: AppCard(
                          tone: AppCardTone.subtle,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      movement.type.toDisplayLabel(),
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ),
                                  StatusBadge(
                                    label: '${movement.quantity}',
                                    type: _movementBadgeType(movement.type),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.medium),
                              Wrap(
                                spacing: AppSpacing.medium,
                                runSpacing: AppSpacing.small,
                                children: [
                                  _InlineMetaChip(
                                    icon: Icons.remove_red_eye_outlined,
                                    label: 'Before ${movement.beforeQuantity}',
                                  ),
                                  _InlineMetaChip(
                                    icon: Icons.trending_up_rounded,
                                    label: 'After ${movement.afterQuantity}',
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.medium),
                              Text(
                                dateFormat.format(movement.createdAt),
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: scheme.onSurface.withValues(
                                    alpha: 0.62,
                                  ),
                                ),
                              ),
                              if (movement.note.trim().isNotEmpty) ...[
                                const SizedBox(height: AppSpacing.medium),
                                Text(
                                  movement.note,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Text('Failed to load movements: $error'),
              ),
            ],
          ),
        );
      },
      loading: () => const AppPageScaffold(
        title: 'Product',
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => AppPageScaffold(
        title: 'Product',
        body: Center(child: Text('Failed to load product: $error')),
      ),
    );
  }

  StatusBadgeType _statusType(Product product) {
    if (product.currentQuantity <= 0) {
      return StatusBadgeType.outOfStock;
    }
    if (product.isLowStock) {
      return StatusBadgeType.lowStock;
    }
    return StatusBadgeType.inStock;
  }

  String _statusLabel(Product product) {
    if (product.currentQuantity <= 0) {
      return 'Out of Stock';
    }
    if (product.isLowStock) {
      return 'Low Stock';
    }
    return 'In Stock';
  }

  StatusBadgeType _movementBadgeType(StockMovementType type) {
    return switch (type) {
      StockMovementType.stockIn => StatusBadgeType.inStock,
      StockMovementType.sale => StatusBadgeType.lowStock,
      StockMovementType.adjustment => StatusBadgeType.info,
    };
  }
}

class _HeroImageCard extends StatelessWidget {
  const _HeroImageCard({
    required this.product,
    required this.imageProvider,
    required this.statusLabel,
    required this.statusType,
  });

  final Product product;
  final ImageProvider<Object>? imageProvider;
  final String statusLabel;
  final StatusBadgeType statusType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final palette = theme.extension<AppThemeColors>()!;

    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: AspectRatio(
        aspectRatio: 1.08,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageProvider != null)
              Image(image: imageProvider!, fit: BoxFit.cover)
            else
              _ImagePlaceholder(name: product.name),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    palette.overlaySoft,
                    palette.overlayStrong.withValues(alpha: 0.86),
                  ],
                ),
              ),
            ),
            Positioned(
              top: AppSpacing.large,
              right: AppSpacing.large,
              child: StatusBadge(label: statusLabel, type: statusType),
            ),
            Positioned(
              left: AppSpacing.large,
              right: AppSpacing.large,
              bottom: AppSpacing.large,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Wrap(
                    spacing: AppSpacing.small,
                    runSpacing: AppSpacing.small,
                    children: [
                      _InlineMetaChip(
                        icon: Icons.inventory_2_outlined,
                        label: '${product.currentQuantity} in stock',
                        dark: true,
                      ),
                      _InlineMetaChip(
                        icon: Icons.qr_code_rounded,
                        label: product.code,
                        dark: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.category_outlined,
                        size: 18,
                        color: Colors.white.withValues(alpha: 0.88),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          product.category.trim().isEmpty
                              ? 'Uncategorized'
                              : product.category,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.88),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return AppCard(
      tone: emphasize ? AppCardTone.highlight : AppCardTone.standard,
      padding: const EdgeInsets.all(AppSpacing.large),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: scheme.primary),
          const SizedBox(height: AppSpacing.large),
          Text(label, style: theme.textTheme.labelMedium),
          const SizedBox(height: AppSpacing.small),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceBlock extends StatelessWidget {
  const _PriceBlock({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelMedium),
        const SizedBox(height: AppSpacing.small),
        Text(
          value,
          style:
              (emphasize
                      ? theme.textTheme.headlineSmall
                      : theme.textTheme.titleLarge)
                  ?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: emphasize ? scheme.primary : null,
                  ),
        ),
      ],
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.large),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: scheme.tertiary.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: scheme.primary, size: 20),
          ),
          const SizedBox(width: AppSpacing.medium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.labelMedium),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineMetaChip extends StatelessWidget {
  const _InlineMetaChip({
    required this.icon,
    required this.label,
    this.dark = false,
  });

  final IconData icon;
  final String label;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final background = dark
        ? Colors.white.withValues(alpha: 0.16)
        : Theme.of(context).colorScheme.surfaceContainerHigh;
    final foreground = dark
        ? Colors.white
        : Theme.of(context).colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.medium,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: dark
              ? Colors.white.withValues(alpha: 0.14)
              : Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: foreground),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({required this.name});

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
            scheme.tertiary.withValues(alpha: 0.92),
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            right: -18,
            bottom: -30,
            child: Text(
              name.characters.first.toUpperCase(),
              style: theme.textTheme.displaySmall?.copyWith(
                fontSize: 132,
                color: Colors.white.withValues(alpha: 0.18),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Center(
            child: Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.62),
                borderRadius: BorderRadius.circular(28),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.photo_outlined,
                size: 36,
                color: scheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
