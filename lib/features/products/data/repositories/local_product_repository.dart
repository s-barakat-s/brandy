import 'package:brandy/features/products/data/datasources/product_local_data_source.dart';
import 'package:brandy/features/products/data/models/product_record.dart';
import 'package:brandy/features/products/domain/entities/product.dart';
import 'package:brandy/features/products/domain/repositories/product_repository.dart';

class LocalProductRepository implements ProductRepository {
  LocalProductRepository(this._localDataSource);

  final ProductLocalDataSource _localDataSource;

  @override
  Future<void> archiveProduct(String productId) {
    return _localDataSource.archiveProduct(productId);
  }

  @override
  Future<void> createProduct(Product product) {
    return _localDataSource.createProduct(ProductRecord.fromEntity(product));
  }

  @override
  Future<List<Product>> getActiveProductsByBrandId(String brandId) async {
    final records = await _localDataSource.getActiveProductsByBrandId(brandId);
    return records.map((record) => record.toEntity()).toList(growable: false);
  }

  @override
  Future<List<Product>> getArchivedProductsByBrandId(String brandId) async {
    final records = await _localDataSource.getArchivedProductsByBrandId(brandId);
    return records.map((record) => record.toEntity()).toList(growable: false);
  }

  @override
  Future<Product?> getProductById(String productId) async {
    final record = await _localDataSource.getProductById(productId);
    return record?.toEntity();
  }

  @override
  Future<List<Product>> getProductsByBrandId(String brandId) async {
    final records = await _localDataSource.getProductsByBrandId(brandId);
    return records.map((record) => record.toEntity()).toList(growable: false);
  }

  @override
  Future<void> restoreProduct(String productId) {
    return _localDataSource.restoreProduct(productId);
  }

  @override
  Future<void> updateProduct(Product product) {
    return _localDataSource.updateProduct(ProductRecord.fromEntity(product));
  }
}
