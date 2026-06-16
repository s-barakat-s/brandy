import 'package:brandy/features/brands/data/datasources/brand_local_data_source.dart';
import 'package:brandy/features/brands/data/models/brand_record.dart';
import 'package:brandy/features/brands/domain/entities/brand.dart';
import 'package:brandy/features/brands/domain/repositories/brand_repository.dart';

class LocalBrandRepository implements BrandRepository {
  LocalBrandRepository(this._localDataSource);

  final BrandLocalDataSource _localDataSource;

  @override
  Future<void> archiveBrand(String brandId) {
    return _localDataSource.archiveBrand(brandId);
  }

  @override
  Future<void> createBrand(Brand brand) {
    return _localDataSource.createBrand(BrandRecord.fromEntity(brand));
  }

  @override
  Future<List<Brand>> getActiveBrands() async {
    final records = await _localDataSource.getActiveBrands();
    return records.map((record) => record.toEntity()).toList(growable: false);
  }

  @override
  Future<List<Brand>> getArchivedBrands() async {
    final records = await _localDataSource.getArchivedBrands();
    return records.map((record) => record.toEntity()).toList(growable: false);
  }

  @override
  Future<Brand?> getBrandById(String brandId) async {
    final record = await _localDataSource.getBrandById(brandId);
    return record?.toEntity();
  }

  @override
  Future<void> restoreBrand(String brandId) {
    return _localDataSource.restoreBrand(brandId);
  }

  @override
  Future<void> updateBrand(Brand brand) {
    return _localDataSource.updateBrand(BrandRecord.fromEntity(brand));
  }
}
