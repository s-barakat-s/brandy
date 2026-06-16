import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static const double radiusCard = 28;
  static const double radiusControl = 20;
  static ThemeData lightTheme() {
    const baseScheme = ColorScheme.light(
      primary: _AppColors.brandGreen,
      onPrimary: _AppColors.onBrandGreen,
      secondary: Color(0xFF5E7F72),
      onSecondary: Colors.white,
      tertiary: Color(0xFFEAF4EF),
      onTertiary: _AppColors.brandGreen,
      surface: Colors.white,
      onSurface: _AppColors.onSurfaceLight,
      error: _AppColors.error,
      onError: Colors.white,
    );

    final colorScheme = baseScheme.copyWith(
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: const Color(0xFFFCFEFD),
      surfaceContainer: const Color(0xFFF6FAF8),
      surfaceContainerHigh: const Color(0xFFF0F6F3),
      surfaceContainerHighest: const Color(0xFFE8F1EC),
      outline: _AppColors.brandGreen.withValues(alpha: 0.16),
      outlineVariant: _AppColors.brandGreen.withValues(alpha: 0.08),
      surfaceTint: _AppColors.brandGreen,
      inverseSurface: _AppColors.brandGreen,
      onInverseSurface: Colors.white,
      inversePrimary: Colors.white,
      shadow: _AppColors.brandGreen.withValues(alpha: 0.08),
      scrim: _AppColors.brandGreen.withValues(alpha: 0.18),
    );

    return _buildTheme(
      colorScheme: colorScheme,
      palette: const AppThemeColors(
        success: Color(0xFF2F7A57),
        onSuccess: Colors.white,
        warning: Color(0xFFB68A3D),
        onWarning: Color(0xFF1F1F1F),
        muted: Color(0xFFF3F7F4),
        onMuted: Color(0xFF5C6A63),
        hero: Color(0xFFF7FBF9),
        onHero: _AppColors.brandGreen,
        shadowSoft: Color(0x141F4D3A),
        brandHeader: _AppColors.brandGreen,
        onBrandHeader: Colors.white,
        overlayStrong: Color(0xAA10241D),
        overlaySoft: Color(0x2210241D),
      ),
      scaffoldBackground: Colors.white,
      textTheme: _textTheme(colorScheme),
      isDark: false,
    );
  }

  static ThemeData darkTheme() {
    const baseScheme = ColorScheme.dark(
      primary: Color(0xFF72A38F),
      onPrimary: Color(0xFF10241D),
      secondary: Color(0xFF8FB3A5),
      onSecondary: Color(0xFF10241D),
      tertiary: Color(0xFF1F312A),
      onTertiary: Color(0xFFEAF4EF),
      surface: Color(0xFF0F1714),
      onSurface: Color(0xFFF2F7F4),
      error: _AppColors.errorDark,
      onError: Color(0xFF10241D),
    );

    final colorScheme = baseScheme.copyWith(
      surfaceContainerLowest: const Color(0xFF0A100E),
      surfaceContainerLow: const Color(0xFF121C18),
      surfaceContainer: const Color(0xFF17231E),
      surfaceContainerHigh: const Color(0xFF1D2D27),
      surfaceContainerHighest: const Color(0xFF243831),
      outline: const Color(0x4472A38F),
      outlineVariant: const Color(0x2272A38F),
      surfaceTint: const Color(0xFF72A38F),
      inverseSurface: const Color(0xFFF4F8F6),
      onInverseSurface: const Color(0xFF10241D),
      inversePrimary: _AppColors.brandGreen,
      shadow: const Color(0x66000000),
      scrim: const Color(0x88000000),
    );

    return _buildTheme(
      colorScheme: colorScheme,
      palette: const AppThemeColors(
        success: Color(0xFF78C29A),
        onSuccess: Color(0xFF10241D),
        warning: Color(0xFFD9B36A),
        onWarning: Color(0xFF161616),
        muted: Color(0xFF1B2722),
        onMuted: Color(0xFFC6D6CF),
        hero: Color(0xFF16231F),
        onHero: Color(0xFFF2F7F4),
        shadowSoft: Color(0x33000000),
        brandHeader: Color(0xFF16392D),
        onBrandHeader: Colors.white,
        overlayStrong: Color(0xCC08110E),
        overlaySoft: Color(0x5208110E),
      ),
      scaffoldBackground: const Color(0xFF0B120F),
      textTheme: _textTheme(colorScheme),
      isDark: true,
    );
  }

  static ThemeData _buildTheme({
    required ColorScheme colorScheme,
    required AppThemeColors palette,
    required Color scaffoldBackground,
    required TextTheme textTheme,
    required bool isDark,
  }) {
    final cardColor = isDark
        ? colorScheme.surfaceContainerHigh
        : colorScheme.surfaceContainerLowest;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      extensions: <ThemeExtension<dynamic>>[palette],
      scaffoldBackgroundColor: scaffoldBackground,
      canvasColor: scaffoldBackground,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: palette.brandHeader,
        foregroundColor: palette.onBrandHeader,
        shadowColor: palette.shadowSoft,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 68,
        titleSpacing: 20,
        elevation: 0,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: palette.onBrandHeader,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: palette.shadowSoft,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? colorScheme.surfaceContainer
            : colorScheme.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.large,
          vertical: AppSpacing.large,
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.76),
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.50),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusControl),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusControl),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusControl),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusControl),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusControl),
          borderSide: BorderSide(color: colorScheme.error, width: 1.4),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: palette.brandHeader,
          foregroundColor: palette.onBrandHeader,
          disabledBackgroundColor: palette.brandHeader.withValues(alpha: 0.32),
          disabledForegroundColor: palette.onBrandHeader.withValues(
            alpha: 0.72,
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xlarge,
            vertical: AppSpacing.large,
          ),
          minimumSize: const Size.fromHeight(54),
          textStyle: textTheme.titleMedium,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.surfaceContainerLow,
          foregroundColor: palette.brandHeader,
          shadowColor: Colors.transparent,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xlarge,
            vertical: AppSpacing.large,
          ),
          minimumSize: const Size.fromHeight(52),
          textStyle: textTheme.titleMedium,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.brandHeader,
          side: BorderSide(color: colorScheme.outlineVariant),
          backgroundColor: isDark
              ? colorScheme.surfaceContainerLow.withValues(alpha: 0.52)
              : colorScheme.surfaceContainerLowest,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.large,
            vertical: AppSpacing.medium,
          ),
          minimumSize: const Size(0, 52),
          textStyle: textTheme.titleMedium,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusControl),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: palette.brandHeader,
        foregroundColor: palette.onBrandHeader,
        elevation: 0,
        extendedTextStyle: textTheme.titleMedium?.copyWith(
          color: palette.onBrandHeader,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHigh,
        selectedColor: colorScheme.primary.withValues(alpha: 0.14),
        disabledColor: colorScheme.surfaceContainerHighest,
        side: BorderSide.none,
        labelStyle: textTheme.labelMedium?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        secondaryLabelStyle: textTheme.labelMedium?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.small,
          vertical: 4,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.14),
        height: 70,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return textTheme.labelMedium?.copyWith(
            color: isSelected ? colorScheme.primary : colorScheme.secondary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: isSelected ? colorScheme.primary : colorScheme.secondary,
          );
        }),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return colorScheme.primary.withValues(alpha: 0.14);
            }
            return colorScheme.surfaceContainerLow;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return colorScheme.primary;
            }
            return colorScheme.secondary;
          }),
          side: WidgetStateProperty.all(
            BorderSide(color: colorScheme.outlineVariant),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          textStyle: WidgetStateProperty.all(textTheme.labelMedium),
        ),
      ),
      dividerColor: colorScheme.outlineVariant,
      listTileTheme: ListTileThemeData(
        iconColor: colorScheme.onSurface,
        textColor: colorScheme.onSurface,
        subtitleTextStyle: textTheme.bodyMedium,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.large,
          vertical: AppSpacing.small,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: palette.brandHeader,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: palette.onBrandHeader,
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
    );
  }

  static TextTheme _textTheme(ColorScheme colorScheme) {
    return TextTheme(
      displaySmall: TextStyle(
        fontSize: 38,
        height: 1.04,
        fontWeight: FontWeight.w800,
        color: colorScheme.onSurface,
        letterSpacing: -0.8,
      ),
      headlineSmall: TextStyle(
        fontSize: 30,
        height: 1.15,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
        letterSpacing: -0.5,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        height: 1.22,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
        letterSpacing: -0.2,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        height: 1.35,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        height: 1.5,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        height: 1.45,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface.withValues(alpha: 0.76),
      ),
      labelLarge: TextStyle(
        fontSize: 13,
        height: 1.3,
        fontWeight: FontWeight.w700,
        color: colorScheme.primary,
        letterSpacing: 0.2,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        height: 1.35,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface.withValues(alpha: 0.64),
        letterSpacing: 0.2,
      ),
    );
  }
}

