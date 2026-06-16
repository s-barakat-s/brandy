import 'package:brandy/core/services/core_providers.dart';
import 'package:brandy/core/services/id/id_generator.dart';
import 'package:brandy/features/brands/data/datasources/brand_local_data_source.dart';
import 'package:brandy/features/brands/data/repositories/local_brand_repository.dart';
import 'package:brandy/features/brands/domain/entities/brand.dart';
import 'package:brandy/features/brands/domain/repositories/brand_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BrandDraft {
  const BrandDraft({
    required this.name,
    required this.type,
    required this.logoPath,
    required this.description,
    this.brandId,
  });

  final String? brandId;
  final String name;
  final String type;
  final String? logoPath;
  final String description;
}

class BrandMutationService {
  BrandMutationService({
    required BrandRepository repository,
    required IdGenerator idGenerator,
  })  : _repository = repository,
        _idGenerator = idGenerator;

  final BrandRepository _repository;
  final IdGenerator _idGenerator;

  Future<void> createBrand(BrandDraft draft) async {
    final now = DateTime.now();
    final brand = Brand(
      id: _idGenerator.generate(),
      name: draft.name,
      type: draft.type,
      logoPath: _normalizeLogoPath(draft.logoPath),
      description: draft.description,
      createdAt: now,
      updatedAt: now,
      isArchived: false,
    );
    await _repository.createBrand(brand);
  }

  Future<void> updateBrand(BrandDraft draft) async {
    final brandId = draft.brandId;
    if (brandId == null) {
      throw ArgumentError('brandId is required when updating a brand.');
    }

    final existing = await _repository.getBrandById(brandId);
    if (existing == null) {
      throw StateError('Brand not found: $brandId');
    }

    final updated = existing.copyWith(
      name: draft.name,
      type: draft.type,
      logoPath: _normalizeLogoPath(draft.logoPath),
      description: draft.description,
      updatedAt: DateTime.now(),
    );
    await _repository.updateBrand(updated);
  }

  Future<void> archiveBrand(String brandId) {
    return _repository.archiveBrand(brandId);
  }

  Future<void> restoreBrand(String brandId) {
    return _repository.restoreBrand(brandId);
  }

  String? _normalizeLogoPath(String? logoPath) {
    final trimmed = logoPath?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }
}

final brandLocalDataSourceProvider = Provider<BrandLocalDataSource>((ref) {
  return BrandLocalDataSource(ref.watch(isarServiceProvider));
});

final brandRepositoryProvider = Provider<BrandRepository>((ref) {
  return LocalBrandRepository(ref.watch(brandLocalDataSourceProvider));
});

final brandsProvider = FutureProvider<List<Brand>>((ref) async {
  await ref.watch(appBootstrapProvider.future);
  return ref.watch(brandRepositoryProvider).getActiveBrands();
});

final archivedBrandsProvider = FutureProvider<List<Brand>>((ref) async {
  await ref.watch(appBootstrapProvider.future);
  return ref.watch(brandRepositoryProvider).getArchivedBrands();
});

final brandByIdProvider =
    FutureProvider.family<Brand?, String>((ref, brandId) async {
  await ref.watch(appBootstrapProvider.future);
  return ref.watch(brandRepositoryProvider).getBrandById(brandId);
});

final brandMutationServiceProvider = Provider<BrandMutationService>((ref) {
  return BrandMutationService(
    repository: ref.watch(brandRepositoryProvider),
    idGenerator: ref.watch(idGeneratorProvider),
  );
});

final createBrandProvider = Provider<Future<void> Function(BrandDraft)>((ref) {
  return (draft) async {
    await ref.read(brandMutationServiceProvider).createBrand(draft);
    ref.invalidate(brandsProvider);
    ref.invalidate(archivedBrandsProvider);
  };
});

final updateBrandProvider = Provider<Future<void> Function(BrandDraft)>((ref) {
  return (draft) async {
    await ref.read(brandMutationServiceProvider).updateBrand(draft);
    if (draft.brandId != null) {
      ref.invalidate(brandByIdProvider(draft.brandId!));
    }
    ref.invalidate(brandsProvider);
    ref.invalidate(archivedBrandsProvider);
  };
});

final archiveBrandProvider = Provider<Future<void> Function(String)>((ref) {
  return (brandId) async {
    await ref.read(brandMutationServiceProvider).archiveBrand(brandId);
    ref.invalidate(brandByIdProvider(brandId));
    ref.invalidate(brandsProvider);
    ref.invalidate(archivedBrandsProvider);
  };
});

final restoreBrandProvider = Provider<Future<void> Function(String)>((ref) {
  return (brandId) async {
    await ref.read(brandMutationServiceProvider).restoreBrand(brandId);
    ref.invalidate(brandByIdProvider(brandId));
    ref.invalidate(brandsProvider);
    ref.invalidate(archivedBrandsProvider);
  };
});
