import 'package:flutter/material.dart';

/// GreaseTrail — garage layout. Beige ground, white cards, rust alerts.
class AppColors {
  AppColors._();

  static const bg = Color(0xFFF5F3EF);
  static const card = Color(0xFFFFFFFF);
  static const ink = Color(0xFF1A1A1A);
  static const muted = Color(0xFFA0A0A0);
  static const faint = Color(0xFFC4C0BA);
  static const hairline = Color(0xFFE6E3DE);
  static const rule = Color(0xFF2C2C2C);
  static const accent = Color(0xFFA65D46);
  static const soon = Color(0xFF6B6058);
  static const iconBg = Color(0xFF1A1A1A);
  static const iconFg = Color(0xFFFFFFFF);
  static const tabOff = Color(0xFFB3AEA8);
}

enum DueLevel { overdue, soon, ok, none }

Color? dotColor(DueLevel level) {
  switch (level) {
    case DueLevel.overdue:
      return AppColors.accent;
    case DueLevel.soon:
      return AppColors.soon;
    case DueLevel.ok:
    case DueLevel.none:
      return null;
  }
}

class AppTypography {
  AppTypography._();

  static const odometer = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w300,
    letterSpacing: -1.6,
    fontFeatures: [FontFeature.tabularFigures()],
  );
  static const title = TextStyle(fontSize: 34, fontWeight: FontWeight.w700, letterSpacing: -0.6);
  static const name = TextStyle(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.4);
  static const row = TextStyle(fontSize: 16, fontWeight: FontWeight.w400);
  static const body = TextStyle(fontSize: 15, fontWeight: FontWeight.w400);
  static const meta = TextStyle(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4);
  static const small = TextStyle(fontSize: 12, fontWeight: FontWeight.w400);
  static const label = TextStyle(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 1.4);
  static const date = TextStyle(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 1.6);
}

/// Text helpers that apply the uppercase transform baked into some styles above
/// (mirrors CSS `textTransform: uppercase` from the original React Native styles).
class AppText {
  AppText._();

  static Text odometer(String text, {Color? color}) =>
      Text(text, style: AppTypography.odometer.copyWith(color: color));

  static Text title(String text, {Color? color}) => Text(text, style: AppTypography.title.copyWith(color: color));

  static Text name(String text, {Color? color, int? maxLines}) => Text(
        text.toUpperCase(),
        style: AppTypography.name.copyWith(color: color),
        maxLines: maxLines,
        overflow: maxLines != null ? TextOverflow.ellipsis : null,
      );

  static Text row(String text, {Color? color, TextAlign? textAlign}) =>
      Text(text, style: AppTypography.row.copyWith(color: color), textAlign: textAlign);

  static Text body(String text, {Color? color, FontWeight? fontWeight}) =>
      Text(text, style: AppTypography.body.copyWith(color: color, fontWeight: fontWeight));

  static Text meta(String text, {Color? color, double? letterSpacing}) => Text(
        text.toUpperCase(),
        style: AppTypography.meta.copyWith(color: color, letterSpacing: letterSpacing),
      );

  static Text small(String text, {Color? color, double? letterSpacing, bool upper = false}) => Text(
        upper ? text.toUpperCase() : text,
        style: AppTypography.small.copyWith(color: color, letterSpacing: letterSpacing),
      );

  static Text label(String text, {Color? color}) =>
      Text(text.toUpperCase(), style: AppTypography.label.copyWith(color: color));

  static Text date(String text, {Color? color}) =>
      Text(text.toUpperCase(), style: AppTypography.date.copyWith(color: color));
}

class AppSpace {
  AppSpace._();

  static const side = 22.0;
  static const rowY = 16.0;
  static const fieldY = 14.0;
  static const block = 28.0;
  static const hairline = 1.0;
  static const radius = 16.0;
}