class AppSpacing {
  const AppSpacing._();

  static const double small = 8;
  static const double medium = 12;
  static const double large = 16;
  static const double xlarge = 24;
  static const double xxlarge = 32;
}

@immutable
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  const AppThemeColors({
    required this.success,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
    required this.muted,
    required this.onMuted,
    required this.hero,
    required this.onHero,
    required this.shadowSoft,
    required this.brandHeader,
    required this.onBrandHeader,
    required this.overlayStrong,
    required this.overlaySoft,
  });

  final Color success;
  final Color onSuccess;
  final Color warning;
  final Color onWarning;
  final Color muted;
  final Color onMuted;
  final Color hero;
  final Color onHero;
  final Color shadowSoft;
  final Color brandHeader;
  final Color onBrandHeader;
  final Color overlayStrong;
  final Color overlaySoft;

  @override
  AppThemeColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? warning,
    Color? onWarning,
    Color? muted,
    Color? onMuted,
    Color? hero,
    Color? onHero,
    Color? shadowSoft,
    Color? brandHeader,
    Color? onBrandHeader,
    Color? overlayStrong,
    Color? overlaySoft,
  }) {
    return AppThemeColors(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      muted: muted ?? this.muted,
      onMuted: onMuted ?? this.onMuted,
      hero: hero ?? this.hero,
      onHero: onHero ?? this.onHero,
      shadowSoft: shadowSoft ?? this.shadowSoft,
      brandHeader: brandHeader ?? this.brandHeader,
      onBrandHeader: onBrandHeader ?? this.onBrandHeader,
      overlayStrong: overlayStrong ?? this.overlayStrong,
      overlaySoft: overlaySoft ?? this.overlaySoft,
    );
  }

  @override
  AppThemeColors lerp(ThemeExtension<AppThemeColors>? other, double t) {
    if (other is! AppThemeColors) {
      return this;
    }

    return AppThemeColors(
      success: Color.lerp(success, other.success, t) ?? success,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t) ?? onSuccess,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      onWarning: Color.lerp(onWarning, other.onWarning, t) ?? onWarning,
      muted: Color.lerp(muted, other.muted, t) ?? muted,
      onMuted: Color.lerp(onMuted, other.onMuted, t) ?? onMuted,
      hero: Color.lerp(hero, other.hero, t) ?? hero,
      onHero: Color.lerp(onHero, other.onHero, t) ?? onHero,
      shadowSoft: Color.lerp(shadowSoft, other.shadowSoft, t) ?? shadowSoft,
      brandHeader: Color.lerp(brandHeader, other.brandHeader, t) ?? brandHeader,
      onBrandHeader:
          Color.lerp(onBrandHeader, other.onBrandHeader, t) ?? onBrandHeader,
      overlayStrong:
          Color.lerp(overlayStrong, other.overlayStrong, t) ?? overlayStrong,
      overlaySoft: Color.lerp(overlaySoft, other.overlaySoft, t) ?? overlaySoft,
    );
  }
}

