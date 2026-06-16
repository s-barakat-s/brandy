import 'package:brandy/features/brands/domain/entities/brand.dart';

abstract class BrandRepository {
  Future<List<Brand>> getActiveBrands();
  Future<List<Brand>> getArchivedBrands();
  Future<Brand?> getBrandById(String brandId);
  Future<void> createBrand(Brand brand);
  Future<void> updateBrand(Brand brand);
  Future<void> archiveBrand(String brandId);
  Future<void> restoreBrand(String brandId);
}
