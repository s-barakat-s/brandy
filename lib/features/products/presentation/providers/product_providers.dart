import 'package:brandy/core/services/core_providers.dart';
import 'package:brandy/core/services/id/id_generator.dart';
import 'package:brandy/features/products/data/datasources/product_local_data_source.dart';
import 'package:brandy/features/products/data/repositories/local_product_repository.dart';
import 'package:brandy/features/products/domain/entities/product.dart';
import 'package:brandy/features/products/domain/repositories/product_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductDraft {
  const ProductDraft({
    required this.brandId,
    required this.name,
    required this.code,
    required this.category,
    required this.imagePath,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.supplierName,
    required this.supplierPhone,
    required this.sourceAddress,
    required this.notes,
    required this.currentQuantity,
    required this.lowStockThreshold,
    this.productId,
  });

  final String? productId;
  final String brandId;
  final String name;
  final String code;
  final String category;
  final String imagePath;
  final double purchasePrice;
  final double sellingPrice;
  final String supplierName;
  final String supplierPhone;
  final String sourceAddress;
  final String notes;
  final int currentQuantity;
  final int lowStockThreshold;
}

class ProductMutationService {
  ProductMutationService({
    required ProductRepository repository,
    required IdGenerator idGenerator,
  })  : _repository = repository,
        _idGenerator = idGenerator;

  final ProductRepository _repository;
  final IdGenerator _idGenerator;

  Future<void> createProduct(ProductDraft draft) async {
    final now = DateTime.now();
    final product = Product(
      id: _idGenerator.generate(),
      brandId: draft.brandId,
      name: draft.name,
      code: draft.code,
      category: draft.category,
      imagePath: draft.imagePath.trim(),
      purchasePrice: draft.purchasePrice,
      sellingPrice: draft.sellingPrice,
      supplierName: draft.supplierName,
      supplierPhone: draft.supplierPhone,
      sourceAddress: draft.sourceAddress,
      notes: draft.notes,
      currentQuantity: draft.currentQuantity,
      lowStockThreshold: draft.lowStockThreshold,
      createdAt: now,
      updatedAt: now,
      isArchived: false,
    );
    await _repository.createProduct(product);
  }

  Future<void> updateProduct(ProductDraft draft) async {
    final productId = draft.productId;
    if (productId == null) {
      throw ArgumentError('productId is required when updating a product.');
    }

    final existing = await _repository.getProductById(productId);
    if (existing == null) {
      throw StateError('Product not found: $productId');
    }

    final updated = existing.copyWith(
      brandId: draft.brandId,
      name: draft.name,
      code: draft.code,
      category: draft.category,
      imagePath: draft.imagePath.trim(),
      purchasePrice: draft.purchasePrice,
      sellingPrice: draft.sellingPrice,
      supplierName: draft.supplierName,
      supplierPhone: draft.supplierPhone,
      sourceAddress: draft.sourceAddress,
      notes: draft.notes,
      currentQuantity: draft.currentQuantity,
      lowStockThreshold: draft.lowStockThreshold,
      updatedAt: DateTime.now(),
    );
    await _repository.updateProduct(updated);
  }

  Future<void> archiveProduct(String productId) {
    return _repository.archiveProduct(productId);
  }

  Future<void> restoreProduct(String productId) {
    return _repository.restoreProduct(productId);
  }
}

final productLocalDataSourceProvider = Provider<ProductLocalDataSource>((ref) {
  return ProductLocalDataSource(ref.watch(isarServiceProvider));
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return LocalProductRepository(ref.watch(productLocalDataSourceProvider));
});

final productsByBrandProvider =
    FutureProvider.family<List<Product>, String>((ref, brandId) async {
  await ref.watch(appBootstrapProvider.future);
  return ref.watch(productRepositoryProvider).getActiveProductsByBrandId(brandId);
});

final archivedProductsByBrandProvider =
    FutureProvider.family<List<Product>, String>((ref, brandId) async {
  await ref.watch(appBootstrapProvider.future);
  return ref.watch(productRepositoryProvider).getArchivedProductsByBrandId(brandId);
});

final productByIdProvider =
    FutureProvider.family<Product?, String>((ref, productId) async {
  await ref.watch(appBootstrapProvider.future);
  return ref.watch(productRepositoryProvider).getProductById(productId);
});

final productMutationServiceProvider = Provider<ProductMutationService>((ref) {
  return ProductMutationService(
    repository: ref.watch(productRepositoryProvider),
    idGenerator: ref.watch(idGeneratorProvider),
  );
});

final createProductProvider =
    Provider<Future<void> Function(ProductDraft)>((ref) {
  return (draft) async {
    await ref.read(productMutationServiceProvider).createProduct(draft);
    ref.invalidate(productsByBrandProvider(draft.brandId));
    ref.invalidate(archivedProductsByBrandProvider(draft.brandId));
  };
});

final updateProductProvider =
    Provider<Future<void> Function(ProductDraft)>((ref) {
  return (draft) async {
    await ref.read(productMutationServiceProvider).updateProduct(draft);
    ref.invalidate(productsByBrandProvider(draft.brandId));
    ref.invalidate(archivedProductsByBrandProvider(draft.brandId));
    if (draft.productId != null) {
      ref.invalidate(productByIdProvider(draft.productId!));
    }
  };
});

final archiveProductProvider = Provider<Future<void> Function(Product)>((ref) {
  return (product) async {
    await ref.read(productMutationServiceProvider).archiveProduct(product.id);
    ref.invalidate(productByIdProvider(product.id));
    ref.invalidate(productsByBrandProvider(product.brandId));
    ref.invalidate(archivedProductsByBrandProvider(product.brandId));
  };
});

final restoreProductProvider = Provider<Future<void> Function(Product)>((ref) {
  return (product) async {
    await ref.read(productMutationServiceProvider).restoreProduct(product.id);
    ref.invalidate(productByIdProvider(product.id));
    ref.invalidate(productsByBrandProvider(product.brandId));
    ref.invalidate(archivedProductsByBrandProvider(product.brandId));
  };
});
