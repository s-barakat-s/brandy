class AppRoutes {
  const AppRoutes._();

  static const brandsPath = '/brands';
  static const brandsSettingsPath = '/brands/settings';
  static const addBrandPath = '/brands/new';

  static String editBrandPath(String brandId) => '/brands/$brandId/edit';

  static String brandProductsPath(String brandId) => '/brands/$brandId/products';

  static String brandOverviewPath(String brandId) => '/brands/$brandId/overview';

  static String brandSettingsPath(String brandId) => '/brands/$brandId/settings';

  static String addProductPath(String brandId) => '/brands/$brandId/products/new';

  static String productDetailsPath(String brandId, String productId) =>
      '/brands/$brandId/products/$productId';

  static String editProductPath(String brandId, String productId) =>
      '/brands/$brandId/products/$productId/edit';

  static String addMovementPath(String brandId, String productId) =>
      '/brands/$brandId/products/$productId/movements/new';
}
