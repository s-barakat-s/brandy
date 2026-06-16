import 'package:brandy/features/products/domain/entities/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProductsByBrandId(String brandId);
  Future<List<Product>> getActiveProductsByBrandId(String brandId);
  Future<List<Product>> getArchivedProductsByBrandId(String brandId);
  Future<Product?> getProductById(String productId);
  Future<void> createProduct(Product product);
  Future<void> updateProduct(Product product);
  Future<void> archiveProduct(String productId);
  Future<void> restoreProduct(String productId);
}
