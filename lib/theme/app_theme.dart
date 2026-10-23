// app_theme.dart
// ---------------------------------------------------------------------------
// Every colour, font size and corner radius of the app lives in this file.
//
// Why one file?  If you want to change the look of FinWise you only edit
// here - no hunting through 20 screens.
//
// The palette comes from the "Colours Cafe" swatch:
//   005B4C  deep green  -> brand colour, income, success
//   DB444E  red         -> spending, danger, "over budget"
//   FD7B64  coral       -> the main call-to-action (most eye-catching)
//   F9BCC5  pink        -> soft highlights, selected states
//   F1E7E9  blush       -> app background (light mode)
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';

/// The raw palette. Widgets should normally use [FinColors] (see below)
/// instead, because FinColors also knows the dark-mode versions.
class Palette {
  Palette._(); // nobody should create a Palette object - it only holds constants

  static const green = Color(0xFF005B4C);
  static const greenLight = Color(0xFF0B7A66);
  static const red = Color(0xFFDB444E);
  static const coral = Color(0xFFFD7B64);
  static const pink = Color(0xFFF9BCC5);
  static const blush = Color(0xFFF1E7E9);
}

/// Sizes used everywhere, so spacing stays consistent ("elements breathe").
class Gaps {
  Gaps._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  /// Horizontal padding of every screen.
  static const double page = 20;

  static const double radiusSm = 12;
  static const double radius = 20;
  static const double radiusLg = 28;
}

/// App-specific colours that change between light and dark mode.
///
/// Flutter's built-in ColorScheme does not have names like "coralSoft", so we
/// add our own set through a ThemeExtension. Any widget can read them with
/// `context.fin.coral` (see the extension at the bottom of this file).
@immutable
class FinColors extends ThemeExtension<FinColors> {
  const FinColors({
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.border,
    required this.text,
    required this.textMuted,
    required this.green,
    required this.greenSoft,
    required this.coral,
    required this.coralSoft,
    required this.red,
    required this.redSoft,
    required this.pink,
    required this.shadow,
  });

  final Color background; // behind everything
  final Color surface; // cards
  final Color surfaceAlt; // chips, input backgrounds, tracks of progress bars
  final Color border;
  final Color text;
  final Color textMuted;
  final Color green;
  final Color greenSoft;
  final Color coral;
  final Color coralSoft;
  final Color red;
  final Color redSoft;
  final Color pink;
  final Color shadow;

  static const light = FinColors(
    background: Palette.blush,
    surface: Colors.white,
    surfaceAlt: Color(0xFFF7F1F2),
    border: Color(0xFFE8DCDF),
    text: Color(0xFF1B2624),
    textMuted: Color(0xFF6D7472),
    green: Palette.green,
    greenSoft: Color(0xFFE1EFEB),
    coral: Palette.coral,
    coralSoft: Color(0xFFFFEAE5),
    red: Palette.red,
    redSoft: Color(0xFFFBE4E6),
    pink: Palette.pink,
    shadow: Color(0x14005B4C), // green-tinted shadow, 8% opacity
  );

  static const dark = FinColors(
    background: Color(0xFF101614),
    surface: Color(0xFF19211F),
    surfaceAlt: Color(0xFF222C29),
    border: Color(0xFF2C3835),
    text: Color(0xFFF1ECEC),
    textMuted: Color(0xFFA2ABA8),
    green: Color(0xFF3FB39C), // brighter green so it is readable on dark
    greenSoft: Color(0xFF16322C),
    coral: Palette.coral,
    coralSoft: Color(0xFF3A2621),
    red: Color(0xFFF06A72),
    redSoft: Color(0xFF3A1F22),
    pink: Palette.pink,
    shadow: Color(0x33000000),
  );

