import 'package:flutter/widgets.dart';

/// Shared layout tokens for PurrFile, based on an 8px unit.
/// Always reference these constants instead of hardcoding padding, gaps,
/// corner radii or animation durations inside widgets.

/// Spacing scale (padding, margins, gaps).
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  /// Minimum size for anything tappable (Material / WCAG touch target).
  static const double touchTarget = 48;

  /// Widest a screen's content may grow on web / tablet. Phones are narrower
  /// than this, so they are unaffected.
  static const double maxContentWidth = 640;

  /// Extra bottom padding for scrolling lists so the floating action button
  /// never covers the last item.
  static const double fabClearance = 96;

  /// Standard horizontal screen padding used on every screen.
  static const EdgeInsetsGeometry screenPadding =
      EdgeInsets.symmetric(horizontal: md);
}

/// Corner radius tokens. Use as `borderRadius: AppRadius.md`.
class AppRadius {
  AppRadius._();

  /// Small details: badges, small tiles.
  static const BorderRadius xs = BorderRadius.all(Radius.circular(8));

  /// Inputs and buttons.
  static const BorderRadius sm = BorderRadius.all(Radius.circular(12));

  /// Cards.
  static const BorderRadius md = BorderRadius.all(Radius.circular(16));

  /// Dialogs, bottom sheets, hero headers.
  static const BorderRadius lg = BorderRadius.all(Radius.circular(24));

  /// Hero headers and the floating nav bar.
  static const BorderRadius xl = BorderRadius.all(Radius.circular(28));

  /// Fully rounded: chips, badges, pills.
  static const BorderRadius pill = BorderRadius.all(Radius.circular(999));
}

/// Animation timing tokens, so every micro-interaction feels the same.
class AppMotion {
  AppMotion._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);

  static const Curve curve = Curves.easeOutCubic;
}
