import 'package:flutter/material.dart';

/// GreaseTrail — warm shop-ledger look. Cream field, white cards, terracotta for what's due.
class AppColors {
  final Color bg;
  final Color surface;
  final Color card;
  final Color ink;
  final Color muted;
  final Color faint;
  final Color hairline;
  final Color border;
  final Color accent;
  final Color soon;
  final Color alert;
  final Color iconBg;
  final Color iconFg;
  final Color photo;
  final Color dotOff;

  const AppColors({
    required this.bg,
    required this.surface,
    required this.card,
    required this.ink,
    required this.muted,
    required this.faint,
    required this.hairline,
    required this.border,
    required this.accent,
    required this.soon,
    required this.alert,
    required this.iconBg,
    required this.iconFg,
    required this.photo,
    required this.dotOff,
  });

  static const light = AppColors(
    bg: Color(0xFFF5F5F0),
    surface: Color(0xFFE8E6E0),
    card: Color(0xFFFFFFFF),
    ink: Color(0xFF1A1A1A),
    muted: Color(0xFF8A8A84),
    faint: Color(0xFFB4B4AE),
    hairline: Color(0xFFE4E2DC),
    border: Color(0xFFD0CEC8),
    accent: Color(0xFF9E5E3D),
    soon: Color(0xFF8A7A70),
    alert: Color(0xFF9E5E3D),
    iconBg: Color(0xFF1A1A1A),
    iconFg: Color(0xFFFFFFFF),
    photo: Color(0xFFEDEBE6),
    dotOff: Color(0xFFD6D4CE),
  );

  static const dark = AppColors(
    bg: Color(0xFF161614),
    surface: Color(0xFF1C1C19),
    card: Color(0xFF242422),
    ink: Color(0xFFF0EFEA),
    muted: Color(0xFF8A8A82),
    faint: Color(0xFF5C5C56),
    hairline: Color(0xFF33332E),
    border: Color(0xFF3A3A35),
    accent: Color(0xFFC17A56),
    soon: Color(0xFFA09086),
    alert: Color(0xFFC17A56),
    iconBg: Color(0xFF1A1A1A),
    iconFg: Color(0xFFFFFFFF),
    photo: Color(0xFF2A2A26),
    dotOff: Color(0xFF4A4A44),
  );

  static AppColors of(BuildContext context) {
    final base = Theme.of(context).brightness == Brightness.dark ? dark : light;
    final override = AccentScope.maybeOf(context);
    return override != null ? base.copyWith(accent: override) : base;
  }

  AppColors copyWith({Color? accent}) => AppColors(
        bg: bg,
        surface: surface,
        card: card,
        ink: ink,
        muted: muted,
        faint: faint,
        hairline: hairline,
        border: border,
        accent: accent ?? this.accent,
        soon: soon,
        alert: alert,
        iconBg: iconBg,
        iconFg: iconFg,
        photo: photo,
        dotOff: dotOff,
      );
}

/// Provides an app-wide accent color override (from the user's Setup choice)
/// to every [AppColors.of] call below it in the tree. `null` means "use the
/// palette's built-in default".
class AccentScope extends InheritedWidget {
  final Color? accent;
  const AccentScope({super.key, required this.accent, required super.child});

  static Color? maybeOf(BuildContext context) => context.dependOnInheritedWidgetOfExactType<AccentScope>()?.accent;

  @override
  bool updateShouldNotify(AccentScope oldWidget) => oldWidget.accent != accent;
}

/// Curated accent choices offered by the app-wide and per-vehicle color
/// pickers. The first entry is the app's built-in default.
const List<Color> accentSwatches = [
  Color(0xFF9E5E3D), // terracotta (default)
  Color(0xFFB2452F), // rust red
  Color(0xFFB8862F), // mustard
  Color(0xFF4C7A4A), // forest green
  Color(0xFF2F7A6E), // teal
  Color(0xFF3C6E91), // ocean blue
  Color(0xFF5B5FA8), // indigo
  Color(0xFF8A4B8C), // plum
  Color(0xFF6B6B66), // stone gray
];

enum DueLevel { overdue, soon, ok }

Decoration dotDecoration(DueLevel level, AppColors c) {
  switch (level) {
    case DueLevel.overdue:
      return BoxDecoration(shape: BoxShape.circle, color: c.accent);
    case DueLevel.soon:
      return BoxDecoration(shape: BoxShape.circle, color: c.soon);
    case DueLevel.ok:
      return BoxDecoration(shape: BoxShape.circle, border: Border.all(color: c.dotOff));
  }
}

class AppTypography {
  AppTypography._();

  static const display = TextStyle(fontSize: 34, fontWeight: FontWeight.w700, letterSpacing: 0.4);
  static const odometer = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w300,
    letterSpacing: -1.4,
    fontFeatures: [FontFeature.tabularFigures()],
  );
  static const title = TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.3);
  static const category = TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
  static const row = TextStyle(fontSize: 16, fontWeight: FontWeight.w400);
  static const body = TextStyle(fontSize: 15, fontWeight: FontWeight.w400);
  static const meta = TextStyle(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.9);
  static const small = TextStyle(fontSize: 13, fontWeight: FontWeight.w400);
  static const label = TextStyle(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 1.4);
  static const date = TextStyle(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 1.1);
  static const tab = TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.9);
}

/// Text helpers that apply the uppercase transform baked into some styles above
/// (mirrors CSS `textTransform: uppercase` from the original React Native styles).
class AppText {
  AppText._();

  static Text display(String text, {Color? color}) =>
      Text(text.toUpperCase(), style: AppTypography.display.copyWith(color: color));

  static Text odometer(String text, {Color? color}) =>
      Text(text, style: AppTypography.odometer.copyWith(color: color));

  static Text title(String text, {Color? color, int? maxLines}) => Text(
        text.toUpperCase(),
        style: AppTypography.title.copyWith(color: color),
        maxLines: maxLines,
        overflow: maxLines != null ? TextOverflow.ellipsis : null,
      );

  static Text category(String text, {Color? color}) => Text(text, style: AppTypography.category.copyWith(color: color));

  static Text row(String text, {Color? color}) => Text(text, style: AppTypography.row.copyWith(color: color));

  static Text body(String text, {Color? color, FontWeight? fontWeight}) =>
      Text(text, style: AppTypography.body.copyWith(color: color, fontWeight: fontWeight));

  static Text meta(String text, {Color? color}) =>
      Text(text.toUpperCase(), style: AppTypography.meta.copyWith(color: color));

  static Text small(String text, {Color? color}) => Text(text, style: AppTypography.small.copyWith(color: color));

  static Text label(String text, {Color? color, double? letterSpacing}) => Text(
        text.toUpperCase(),
        style: AppTypography.label.copyWith(color: color, letterSpacing: letterSpacing),
      );

  static Text date(String text, {Color? color}) =>
      Text(text.toUpperCase(), style: AppTypography.date.copyWith(color: color));

  static Text tab(String text, {Color? color}) =>
      Text(text.toUpperCase(), style: AppTypography.tab.copyWith(color: color));
}

class AppSpace {
  AppSpace._();

  static const side = 20.0;
  static const rowY = 14.0;
  static const fieldY = 14.0;
  static const block = 28.0;
  static const cardPad = 16.0;
  static const radius = 16.0;
  static const hairline = 1.0;
}
