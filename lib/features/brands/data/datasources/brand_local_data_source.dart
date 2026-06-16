import 'package:brandy/core/services/database/isar_service.dart';
import 'package:brandy/features/brands/data/models/brand_record.dart';
import 'package:isar_community/isar.dart';

class BrandLocalDataSource {
  BrandLocalDataSource(this._isarService);

  final IsarService _isarService;

  Future<Isar> get _isar async => _isarService.instance;

  Future<List<BrandRecord>> getActiveBrands() async {
    final isar = await _isar;
    return isar.brandRecords
        .filter()
        .isArchivedEqualTo(false)
        .sortByUpdatedAtDesc()
        .findAll();
  }

  Future<List<BrandRecord>> getArchivedBrands() async {
    final isar = await _isar;
    return isar.brandRecords
        .filter()
        .isArchivedEqualTo(true)
        .sortByUpdatedAtDesc()
        .findAll();
  }

  Future<BrandRecord?> getBrandById(String brandId) async {
    final isar = await _isar;
    return isar.brandRecords.filter().idEqualTo(brandId).findFirst();
  }

  Future<void> createBrand(BrandRecord record) async {
    final isar = await _isar;
    await isar.writeTxn(() async {
      await isar.brandRecords.put(record);
    });
  }

  Future<void> updateBrand(BrandRecord record) async {
    final isar = await _isar;
    final existing = await getBrandById(record.id);
    if (existing != null) {
      record.isarId = existing.isarId;
    }

    await isar.writeTxn(() async {
      await isar.brandRecords.put(record);
    });
  }

  Future<void> archiveBrand(String brandId) async {
    final isar = await _isar;
    final existing = await getBrandById(brandId);
    if (existing == null) {
      return;
    }

    existing
      ..isArchived = true
      ..updatedAt = DateTime.now();

    await isar.writeTxn(() async {
      await isar.brandRecords.put(existing);
    });
  }

  Future<void> restoreBrand(String brandId) async {
    final isar = await _isar;
    final existing = await getBrandById(brandId);
    if (existing == null) {
      return;
    }

    existing
      ..isArchived = false
      ..updatedAt = DateTime.now();

    await isar.writeTxn(() async {
      await isar.brandRecords.put(existing);
    });
  }
}
