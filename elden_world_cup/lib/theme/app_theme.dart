import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF15100C);
  static const surface = Color(0xFF1A1410);
  static const surfaceAlt = Color(0xFF221A12);
  static const gold = Color(0xFFD4AF37);
  static const goldLight = Color(0xFFF0D98A);
  static const border = Color(0xFF3A2F22);
  static const textMuted = Color(0xFF8A7A5C);
  static const textBody = Color(0xFFA89876);
  static const strong = Color(0xFF7FB38A);
  static const weak = Color(0xFFCF8A6A);

  /// Warm accent for defeated main bosses (border, name, pulse glow).
  static const mainAccent = Color(0xFFE2483D);
}

class AppText {
  static const title = TextStyle(
      color: AppColors.gold, fontSize: 20, fontWeight: FontWeight.w800);
  static const regionLabel = TextStyle(
      color: Color(0xFFC9B78F), fontSize: 13, fontWeight: FontWeight.w700,
      letterSpacing: 1, height: 1);
  static const sectionLabel = TextStyle(
      color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w800,
      letterSpacing: 1.2);
  static const lore = TextStyle(
      color: AppColors.textBody, fontSize: 13, height: 1.65);
  static const slotName = TextStyle(
      color: AppColors.goldLight, fontSize: 9, fontWeight: FontWeight.w800,
      letterSpacing: .3);
}
