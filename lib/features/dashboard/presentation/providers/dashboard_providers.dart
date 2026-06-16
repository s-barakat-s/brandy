import 'package:brandy/features/dashboard/domain/entities/brand_dashboard_summary.dart';
import 'package:brandy/features/products/presentation/providers/product_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final brandDashboardSummaryProvider =
    FutureProvider.family<BrandDashboardSummary, String>((ref, brandId) async {
  final products = await ref.watch(productsByBrandProvider(brandId).future);

  return BrandDashboardSummary(
    totalProducts: products.length,
    lowStockProducts: products.where((product) => product.isLowStock).length,
    totalUnits: products.fold<int>(
      0,
      (sum, product) => sum + product.currentQuantity,
    ),
  );
});

