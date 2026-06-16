export 'package:brandy/core/navigation/app_routes.dart';
import 'package:brandy/core/navigation/app_routes.dart';
import 'package:brandy/features/auth_placeholder/presentation/screens/splash_screen.dart';
import 'package:brandy/features/brands/presentation/screens/brand_form_screen.dart';
import 'package:brandy/features/brands/presentation/screens/brands_screen.dart';
import 'package:brandy/features/dashboard/presentation/screens/brand_dashboard_screen.dart';
import 'package:brandy/features/more/presentation/screens/more_screen.dart';
import 'package:brandy/features/products/presentation/screens/product_details_screen.dart';
import 'package:brandy/features/products/presentation/screens/product_form_screen.dart';
import 'package:brandy/features/products/presentation/screens/products_screen.dart';
import 'package:brandy/features/stock_movements/presentation/screens/add_stock_movement_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: SplashScreen.routePath,
    routes: [
      GoRoute(
        path: SplashScreen.routePath,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: BrandsScreen.routePath,
        builder: (context, state) => const BrandsScreen(),
        routes: [
          GoRoute(
            path: 'settings',
            builder: (context, state) => const MoreScreen(),
          ),
          GoRoute(
            path: 'new',
            builder: (context, state) => const BrandFormScreen(),
          ),
          GoRoute(
            path: ':brandId/edit',
            builder: (context, state) {
              final brandId = state.pathParameters['brandId']!;
              return BrandFormScreen(brandId: brandId);
            },
          ),
          GoRoute(
            path: ':brandId/overview',
            builder: (context, state) {
              final brandId = state.pathParameters['brandId']!;
              return BrandDashboardScreen(
                brandId: brandId,
                showShell: true,
              );
            },
          ),
          GoRoute(
            path: ':brandId/settings',
            builder: (context, state) {
              final brandId = state.pathParameters['brandId']!;
              return MoreScreen(brandId: brandId);
            },
          ),
          GoRoute(
            path: ':brandId/products',
            builder: (context, state) {
              final brandId = state.pathParameters['brandId']!;
              return ProductsScreen(
                brandId: brandId,
                showShell: true,
              );
            },
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) {
                  final brandId = state.pathParameters['brandId']!;
                  return ProductFormScreen(brandId: brandId);
                },
              ),
              GoRoute(
                path: ':productId',
                builder: (context, state) {
                  final brandId = state.pathParameters['brandId']!;
                  final productId = state.pathParameters['productId']!;
                  return ProductDetailsScreen(
                    brandId: brandId,
                    productId: productId,
                  );
                },
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) {
                      final brandId = state.pathParameters['brandId']!;
                      final productId = state.pathParameters['productId']!;
                      return ProductFormScreen(
                        brandId: brandId,
                        productId: productId,
                      );
                    },
                  ),
                  GoRoute(
                    path: 'movements/new',
                    builder: (context, state) {
                      final brandId = state.pathParameters['brandId']!;
                      final productId = state.pathParameters['productId']!;
                      return AddStockMovementScreen(
                        brandId: brandId,
                        productId: productId,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
