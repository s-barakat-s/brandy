import 'package:brandy/core/services/core_providers.dart';
import 'package:brandy/core/theme/app_theme.dart';
import 'package:brandy/features/products/domain/entities/product.dart';
import 'package:brandy/features/products/presentation/providers/product_providers.dart';
import 'package:brandy/shared/presentation/widgets/app_card.dart';
import 'package:brandy/shared/presentation/widgets/app_page_scaffold.dart';
import 'package:brandy/shared/presentation/widgets/primary_button.dart';
import 'package:brandy/shared/presentation/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  const ProductFormScreen({
    super.key,
    required this.brandId,
    this.productId,
  });

  final String brandId;
  final String? productId;

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _codeController;
  late final TextEditingController _categoryController;
  late final TextEditingController _imagePathController;
  late final TextEditingController _purchasePriceController;
  late final TextEditingController _sellingPriceController;
  late final TextEditingController _supplierNameController;
  late final TextEditingController _supplierPhoneController;
  late final TextEditingController _sourceAddressController;
  late final TextEditingController _notesController;
  late final TextEditingController _currentQuantityController;
  late final TextEditingController _lowStockThresholdController;
  bool _didHydrate = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _codeController = TextEditingController();
    _categoryController = TextEditingController();
    _imagePathController = TextEditingController();
    _purchasePriceController = TextEditingController();
    _sellingPriceController = TextEditingController();
    _supplierNameController = TextEditingController();
    _supplierPhoneController = TextEditingController();
    _sourceAddressController = TextEditingController();
    _notesController = TextEditingController();
    _currentQuantityController = TextEditingController(text: '0');
    _lowStockThresholdController = TextEditingController(text: '5');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _categoryController.dispose();
    _imagePathController.dispose();
    _purchasePriceController.dispose();
    _sellingPriceController.dispose();
    _supplierNameController.dispose();
    _supplierPhoneController.dispose();
    _sourceAddressController.dispose();
    _notesController.dispose();
    _currentQuantityController.dispose();
    _lowStockThresholdController.dispose();
    super.dispose();
  }

  void _hydrate(Product? product) {
    if (_didHydrate || product == null) {
      return;
    }

    _nameController.text = product.name;
    _codeController.text = product.code;
    _categoryController.text = product.category;
    _imagePathController.text = product.imagePath;
    _purchasePriceController.text = product.purchasePrice.toString();
    _sellingPriceController.text = product.sellingPrice.toString();
    _supplierNameController.text = product.supplierName;
    _supplierPhoneController.text = product.supplierPhone;
    _sourceAddressController.text = product.sourceAddress;
    _notesController.text = product.notes;
    _currentQuantityController.text = product.currentQuantity.toString();
    _lowStockThresholdController.text = product.lowStockThreshold.toString();
    _didHydrate = true;
  }

  Future<void> _pickImage() async {
    final pickedPath = await ref.read(imagePickerProvider).pickImagePath();
    if (pickedPath != null && mounted) {
      _imagePathController.text = pickedPath;
      setState(() {});
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final draft = ProductDraft(
      productId: widget.productId,
      brandId: widget.brandId,
      name: _nameController.text.trim(),
      code: _codeController.text.trim(),
      category: _categoryController.text.trim(),
      imagePath: _imagePathController.text.trim(),
      purchasePrice: double.parse(_purchasePriceController.text.trim()),
      sellingPrice: double.parse(_sellingPriceController.text.trim()),
      supplierName: _supplierNameController.text.trim(),
      supplierPhone: _supplierPhoneController.text.trim(),
      sourceAddress: _sourceAddressController.text.trim(),
      notes: _notesController.text.trim(),
      currentQuantity: int.parse(_currentQuantityController.text.trim()),
      lowStockThreshold: int.parse(_lowStockThresholdController.text.trim()),
    );

    try {
      if (widget.productId == null) {
        await ref.read(createProductProvider)(draft);
      } else {
        await ref.read(updateProductProvider)(draft);
      }

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
    final existingAsync = widget.productId == null
        ? const AsyncData<Product?>(null)
        : ref.watch(productByIdProvider(widget.productId!));

    return AppPageScaffold(
      title: widget.productId == null ? 'Add Product' : 'Edit Product',
      body: existingAsync.when(
        data: (product) {
          if (widget.productId != null && product == null) {
            return const Center(child: Text('Product not found.'));
          }

          _hydrate(product);
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.large),
              children: [
                const SectionHeader(
                  title: 'Basic Info',
                  subtitle: 'Give the product a clear identity that is easy to scan later.',
                ),
                AppCard(
                  tone: AppCardTone.highlight,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Product name'),
                        validator: _requiredValidator,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      TextFormField(
                        controller: _codeController,
                        decoration: const InputDecoration(labelText: 'Product code'),
                        validator: _requiredValidator,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      TextFormField(
                        controller: _categoryController,
                        decoration: const InputDecoration(labelText: 'Category'),
                        validator: _requiredValidator,
                        textInputAction: TextInputAction.next,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xlarge),
                const SectionHeader(
                  title: 'Image',
                  subtitle: 'Attach a product image path when you have one available.',
                ),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.large),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.20),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.image_outlined,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.medium),
                            Expanded(
                              child: Text(
                                _imagePathController.text.trim().isEmpty
                                    ? 'No image selected yet.'
                                    : _imagePathController.text.trim(),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      TextFormField(
                        controller: _imagePathController,
                        decoration: const InputDecoration(labelText: 'Image path'),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      OutlinedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.photo_library_outlined),
                        label: const Text('Choose Image'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xlarge),
                const SectionHeader(
                  title: 'Pricing & Stock',
                  subtitle: 'Make quantity and thresholds explicit so stock health stays obvious.',
                ),
                AppCard(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _purchasePriceController,
                        decoration: const InputDecoration(labelText: 'Purchase price'),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: _doubleValidator,
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      TextFormField(
                        controller: _sellingPriceController,
                        decoration: const InputDecoration(labelText: 'Selling price'),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: _doubleValidator,
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      TextFormField(
                        controller: _currentQuantityController,
                        decoration: const InputDecoration(labelText: 'Current quantity'),
                        keyboardType: TextInputType.number,
                        validator: _intValidator,
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      TextFormField(
                        controller: _lowStockThresholdController,
                        decoration: const InputDecoration(labelText: 'Low-stock threshold'),
                        keyboardType: TextInputType.number,
                        validator: _intValidator,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xlarge),
                const SectionHeader(
                  title: 'Supplier',
                  subtitle: 'Keep supplier details nearby for reorders and follow-up.',
                ),
                AppCard(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _supplierNameController,
                        decoration: const InputDecoration(labelText: 'Supplier name'),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      TextFormField(
                        controller: _supplierPhoneController,
                        decoration: const InputDecoration(labelText: 'Supplier phone'),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: AppSpacing.medium),
                      TextFormField(
                        controller: _sourceAddressController,
                        decoration: const InputDecoration(labelText: 'Source address'),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xlarge),
                const SectionHeader(
                  title: 'Notes',
                  subtitle: 'Capture anything useful for future stock handling or sales.',
                ),
                AppCard(
                  child: TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(labelText: 'Notes'),
                    maxLines: 5,
                  ),
                ),
                const SizedBox(height: AppSpacing.xlarge),
                PrimaryButton(
                  label: widget.productId == null ? 'Save Product' : 'Update Product',
                  leading: const Icon(Icons.check_circle_outline),
                  isBusy: _isSaving,
                  onPressed: _save,
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

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }

  String? _doubleValidator(String? value) {
    if (_requiredValidator(value) case final error?) {
      return error;
    }
    if (double.tryParse(value!.trim()) == null) {
      return 'Enter a valid number';
    }
    return null;
  }

  String? _intValidator(String? value) {
    if (_requiredValidator(value) case final error?) {
      return error;
    }
    final parsed = int.tryParse(value!.trim());
    if (parsed == null || parsed < 0) {
      return 'Enter a valid non-negative number';
    }
    return null;
  }
}
