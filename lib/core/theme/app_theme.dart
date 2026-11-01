import 'package:flutter/material.dart';

import 'app_tokens.dart';

class AppTheme {
  AppTheme._();

  static const ColorScheme _colorScheme = ColorScheme.light(
    primary: AppColors.primary,
    onPrimary: AppColors.surface,
    primaryContainer: AppColors.primaryContainer,
    onPrimaryContainer: AppColors.darkBlue,
    secondary: AppColors.secondaryText,
    onSecondary: AppColors.surface,
    secondaryContainer: AppColors.border,
    onSecondaryContainer: AppColors.primaryText,
    tertiary: AppColors.success,
    onTertiary: AppColors.surface,
    error: AppColors.error,
    onError: AppColors.surface,
    surface: AppColors.surface,
    onSurface: AppColors.primaryText,
    onSurfaceVariant: AppColors.secondaryText,
    outline: AppColors.border,
    outlineVariant: AppColors.border,
    shadow: AppColors.primaryText,
    scrim: Colors.black,
    inverseSurface: AppColors.primaryText,
    onInverseSurface: AppColors.surface,
    inversePrimary: Color(0xFFADC8FF),
    surfaceTint: AppColors.primary,
  );

  static ThemeData lightTheme() {
    final textTheme = _buildTextTheme();
    final controlRadius = BorderRadius.circular(AppRadii.md);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: _colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: AppColors.surface,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: AppColors.primaryText.withValues(alpha: 0.08),
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.secondaryText.withValues(alpha: 0.72),
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.secondaryText,
        ),
        border: OutlineInputBorder(
          borderRadius: controlRadius,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: controlRadius,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: controlRadius,
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: controlRadius,
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: controlRadius,
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: _buttonStyle(
          background: AppColors.primary,
          foreground: AppColors.surface,
          radius: AppRadii.md,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: _buttonStyle(
          background: AppColors.primary,
          foreground: AppColors.surface,
          radius: AppRadii.md,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.secondaryText,
        selectedLabelStyle: textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: textTheme.labelSmall,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  static TextTheme _buildTextTheme() => const TextTheme(
    displaySmall: TextStyle(
      color: AppColors.primaryText,
      fontSize: 32,
      fontWeight: FontWeight.w700,
      height: 1.25,
    ),
    headlineSmall: TextStyle(
      color: AppColors.primaryText,
      fontSize: 24,
      fontWeight: FontWeight.w700,
      height: 1.35,
    ),
    titleLarge: TextStyle(
      color: AppColors.primaryText,
      fontSize: 20,
      fontWeight: FontWeight.w700,
      height: 1.4,
    ),
    titleMedium: TextStyle(
      color: AppColors.primaryText,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.4,
    ),
    bodyLarge: TextStyle(
      color: AppColors.primaryText,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.6,
    ),
    bodyMedium: TextStyle(
      color: AppColors.secondaryText,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.55,
    ),
    labelLarge: TextStyle(
      color: AppColors.primaryText,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.4,
    ),
    labelSmall: TextStyle(
      color: AppColors.secondaryText,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 1.4,
    ),
  );

  static ButtonStyle _buttonStyle({
    required Color background,
    required Color foreground,
    required double radius,
  }) => ElevatedButton.styleFrom(
    backgroundColor: background,
    foregroundColor: foreground,
    disabledBackgroundColor: AppColors.border,
    disabledForegroundColor: AppColors.secondaryText,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.sm,
    ),
    textStyle: _buildTextTheme().labelLarge,
  );
}
