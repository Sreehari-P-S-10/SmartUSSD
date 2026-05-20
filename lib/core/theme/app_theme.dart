import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColorsLight.primary,
        onPrimary: AppColorsLight.onPrimary,
        primaryContainer: AppColorsLight.primaryContainer,
        onPrimaryContainer: AppColorsLight.onPrimaryContainer,
        secondary: AppColorsLight.secondary,
        onSecondary: AppColorsLight.onSecondary,
        secondaryContainer: AppColorsLight.secondaryContainer,
        onSecondaryContainer: AppColorsLight.onSecondaryContainer,
        tertiary: AppColorsLight.tertiary,
        onTertiary: AppColorsLight.onTertiary,
        tertiaryContainer: AppColorsLight.tertiaryContainer,
        onTertiaryContainer: AppColorsLight.onTertiaryContainer,
        error: AppColorsLight.error,
        onError: AppColorsLight.onError,
        errorContainer: AppColorsLight.errorContainer,
        onErrorContainer: AppColorsLight.onErrorContainer,
        surface: AppColorsLight.surface,
        onSurface: AppColorsLight.onSurface,
        onSurfaceVariant: AppColorsLight.onSurfaceVariant,
        outline: AppColorsLight.outline,
        outlineVariant: AppColorsLight.outlineVariant,
        shadow: Colors.black,
        scrim: Colors.black,
        inverseSurface: AppColorsLight.inverseSurface,
        onInverseSurface: AppColorsLight.inverseOnSurface,
        inversePrimary: AppColorsLight.inversePrimary,
        surfaceTint: AppColorsLight.surfaceTint,
      ),
      scaffoldBackgroundColor: AppColorsLight.background,
      textTheme: _buildTextTheme(AppColorsLight.onSurface),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColorsLight.surface,
        foregroundColor: AppColorsLight.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: AppColorsLight.outlineVariant,
        titleTextStyle: AppTextStyles.headlineMd.copyWith(
          color: AppColorsLight.onSurface,
        ),
        iconTheme: const IconThemeData(color: AppColorsLight.onSurfaceVariant),
      ),
      cardTheme: CardThemeData(
        color: AppColorsLight.surfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColorsLight.outlineVariant),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColorsLight.primary,
          foregroundColor: AppColorsLight.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: AppTextStyles.labelMd,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColorsLight.primary,
          side: const BorderSide(color: AppColorsLight.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: AppTextStyles.labelMd,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColorsLight.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColorsLight.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColorsLight.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColorsLight.primary, width: 2),
        ),
        labelStyle: AppTextStyles.labelMd.copyWith(
          color: AppColorsLight.onSurfaceVariant,
        ),
        hintStyle: AppTextStyles.bodyMd.copyWith(
          color: AppColorsLight.onSurfaceVariant.withValues(alpha: 0.6),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColorsLight.surfaceContainer,
        indicatorColor: AppColorsLight.secondaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.labelSm.copyWith(color: AppColorsLight.primary);
          }
          return AppTextStyles.labelSm.copyWith(color: AppColorsLight.onSurfaceVariant);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColorsLight.primary);
          }
          return const IconThemeData(color: AppColorsLight.onSurfaceVariant);
        }),
        elevation: 3,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColorsLight.surfaceContainerHigh,
        selectedColor: AppColorsLight.primaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9999),
        ),
        labelStyle: AppTextStyles.labelSm,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColorsLight.outlineVariant,
        thickness: 1,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? AppColorsLight.primary : AppColorsLight.outline),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? AppColorsLight.secondaryContainer : AppColorsLight.surfaceContainerHighest),
      ),
    );
    return base;
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColorsDark.primary,
        onPrimary: AppColorsDark.onPrimary,
        primaryContainer: AppColorsDark.primaryContainer,
        onPrimaryContainer: AppColorsDark.onPrimaryContainer,
        secondary: AppColorsDark.secondary,
        onSecondary: AppColorsDark.onSecondary,
        secondaryContainer: AppColorsDark.secondaryContainer,
        onSecondaryContainer: AppColorsDark.onSecondaryContainer,
        tertiary: AppColorsDark.tertiary,
        onTertiary: AppColorsDark.onTertiary,
        tertiaryContainer: AppColorsDark.tertiaryContainer,
        onTertiaryContainer: AppColorsDark.onTertiaryContainer,
        error: AppColorsDark.error,
        onError: AppColorsDark.onError,
        errorContainer: AppColorsDark.errorContainer,
        onErrorContainer: AppColorsDark.onErrorContainer,
        surface: AppColorsDark.surface,
        onSurface: AppColorsDark.onSurface,
        onSurfaceVariant: AppColorsDark.onSurfaceVariant,
        outline: AppColorsDark.outline,
        outlineVariant: AppColorsDark.outlineVariant,
        shadow: Colors.black,
        scrim: Colors.black,
        inverseSurface: AppColorsDark.inverseSurface,
        onInverseSurface: AppColorsDark.inverseOnSurface,
        inversePrimary: AppColorsDark.inversePrimary,
        surfaceTint: AppColorsDark.surfaceTint,
      ),
      scaffoldBackgroundColor: AppColorsDark.background,
      textTheme: _buildTextTheme(AppColorsDark.onSurface),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColorsDark.surfaceContainerLow,
        foregroundColor: AppColorsDark.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleTextStyle: AppTextStyles.headlineMd.copyWith(
          color: AppColorsDark.onSurface,
        ),
        iconTheme: const IconThemeData(color: AppColorsDark.onSurfaceVariant),
      ),
      cardTheme: CardThemeData(
        color: AppColorsDark.surfaceContainerLow,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColorsDark.outlineVariant),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColorsDark.primary,
          foregroundColor: AppColorsDark.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: AppTextStyles.labelMd,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColorsDark.primary,
          side: const BorderSide(color: AppColorsDark.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: AppTextStyles.labelMd,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColorsDark.surfaceContainerHigh,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColorsDark.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColorsDark.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColorsDark.primary, width: 2),
        ),
        labelStyle: AppTextStyles.labelMd.copyWith(
          color: AppColorsDark.onSurfaceVariant,
        ),
        hintStyle: AppTextStyles.bodyMd.copyWith(
          color: AppColorsDark.onSurfaceVariant.withValues(alpha: 0.6),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColorsDark.surfaceContainerLow,
        indicatorColor: AppColorsDark.secondaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.labelSm.copyWith(color: AppColorsDark.primary);
          }
          return AppTextStyles.labelSm.copyWith(color: AppColorsDark.onSurfaceVariant);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColorsDark.primary);
          }
          return const IconThemeData(color: AppColorsDark.onSurfaceVariant);
        }),
        elevation: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColorsDark.surfaceContainerHigh,
        selectedColor: AppColorsDark.primaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9999),
        ),
        labelStyle: AppTextStyles.labelSm,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColorsDark.outlineVariant,
        thickness: 1,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? AppColorsDark.primary : AppColorsDark.outline),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? AppColorsDark.secondaryContainer : AppColorsDark.surfaceContainerHighest),
      ),
    );
  }

  static TextTheme _buildTextTheme(Color textColor) {
    return GoogleFonts.robotoFlexTextTheme().copyWith(
      displayLarge: AppTextStyles.displayLg.copyWith(color: textColor),
      headlineLarge: AppTextStyles.headlineLg.copyWith(color: textColor),
      headlineMedium: AppTextStyles.headlineMd.copyWith(color: textColor),
      bodyLarge: AppTextStyles.bodyLg.copyWith(color: textColor),
      bodyMedium: AppTextStyles.bodyMd.copyWith(color: textColor),
      labelLarge: AppTextStyles.labelMd.copyWith(color: textColor),
      labelSmall: AppTextStyles.labelSm.copyWith(color: textColor),
    );
  }
}
