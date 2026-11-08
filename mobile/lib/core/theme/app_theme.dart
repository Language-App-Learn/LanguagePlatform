import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_tokens.dart';

/// Material 3 açık/koyu temalar ve bileşen temaları.
///
/// Arapça gibi "tall" yazı sistemleri için satır yüksekliği ve font
/// seçimini Flutter, `MaterialApp` içinde locale'e göre otomatik yapar
/// (`ThemeData.localize`); burada ayrıca bir ayar gerekmez.
abstract final class AppTheme {
  static ThemeData get light => _build(Brightness.light);

  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final seeded = ColorScheme.fromSeed(
      seedColor: AppColors.seed,
      brightness: brightness,
    );
    // Light mode uses the exact brand purples; dark mode keeps the tonal
    // palette derived from the same seed.
    final scheme = brightness == Brightness.light
        ? seeded.copyWith(
            primary: AppColors.brand,
            onPrimary: Colors.white,
            primaryContainer: AppColors.brandLight,
            onPrimaryContainer: AppColors.brandDeep,
            secondary: AppColors.brandMid,
            surface: Colors.white,
            surfaceContainerLowest: Colors.white,
            surfaceContainerLow: AppColors.brandMist,
            surfaceContainer: AppColors.brandMist,
          )
        : seeded;
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: brightness,
    );
    final text = base.textTheme;
    return base.copyWith(
      extensions: [
        brightness == Brightness.light
            ? AppSemanticColors.light
            : AppSemanticColors.dark,
      ],
      scaffoldBackgroundColor: scheme.surface,
      textTheme: text.copyWith(
        headlineMedium: text.headlineMedium?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
        ),
        headlineSmall: text.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        titleLarge: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        bodyLarge: text.bodyLarge?.copyWith(height: 1.5),
        bodyMedium: text.bodyMedium?.copyWith(height: 1.45),
      ),
      materialTapTargetSize: MaterialTapTargetSize.padded,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: scheme.surface,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.lgAll,
          side: BorderSide(color: scheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
          textStyle: text.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(
            AppSizes.minTouchTarget,
            AppSizes.minTouchTarget,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.smAll),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainer,
        indicatorColor: scheme.primaryContainer,
      ),
      dialogTheme: const DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.xlAll),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusDirectional.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        minVerticalPadding: AppSpacing.sm,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
      ),
    );
  }
}
