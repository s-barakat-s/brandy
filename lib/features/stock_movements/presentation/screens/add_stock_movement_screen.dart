import 'package:brandy/core/theme/app_theme.dart';
import 'package:brandy/features/products/domain/entities/product.dart';
import 'package:brandy/features/products/presentation/providers/product_providers.dart';
import 'package:brandy/features/stock_movements/domain/entities/stock_movement_type.dart';
import 'package:brandy/features/stock_movements/presentation/providers/stock_movement_providers.dart';
import 'package:brandy/shared/presentation/widgets/app_card.dart';
import 'package:brandy/shared/presentation/widgets/app_page_scaffold.dart';
import 'package:brandy/shared/presentation/widgets/primary_button.dart';
import 'package:brandy/shared/presentation/widgets/section_header.dart';
import 'package:brandy/shared/presentation/widgets/status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AddStockMovementScreen extends ConsumerStatefulWidget {
  const AddStockMovementScreen({
    super.key,
    required this.brandId,
    required this.productId,
  });

  final String brandId;
  final String productId;

  @override
  ConsumerState<AddStockMovementScreen> createState() => _AddStockMovementScreenState();
}

class _AddStockMovementScreenState extends ConsumerState<AddStockMovementScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _quantityController;
  late final TextEditingController _unitPriceController;
  late final TextEditingController _noteController;
  StockMovementType _selectedType = StockMovementType.stockIn;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(text: '1');
    _unitPriceController = TextEditingController();
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _unitPriceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save(Product product) async {
    if (!_formKey.currentState!.validate() || _isSaving) {
      return;
    }

    final quantity = int.parse(_quantityController.text.trim());
    if (_selectedType == StockMovementType.sale && quantity > product.currentQuantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sale quantity cannot exceed current stock.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final input = MovementInput(
      brandId: widget.brandId,
      productId: widget.productId,
      type: _selectedType,
      quantity: quantity,
      unitPrice: _unitPriceController.text.trim().isEmpty
          ? null
          : double.parse(_unitPriceController.text.trim()),
      note: _noteController.text.trim(),
    );

    try {
      await ref.read(stockMovementEditorProvider).addMovement(
            product: product,
            input: input,
          );

      ref.invalidate(productByIdProvider(widget.productId));
      ref.invalidate(productsByBrandProvider(widget.brandId));
      ref.invalidate(stockMovementsByProductProvider(widget.productId));

      if (!mounted) {
        return;
      }
      context.pop();
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productByIdProvider(widget.productId));

    return AppPageScaffold(
      title: 'Stock Movement',
      body: productAsync.when(
        data: (product) {
          if (product == null) {
            return const Center(child: Text('Product not found.'));
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.large),
              children: [
                AppCard(
                  tone: AppCardTone.highlight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: AppSpacing.small),
                      Text(
                        'Current quantity: ${product.currentQuantity}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.large),
                      StatusBadge(
                        label: _selectedType.toDisplayLabel(),
                        type: _badgeType(_selectedType),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xlarge),
                const SectionHeader(
                  title: 'Movement Type',
                  subtitle: 'Choose whether stock is being added, sold, or reset to a specific amount.',
                ),
                AppCard(
                  child: SegmentedButton<StockMovementType>(
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment(
                        value: StockMovementType.stockIn,
                        icon: const Icon(Icons.south_west_outlined),
                        label: Text(StockMovementType.stockIn.toDisplayLabel()),
                      ),
                      ButtonSegment(
                        value: StockMovementType.sale,
                        icon: const Icon(Icons.point_of_sale_outlined),
                        label: Text(StockMovementType.sale.toDisplayLabel()),
                      ),
                      ButtonSegment(
                        value: StockMovementType.adjustment,
                        icon: const Icon(Icons.tune_outlined),
                        label: Text(StockMovementType.adjustment.toDisplayLabel()),
                      ),
                    ],
                    selected: {_selectedType},
                    onSelectionChanged: (selection) {
                      setState(() {
                        _selectedType = selection.first;
                      });
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.xlarge),
                const SectionHeader(
                  title: 'Movement Details',
                  subtitle: 'Use a larger quantity field so changes are easy to confirm before saving.',
                ),
                AppCard(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _quantityController,
                        decoration: InputDecoration(
                          labelText: _selectedType == StockMovementType.adjustment
                              ? 'New quantity'
                              : 'Quantity',
                        ),
                        style: Theme.of(context).textTheme.headlineSmall,
                        keyboardType: TextInputType.number,
                        validator: _quantityValidator,
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      TextFormField(
                        controller: _unitPriceController,
                        decoration: const InputDecoration(
                          labelText: 'Unit price (optional)',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: _optionalDoubleValidator,
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      TextFormField(
                        controller: _noteController,
                        decoration: const InputDecoration(labelText: 'Note'),
                        maxLines: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.large),
                AppCard(
                  tone: AppCardTone.subtle,
                  child: Text(
                    _helperText(product),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: AppSpacing.xlarge),
                PrimaryButton(
                  label: 'Save Movement',
                  leading: const Icon(Icons.check_circle_outline),
                  isBusy: _isSaving,
                  onPressed: () => _save(product),
                ),
                const SizedBox(height: AppSpacing.xlarge),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Failed to load product: $error')),
      ),
    );
  }

  StatusBadgeType _badgeType(StockMovementType type) {
    return switch (type) {
      StockMovementType.stockIn => StatusBadgeType.inStock,
      StockMovementType.sale => StatusBadgeType.lowStock,
      StockMovementType.adjustment => StatusBadgeType.info,
    };
  }

  String _helperText(Product product) {
    return switch (_selectedType) {
      StockMovementType.stockIn => 'This will add to the current quantity of ${product.currentQuantity}.',
      StockMovementType.sale => 'This will reduce the current quantity of ${product.currentQuantity}.',
      StockMovementType.adjustment => 'This will replace the current quantity with the new amount you enter.',
    };
  }

  String? _quantityValidator(String? value) {
    final parsed = int.tryParse(value?.trim() ?? '');
    if (parsed == null || parsed < 0) {
      return 'Enter a valid non-negative quantity';
    }
    return null;
  }

  String? _optionalDoubleValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    if (double.tryParse(value.trim()) == null) {
      return 'Enter a valid number';
    }
    return null;
  }
}
