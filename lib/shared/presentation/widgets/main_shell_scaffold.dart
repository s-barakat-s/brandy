import 'package:brandy/core/navigation/app_routes.dart';
import 'package:brandy/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainShellScaffold extends StatelessWidget {
  const MainShellScaffold({
    super.key,
    required this.title,
    required this.brandId,
    required this.currentIndex,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.appBarBackgroundColor,
    this.appBarForegroundColor,
    this.bodyBackgroundColor,
  });

  static const double _navigationBodyClearance = 96;
  static const double _floatingActionButtonBodyClearance = 72;

  final String title;
  final String brandId;
  final int currentIndex;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Color? appBarBackgroundColor;
  final Color? appBarForegroundColor;
  final Color? bodyBackgroundColor;

  static double scrollPadding(
    BuildContext context, {
    bool hasFloatingActionButton = false,
  }) {
    return MediaQuery.paddingOf(context).bottom +
        _navigationBodyClearance +
        (hasFloatingActionButton ? _floatingActionButtonBodyClearance : 0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final palette = theme.extension<AppThemeColors>()!;
    final canPop = GoRouter.of(context).canPop();
    final navBackground = theme.brightness == Brightness.dark
        ? scheme.surfaceContainerLow
        : scheme.surfaceContainerLowest;
    final appBarIconColor =
        appBarForegroundColor ??
        theme.appBarTheme.foregroundColor ??
        scheme.onSurface;

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text(title),
        automaticallyImplyLeading: false,
        leadingWidth: 56,
        leading: IconButton(
          onPressed: () {
            if (canPop) {
              context.pop();
              return;
            }
            context.go(AppRoutes.brandsPath);
          },
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: appBarIconColor,
          ),
          tooltip: 'Back to brands',
        ),
        actions: actions,
        backgroundColor: appBarBackgroundColor,
        foregroundColor: appBarForegroundColor,
        scrolledUnderElevation: 0,
        shadowColor: palette.shadowSoft,
      ),
      body: ColoredBox(
        color: bodyBackgroundColor ?? theme.scaffoldBackgroundColor,
        child: body,
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: navBackground,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: scheme.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: palette.shadowSoft,
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: NavigationBar(
              selectedIndex: currentIndex,
              onDestinationSelected: (index) =>
                  _onDestinationSelected(context, index),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.storefront_outlined),
                  selectedIcon: Icon(Icons.storefront_rounded),
                  label: 'Brands',
                ),
                NavigationDestination(
                  icon: Icon(Icons.inventory_2_outlined),
                  selectedIcon: Icon(Icons.inventory_2_rounded),
                  label: 'Products',
                ),
                NavigationDestination(
                  icon: Icon(Icons.space_dashboard_outlined),
                  selectedIcon: Icon(Icons.space_dashboard_rounded),
                  label: 'Overview',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings_rounded),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onDestinationSelected(BuildContext context, int index) {
    final path = switch (index) {
      0 => AppRoutes.brandsPath,
      1 => AppRoutes.brandProductsPath(brandId),
      2 => AppRoutes.brandOverviewPath(brandId),
      _ => AppRoutes.brandSettingsPath(brandId),
    };

    if (GoRouterState.of(context).uri.path == path) {
      return;
    }

    context.go(path);
  }
}
