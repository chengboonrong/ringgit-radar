import 'package:flutter/material.dart';

/// Our own red. Close to a console red but deliberately not Nintendo's.
const brandRed = Color(0xFFC8102E);
const saleRedOnDark = Color(0xFFFF7A8A);
const amber = Color(0xFFFFAC00);
const green = Color(0xFF72B814);
const nearBlack = Color(0xFF121212);

const ringColors = [
  Color(0xFF056FEE),
  Color(0xFF89CBFC),
  Color(0xFFB3A4F9),
  Color(0xFFFFC6DC),
  Color(0xFFFDD7CB),
];

const fontFamily = 'MPlusRounded1c';

@immutable
class Tokens extends ThemeExtension<Tokens> {
  const Tokens({
    required this.sidebar,
    required this.content,
    required this.card,
    required this.text,
    required this.hint,
    required this.divider,
    required this.skeleton,
    required this.skeletonPill,
    required this.saleText,
    required this.isDark,
  });

  final Color sidebar;
  final Color content;
  final Color card;
  final Color text;
  final Color hint;
  final Color divider;
  final Color skeleton;
  final Color skeletonPill;
  final Color saleText;
  final bool isDark;

  static const light = Tokens(
    sidebar: Color(0xFFF1F1F1),
    content: Color(0xFFEAEAEA),
    card: Color(0xFFF9F9F9),
    text: Color(0xFF121212),
    hint: Color(0xFF5F5E5D),
    divider: Color(0xFFC9C9C9),
    skeleton: Color(0xFFD7D7D7),
    skeletonPill: Color(0xFFD7D7D7),
    saleText: brandRed,
    isDark: false,
  );

  static const dark = Tokens(
    sidebar: Color(0xFF1F211E),
    content: Color(0xFF171916),
    card: Color(0xFF2E302D),
    text: Color(0xFFFFFFFF),
    hint: Color(0xFFABACAA),
    divider: Color(0xFF3F413E),
    skeleton: Color(0xFF3A3C39),
    skeletonPill: Color(0xFF272926),
    saleText: saleRedOnDark,
    isDark: true,
  );

  @override
  Tokens copyWith() => this;

  @override
  Tokens lerp(Tokens? other, double t) => t < 0.5 ? this : (other ?? this);
}

extension TokensX on BuildContext {
  Tokens get tokens => Theme.of(this).extension<Tokens>()!;
}

ThemeData buildTheme(Brightness brightness) {
  final t = brightness == Brightness.dark ? Tokens.dark : Tokens.light;
  final scheme = ColorScheme.fromSeed(seedColor: brandRed, brightness: brightness).copyWith(
    primary: brandRed,
    onPrimary: Colors.white,
    surface: t.card,
    onSurface: t.text,
    error: brandRed,
  );
  TextStyle s(double size, FontWeight w, {Color? color, double? height}) =>
      // -0.02em, so text reads a little tighter than the font's own spacing. Digits keep their equal widths.
      TextStyle(fontFamily: fontFamily, fontSize: size, fontWeight: w, color: color ?? t.text, height: height, letterSpacing: -size * 0.02);
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    fontFamily: fontFamily,
    scaffoldBackgroundColor: t.content,
    canvasColor: t.content,
    dividerColor: t.divider,
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    extensions: [t],
    textTheme: TextTheme(
      displaySmall: s(28, FontWeight.w700, height: 1.2),
      headlineSmall: s(22, FontWeight.w700, height: 1.25),
      titleLarge: s(20, FontWeight.w700, height: 1.25),
      titleMedium: s(16, FontWeight.w700, height: 1.3),
      titleSmall: s(14, FontWeight.w500, height: 1.3),
      bodyLarge: s(16, FontWeight.w400, height: 1.5),
      bodyMedium: s(14, FontWeight.w400, height: 1.5),
      bodySmall: s(12, FontWeight.w400, color: t.hint, height: 1.4),
      labelLarge: s(14, FontWeight.w700),
      labelMedium: s(12, FontWeight.w500),
      labelSmall: s(11, FontWeight.w500),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((st) => st.contains(WidgetState.selected) ? brandRed : Colors.transparent),
      checkColor: const WidgetStatePropertyAll(Colors.white),
      side: BorderSide(color: t.hint, width: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: const WidgetStatePropertyAll(Colors.white),
      trackColor: WidgetStateProperty.resolveWith((st) => st.contains(WidgetState.selected) ? brandRed : t.hint),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: brandRed,
      selectionColor: brandRed.withValues(alpha: 0.28),
      selectionHandleColor: brandRed,
    ),
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: WidgetStatePropertyAll(t.hint.withValues(alpha: 0.5)),
      radius: const Radius.circular(4),
      thickness: const WidgetStatePropertyAll(6),
    ),
  );
}