class _AppColors {
  const _AppColors._();

  static const Color darkBrown = Color(0xFF3E2522);
  static const Color mediumBrown = Color(0xFF8C6E63);
  static const Color mediumBrownDark = Color(0xFFB59A90);
  static const Color warmSand = Color(0xFFD3A376);
  static const Color lightCream = Color(0xFFFFE0B2);
  static const Color softWhite = Color(0xFFFFF2DF);

  static const Color brandGreen = Color(0xFF1F4D3A);
  static const Color brandGreenDark = Color(0xFF163428);
  static const Color greenAccentDark = Color(0xFF9EC8B5);

  static const Color onDarkBrown = Color(0xFFFFF8F1);
  static const Color onBrandGreen = Color(0xFFF8FBF8);
  static const Color onSurfaceLight = Color(0xFF2F1D1A);

  static const Color backgroundDark = Color(0xFF171211);
  static const Color surfaceDark = Color(0xFF241B19);
  static const Color surfaceDarkSoft = Color(0xFF302522);
  static const Color surfaceDarkRaised = Color(0xFF3A2D2A);
  static const Color onSurfaceDark = Color(0xFFF2E4D4);

  static const Color error = Color(0xFF8A3C32);
  static const Color errorDark = Color(0xFFFFB4A7);
}
