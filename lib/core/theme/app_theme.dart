import 'package:flutter/material.dart';
class AppTheme {
  static const mint = Color(0xFF2F7D6B);
  static const emerald = Color(0xFF3FA38A);
  static const coral = Color(0xFFE5735E);
  static const ink = Color(0xFF172026);
  static const graphite = Color(0xFF26313A);
  static const mist = Color(0xFFF5F1EA);
  static const sand = Color(0xFFE7DED2);
  static const amber = Color(0xFFD9A441);

  static ThemeData light() {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: mint,
      onPrimary: Colors.white,
      secondary: emerald,
      onSecondary: Colors.white,
      error: coral,
      onError: Colors.white,
      surface: Color(0xFFFFFCF8),
      onSurface: ink,
      surfaceContainerHighest: Color(0xFFF0E8DD),
      onSurfaceVariant: Color(0xFF60707C),
      outline: Color(0xFFD4C7B7),
      outlineVariant: Color(0xFFE5DBCF),
      shadow: Color(0x220F151A),
      inverseSurface: graphite,
      onInverseSurface: Colors.white,
      tertiary: amber,
      onTertiary: ink,
      primaryContainer: Color(0xFFDDEBE6),
      onPrimaryContainer: ink,
      secondaryContainer: Color(0xFFDDEDE8),
      onSecondaryContainer: ink,
      tertiaryContainer: Color(0xFFF3E4BF),
      onTertiaryContainer: ink,
      errorContainer: Color(0xFFF6DBD5),
      onErrorContainer: ink,
      scrim: Color(0x660F151A),
    );
    return _theme(scheme);
  }

  static ThemeData dark() {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF79B6A7),
      onPrimary: ink,
      secondary: Color(0xFFA2CDBD),
      onSecondary: ink,
      error: Color(0xFFF0A28F),
      onError: ink,
      surface: graphite,
      onSurface: Color(0xFFF4EEE7),
      surfaceContainerHighest: Color(0xFF33404A),
      onSurfaceVariant: Color(0xFFC1C9CD),
      outline: Color(0xFF4B5A65),
      outlineVariant: Color(0xFF394650),
      shadow: Colors.black54,
      inverseSurface: Color(0xFFF3EEE8),
      onInverseSurface: ink,
      tertiary: Color(0xFFE4C87D),
      onTertiary: ink,
      primaryContainer: Color(0xFF274840),
      onPrimaryContainer: Color(0xFFF4EEE7),
      secondaryContainer: Color(0xFF314B44),
      onSecondaryContainer: Color(0xFFF4EEE7),
      tertiaryContainer: Color(0xFF5B4B21),
      onTertiaryContainer: Color(0xFFF8F1D8),
      errorContainer: Color(0xFF5A332A),
      onErrorContainer: Color(0xFFF6DBD5),
      scrim: Color(0x99000000),
    );
    return _theme(scheme);
  }

  static ThemeData _theme(ColorScheme scheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor:
          scheme.brightness == Brightness.dark ? ink : mist,
      fontFamily: 'Roboto',
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: scheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.primary, width: 1.2),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        side: BorderSide(color: scheme.outlineVariant),
        backgroundColor: scheme.surface,
        selectedColor: scheme.primaryContainer,
        labelStyle: TextStyle(color: scheme.onSurface),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primary.withValues(alpha: .18),
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      ),
      dividerColor: scheme.outlineVariant,
    );
  }
}
