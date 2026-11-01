import 'package:flutter/material.dart';

/// Shared palette for the TERM light design system.
class AppColors {
  AppColors._();

  static const primary = Color(0xFF0067FF);
  static const primaryContainer = Color(0xFFDCEBFF);
  static const darkBlue = Color(0xFF003DA5);
  static const background = Color(0xFFF0F5FE);
  static const surface = Color(0xFFFFFFFF);
  static const primaryText = Color(0xFF101A3A);
  static const secondaryText = Color(0xFF354A76);
  static const border = Color(0xFFDCE6F7);

  static const success = Color(0xFF16A765);
  static const warning = Color(0xFFFF981F);
  static const error = Color(0xFFE5484D);
}

/// Layout spacing in Flutter logical pixels.
class AppSpacing {
  AppSpacing._();

  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
}

/// Shared corner radii in Flutter logical pixels.
class AppRadii {
  AppRadii._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 28;
  static const double pill = 999;
}