  /// Required by ThemeExtension: make a copy with some values changed.
  @override
  FinColors copyWith({Color? background, Color? surface, Color? text}) {
    return FinColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceAlt: surfaceAlt,
      border: border,
      text: text ?? this.text,
      textMuted: textMuted,
      green: green,
      greenSoft: greenSoft,
      coral: coral,
      coralSoft: coralSoft,
      red: red,
      redSoft: redSoft,
      pink: pink,
      shadow: shadow,
    );
  }

  /// Required by ThemeExtension: blend between two themes (used when the
  /// phone switches between light and dark mode, so colours fade smoothly).
  @override
  FinColors lerp(FinColors? other, double t) {
    if (other == null) {
      return this;
    }
    return FinColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      border: Color.lerp(border, other.border, t)!,
      text: Color.lerp(text, other.text, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      green: Color.lerp(green, other.green, t)!,
      greenSoft: Color.lerp(greenSoft, other.greenSoft, t)!,
      coral: Color.lerp(coral, other.coral, t)!,
      coralSoft: Color.lerp(coralSoft, other.coralSoft, t)!,
      red: Color.lerp(red, other.red, t)!,
      redSoft: Color.lerp(redSoft, other.redSoft, t)!,
      pink: Color.lerp(pink, other.pink, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}

/// Shortcut so widgets can write `context.fin.green` instead of the long
/// `Theme.of(context).extension<FinColors>()!.green`.
extension FinColorsContext on BuildContext {
  FinColors get fin => Theme.of(this).extension<FinColors>()!;
}

/// Builds the full Material theme for light or dark mode.
class AppTheme {
  AppTheme._();

  /// Be Vietnam Pro was designed for Vietnamese: its accent marks
  /// (ă, ơ, ư, ệ ...) sit perfectly, which many Latin fonts get wrong.
  static const fontFamily = 'BeVietnamPro';

  static ThemeData light() => _build(Brightness.light, FinColors.light);

  static ThemeData dark() => _build(Brightness.dark, FinColors.dark);

  static ThemeData _build(Brightness brightness, FinColors colors) {
    final scheme = ColorScheme.fromSeed(
      seedColor: Palette.green,
      brightness: brightness,
      primary: colors.green,
      secondary: colors.coral,
      error: colors.red,
      surface: colors.surface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: colors.background,
      extensions: [colors],
      textTheme: _textTheme(colors),
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        foregroundColor: colors.text,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: colors.text,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: colors.greenSoft,
        elevation: 0,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontFamily: fontFamily,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? colors.green : colors.textMuted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(color: selected ? colors.green : colors.textMuted);
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceAlt,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Gaps.radiusSm),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Gaps.radiusSm),
          borderSide: BorderSide(color: colors.green, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Gaps.radiusSm),
          borderSide: BorderSide(color: colors.red, width: 1.2),
        ),
        hintStyle: TextStyle(color: colors.textMuted),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colors.text,
        contentTextStyle: TextStyle(fontFamily: fontFamily, color: colors.surface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Gaps.radiusSm)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(Gaps.radiusLg)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Gaps.radius)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.surfaceAlt,
        selectedColor: colors.greenSoft,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        labelStyle: TextStyle(fontFamily: fontFamily, color: colors.text, fontSize: 13),
      ),
      dividerTheme: DividerThemeData(color: colors.border, thickness: 1, space: 1),
    );
  }

  /// Typographic hierarchy: one clear size per role.
  static TextTheme _textTheme(FinColors c) {
    return TextTheme(
      displaySmall: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: c.text, height: 1.1, letterSpacing: -0.8),
      headlineMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: c.text, height: 1.2, letterSpacing: -0.4),
      headlineSmall: TextStyle(fontSize: 21, fontWeight: FontWeight.w700, color: c.text, height: 1.25),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: c.text),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: c.text),
      titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.text),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: c.text, height: 1.55),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: c.text, height: 1.5),
      bodySmall: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w400, color: c.textMuted, height: 1.4),
      labelLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: c.text),
      labelMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: c.textMuted),
      labelSmall: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: c.textMuted, letterSpacing: 0.4),
    );
  }
}
