import 'package:brandy/core/services/database/isar_service.dart';
import 'package:brandy/features/products/data/models/product_record.dart';
import 'package:isar_community/isar.dart';

class ProductLocalDataSource {
  ProductLocalDataSource(this._isarService);

  final IsarService _isarService;

  Future<Isar> get _isar async => _isarService.instance;

  Future<List<ProductRecord>> getProductsByBrandId(String brandId) async {
    final isar = await _isar;
    return isar.productRecords
        .filter()
        .brandIdEqualTo(brandId)
        .sortByUpdatedAtDesc()
        .findAll();
  }

  Future<List<ProductRecord>> getActiveProductsByBrandId(String brandId) async {
    final isar = await _isar;
    return isar.productRecords
        .filter()
        .brandIdEqualTo(brandId)
        .and()
        .isArchivedEqualTo(false)
        .sortByUpdatedAtDesc()
        .findAll();
  }

  Future<List<ProductRecord>> getArchivedProductsByBrandId(String brandId) async {
    final isar = await _isar;
    return isar.productRecords
        .filter()
        .brandIdEqualTo(brandId)
        .and()
        .isArchivedEqualTo(true)
        .sortByUpdatedAtDesc()
        .findAll();
  }

  Future<ProductRecord?> getProductById(String productId) async {
    final isar = await _isar;
    return isar.productRecords.filter().idEqualTo(productId).findFirst();
  }

  Future<void> createProduct(ProductRecord record) async {
    final isar = await _isar;
    await isar.writeTxn(() async {
      await isar.productRecords.put(record);
    });
  }

  Future<void> updateProduct(ProductRecord record) async {
    final isar = await _isar;
    final existing = await getProductById(record.id);
    if (existing != null) {
      record.isarId = existing.isarId;
    }

    await isar.writeTxn(() async {
      await isar.productRecords.put(record);
    });
  }

  Future<void> archiveProduct(String productId) async {
    final isar = await _isar;
    final existing = await getProductById(productId);
    if (existing == null) {
      return;
    }

    existing
      ..isArchived = true
      ..updatedAt = DateTime.now();

    await isar.writeTxn(() async {
      await isar.productRecords.put(existing);
    });
  }

  Future<void> restoreProduct(String productId) async {
    final isar = await _isar;
    final existing = await getProductById(productId);
    if (existing == null) {
      return;
    }

    existing
      ..isArchived = false
      ..updatedAt = DateTime.now();

    await isar.writeTxn(() async {
      await isar.productRecords.put(existing);
    });
  }
}
