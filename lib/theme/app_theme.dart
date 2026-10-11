import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/app_spacing.dart';

/// PurrFile's design system.
///
/// Rules of thumb:
///  * Colors come from `Theme.of(context).colorScheme`, or from the extra
///    PurrFile colors via `context.purr` (see [PurrColors] below).
///  * Text styles come from `Theme.of(context).textTheme`.
///  * Spacing, radii and durations come from `app_spacing.dart`.
///
/// Dark mode is NOT built yet, but the theme is structured for it: everything
/// is assembled by [_buildTheme] from a [ColorScheme] plus a [PurrColors], so a
/// dark theme only needs a dark scheme and a dark [PurrColors].
class AppTheme {
  AppTheme._();

  /// Fully transparent. Used to switch off Material 3's automatic "surface
  /// tint" so our own warm shadows are what make cards look layered.
  static const Color _clear = Color(0x00000000);

  // ---------------------------------------------------------------------------
  // Colors
  // ---------------------------------------------------------------------------
  //
  // Same brand as before: dark green + sage + warm cream. Contrast ratios were
  // measured against WCAG AA (4.5:1 for text, 3:1 for icons and borders);
  // test/theme_contrast_test.dart keeps them honest.
  //
  // IMPORTANT: sage (`secondary`, #8FAF8A) is only ~2.2:1 on cream, so it is
  // for FILLS only (avatars, badges, indicators). For sage-colored TEXT or
  // ICONS on cream, use `context.purr.done.color` (a darker sage, ~5:1).
  static const ColorScheme lightScheme = ColorScheme(
    brightness: Brightness.light,

    // Brand dark green.
    primary: Color(0xFF2F5D50),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFDCE8D8), // soft sage tint
    onPrimaryContainer: Color(0xFF1F3F35),

    // Sage green (fills only, see note above).
    secondary: Color(0xFF8FAF8A),
    onSecondary: Color(0xFF1F2E27),
    secondaryContainer: Color(0xFFEAF0E6),
    onSecondaryContainer: Color(0xFF24503B),

    // Warm sand / beige.
    tertiary: Color(0xFFE8DCC8),
    onTertiary: Color(0xFF5C4A2F),
    tertiaryContainer: Color(0xFFF3EEE4),
    onTertiaryContainer: Color(0xFF5C4A2F),

    // Warm red (was #C1584F: white text on it was 4.4:1, just under AA).
    error: Color(0xFFB3443B),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFF8E1DD),
    onErrorContainer: Color(0xFF8A2F28),

    // Surfaces: white cards on a cream page.
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF1F2E27),
    onSurfaceVariant: Color(0xFF5A6B62), // muted text (5.2:1 on cream)
    surfaceContainerLowest: Color(0xFFF8F6F2), // the cream page background
    surfaceContainerLow: Color(0xFFF4F0E8),
    surfaceContainer: Color(0xFFF0EBE1),
    surfaceContainerHigh: Color(0xFFEBE5D9),
    surfaceContainerHighest: Color(0xFFE6DFD2),
    surfaceDim: Color(0xFFE0D9CC),
    surfaceBright: Color(0xFFFFFFFF),
    surfaceTint: _clear,

    // Lines. `outline` is strong enough for input borders (3:1);
    // `outlineVariant` is the soft hairline for cards and dividers.
    outline: Color(0xFF7E8F85),
    outlineVariant: Color(0xFFE3DCCF),

    // Warm brown-tinted shadows instead of cold gray ones.
    shadow: Color(0xFF3A2F1E),
    scrim: Color(0xFF1F2E27),

    // Used by SnackBars.
    inverseSurface: Color(0xFF1F2E27),
    onInverseSurface: Color(0xFFF8F6F2),
    inversePrimary: Color(0xFF8FAF8A),
  );

  // ---------------------------------------------------------------------------
  // Text
  // ---------------------------------------------------------------------------
  //
  // Baloo 2 (rounded, friendly) for display / headline / titleLarge.
  // Inter (clean, readable) for everything else.
  static TextTheme _textTheme(ColorScheme scheme) {
    TextStyle baloo(double size, FontWeight weight, double height) =>
        GoogleFonts.baloo2(
          fontSize: size,
          fontWeight: weight,
          height: height,
          color: scheme.onSurface,
        );

    TextStyle inter(
      double size,
      FontWeight weight,
      double height, {
      Color? color,
      double letterSpacing = 0,
    }) =>
        GoogleFonts.inter(
          fontSize: size,
          fontWeight: weight,
          height: height,
          letterSpacing: letterSpacing,
          color: color ?? scheme.onSurface,
        );

    return TextTheme(
      // Display: big moments (greeting, empty states, cat name on profile).
      displayLarge: baloo(44, FontWeight.w700, 1.15),
      displayMedium: baloo(38, FontWeight.w700, 1.15),
      displaySmall: baloo(32, FontWeight.w700, 1.2),

      // Headline: screen and section titles.
      headlineLarge: baloo(30, FontWeight.w700, 1.2),
      headlineMedium: baloo(27, FontWeight.w700, 1.2),
      headlineSmall: baloo(24, FontWeight.w700, 1.25),

      // Title: card titles, list item titles, app bar.
      titleLarge: baloo(20, FontWeight.w700, 1.25),
      titleMedium: inter(16, FontWeight.w600, 1.4),
      titleSmall: inter(14, FontWeight.w600, 1.4, letterSpacing: 0.1),

      // Body: paragraphs and notes. bodySmall is the muted caption style.
      bodyLarge: inter(16, FontWeight.w400, 1.5),
      bodyMedium: inter(14, FontWeight.w400, 1.5),
      bodySmall:
          inter(12, FontWeight.w400, 1.4, color: scheme.onSurfaceVariant),

      // Label: buttons, chips, badges, nav labels.
      labelLarge: inter(16, FontWeight.w600, 1.25),
      labelMedium: inter(13, FontWeight.w600, 1.3, letterSpacing: 0.2),
      labelSmall: inter(12, FontWeight.w600, 1.3, letterSpacing: 0.2),
    );
  }

  // ---------------------------------------------------------------------------
  // Themes
  // ---------------------------------------------------------------------------

  static ThemeData get light => _buildTheme(lightScheme, PurrColors.light);

  // When dark mode is wanted later:
  //   static ThemeData get dark => _buildTheme(darkScheme, PurrColors.dark);
  // then add `darkTheme: AppTheme.dark` to MaterialApp in app.dart.

  static ThemeData _buildTheme(ColorScheme scheme, PurrColors purr) {
    final text = _textTheme(scheme);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surfaceContainerLowest,
      textTheme: text,
      extensions: [purr],

      // --- App bar -----------------------------------------------------------
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surfaceContainerLowest,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: _clear,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
      ),

      // --- Bottom navigation -------------------------------------------------
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: scheme.surface,
        surfaceTintColor: _clear,
        elevation: 3,
        shadowColor: scheme.shadow,
        indicatorColor: scheme.primaryContainer,
        indicatorShape: const StadiumBorder(),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return text.labelSmall?.copyWith(
            color: selected ? scheme.primary : scheme.onSurfaceVariant,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 24,
            color: selected ? scheme.primary : scheme.onSurfaceVariant,
          );
        }),
      ),

      // --- Floating action button -------------------------------------------
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 3,
        focusElevation: 4,
        hoverElevation: 4,
        highlightElevation: 2,
        shape: const StadiumBorder(),
        extendedTextStyle: text.labelLarge,
      ),

      // --- Cards: soft warm shadow + hairline border ------------------------
      cardTheme: CardThemeData(
        color: scheme.surface,
        surfaceTintColor: _clear,
        elevation: 2,
        shadowColor: scheme.shadow.withValues(alpha: 0.35),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.md,
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),

      // --- Chips -------------------------------------------------------------
      // Selected chips get a sage tint AND a check mark, so selection never
      // depends on color alone.
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surface,
        selectedColor: scheme.primaryContainer,
        disabledColor: scheme.surfaceContainer,
        labelStyle: text.labelMedium?.copyWith(color: scheme.onSurface),
        secondaryLabelStyle:
            text.labelMedium?.copyWith(color: scheme.onPrimaryContainer),
        iconTheme: IconThemeData(size: 18, color: scheme.onSurfaceVariant),
        checkmarkColor: scheme.primary,
        showCheckmark: true,
        side: BorderSide(color: scheme.outlineVariant),
        shape: const StadiumBorder(),
        elevation: 0,
        pressElevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.sm,
        ),
      ),

      // --- Text fields -------------------------------------------------------
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        labelStyle:
            text.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
        floatingLabelStyle: text.bodyLarge
            ?.copyWith(color: scheme.primary, fontWeight: FontWeight.w600),
        hintStyle: text.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
        helperStyle: text.bodySmall,
        errorStyle: text.bodySmall
            ?.copyWith(color: scheme.error, fontWeight: FontWeight.w500),
        errorMaxLines: 3,
        prefixIconColor: scheme.onSurfaceVariant,
        suffixIconColor: scheme.onSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: AppRadius.md,
          borderSide: BorderSide(color: scheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.md,
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.md,
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.md,
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.md,
          borderSide: BorderSide(color: scheme.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.md,
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: scheme.primary,
        selectionHandleColor: scheme.primary,
        selectionColor: scheme.primary.withValues(alpha: 0.25),
      ),

      // --- Buttons -----------------------------------------------------------
      // PrimaryButton uses ElevatedButton (full width), so it is styled to look
      // like the filled brand button.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          disabledBackgroundColor: scheme.onSurface.withValues(alpha: 0.12),
          disabledForegroundColor: scheme.onSurface.withValues(alpha: 0.38),
          elevation: 0,
          shadowColor: scheme.shadow,
          minimumSize: const Size.fromHeight(54),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          textStyle: text.labelLarge,
          shape: const StadiumBorder(),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size(64, AppSpacing.touchTarget),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          textStyle: text.labelLarge,
          shape: const StadiumBorder(),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          side: BorderSide(color: scheme.primary, width: 1.5),
          minimumSize: const Size(64, AppSpacing.touchTarget),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          textStyle: text.labelLarge,
          shape: const StadiumBorder(),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          minimumSize: const Size(64, AppSpacing.touchTarget),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          textStyle: text.labelLarge,
          shape: const StadiumBorder(),
        ),
      ),
      // Only size here: colors stay per-variant so IconButton.filled keeps its
      // own light-on-dark look.
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size.square(AppSpacing.touchTarget),
        ),
      ),

      // --- Dialogs, sheets, snackbars ---------------------------------------
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: _clear,
        elevation: 6,
        shadowColor: scheme.shadow,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.lg),
        titleTextStyle: text.titleLarge,
        contentTextStyle: text.bodyMedium,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: _clear,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle:
            text.bodyMedium?.copyWith(color: scheme.onInverseSurface),
        actionTextColor: scheme.inversePrimary,
        elevation: 3,
        insetPadding: const EdgeInsets.all(AppSpacing.md),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.sm),
      ),

      // --- Tabs --------------------------------------------------------------
      tabBarTheme: TabBarThemeData(
        labelColor: scheme.primary,
        unselectedLabelColor: scheme.onSurfaceVariant,
        labelStyle: text.titleSmall,
        unselectedLabelStyle: text.titleSmall,
        indicatorSize: TabBarIndicatorSize.label,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: scheme.primary, width: 3),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
        ),
        dividerColor: scheme.outlineVariant,
        overlayColor: WidgetStatePropertyAll(
          scheme.primary.withValues(alpha: 0.08),
        ),
      ),

      // --- Small details -----------------------------------------------------
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.primaryContainer,
      ),
    );
  }
}

// =============================================================================
// Extra PurrFile colors and shadows (a Flutter "ThemeExtension")
// =============================================================================
//
// Material's ColorScheme has no slot for "vaccination green" or "overdue red",
// so those live here. Read them anywhere with `context.purr`:
//
//   final purr = context.purr;
//   Container(
//     decoration: BoxDecoration(
//       color: purr.vaccination.container,
//       boxShadow: purr.shadowSoft,
//     ),
//   );

/// One color "family": a strong color, a soft tint, and readable text on it.
@immutable
class PurrTone {
  /// Strong color for dots, icons and borders (3:1 or better on cream).
  final Color color;

  /// Soft background tint, for badges and icon circles.
  final Color container;

  /// Text / icon color to put ON [container] (AA contrast, 4.5:1 or better).
  final Color onContainer;

  const PurrTone({
    required this.color,
    required this.container,
    required this.onContainer,
  });

  static PurrTone lerp(PurrTone a, PurrTone b, double t) => PurrTone(
        color: Color.lerp(a.color, b.color, t)!,
        container: Color.lerp(a.container, b.container, t)!,
        onContainer: Color.lerp(a.onContainer, b.onContainer, t)!,
      );
}

@immutable
class PurrColors extends ThemeExtension<PurrColors> {
  // One tone per health record type (timeline dots, icons, chips).
  final PurrTone vaccination;
  final PurrTone vetVisit;
  final PurrTone weight;
  final PurrTone illness;
  final PurrTone other;

  // Reminder statuses. Badges also use an icon + a word, never color alone.
  final PurrTone overdue; // warm red
  final PurrTone upcoming; // neutral sand
  final PurrTone done; // sage

  /// Warm terracotta accent for small highlights (use sparingly).
  final PurrTone accent;

  // Three levels of soft, warm shadow (use in BoxDecoration.boxShadow).
  final List<BoxShadow> shadowSoft; // resting cards
  final List<BoxShadow> shadowRaised; // pressed / hovered / featured cards
  final List<BoxShadow> shadowOverlay; // floating things (menus, sheets)

  const PurrColors({
    required this.vaccination,
    required this.vetVisit,
    required this.weight,
    required this.illness,
    required this.other,
    required this.overdue,
    required this.upcoming,
    required this.done,
    required this.accent,
    required this.shadowSoft,
    required this.shadowRaised,
    required this.shadowOverlay,
  });

  /// Light-theme values. A future `PurrColors.dark` goes right next to this.
  static const PurrColors light = PurrColors(
    vaccination: PurrTone(
      color: Color(0xFF2F5D50),
      container: Color(0xFFDCE8D8),
      onContainer: Color(0xFF1F4A3A),
    ),
    vetVisit: PurrTone(
      color: Color(0xFF3B7A8C),
      container: Color(0xFFDCEBEF),
      onContainer: Color(0xFF1F4F5E),
    ),
    weight: PurrTone(
      color: Color(0xFFC46A3C),
      container: Color(0xFFF6E3D6),
      onContainer: Color(0xFF7A3B1B),
    ),
    illness: PurrTone(
      color: Color(0xFFB3443B),
      container: Color(0xFFF8E1DD),
      onContainer: Color(0xFF8A2F28),
    ),
    other: PurrTone(
      color: Color(0xFF8A7355),
      container: Color(0xFFEFE6D3),
      onContainer: Color(0xFF5C4A2F),
    ),
    overdue: PurrTone(
      color: Color(0xFFB3443B),
      container: Color(0xFFF8E1DD),
      onContainer: Color(0xFF8A2F28),
    ),
    upcoming: PurrTone(
      color: Color(0xFF8A7355),
      container: Color(0xFFEFE6D3),
      onContainer: Color(0xFF5C4A2F),
    ),
    done: PurrTone(
      color: Color(0xFF4B7451),
      container: Color(0xFFDCE8D8),
      onContainer: Color(0xFF24503B),
    ),
    accent: PurrTone(
      color: Color(0xFFC46A3C),
      container: Color(0xFFF6E3D6),
      onContainer: Color(0xFF7A3B1B),
    ),
    shadowSoft: [
      BoxShadow(
        color: Color(0x0F3A2F1E),
        blurRadius: 2,
        offset: Offset(0, 1),
      ),
      BoxShadow(
        color: Color(0x143A2F1E),
        blurRadius: 14,
        offset: Offset(0, 4),
      ),
    ],
    shadowRaised: [
      BoxShadow(
        color: Color(0x143A2F1E),
        blurRadius: 4,
        offset: Offset(0, 2),
      ),
      BoxShadow(
        color: Color(0x1F3A2F1E),
        blurRadius: 24,
        offset: Offset(0, 10),
      ),
    ],
    shadowOverlay: [
      BoxShadow(
        color: Color(0x1A3A2F1E),
        blurRadius: 6,
        offset: Offset(0, 3),
      ),
      BoxShadow(
        color: Color(0x2E3A2F1E),
        blurRadius: 36,
        offset: Offset(0, 14),
      ),
    ],
  );

  @override
  PurrColors copyWith({
    PurrTone? vaccination,
    PurrTone? vetVisit,
    PurrTone? weight,
    PurrTone? illness,
    PurrTone? other,
    PurrTone? overdue,
    PurrTone? upcoming,
    PurrTone? done,
    PurrTone? accent,
    List<BoxShadow>? shadowSoft,
    List<BoxShadow>? shadowRaised,
    List<BoxShadow>? shadowOverlay,
  }) {
    return PurrColors(
      vaccination: vaccination ?? this.vaccination,
      vetVisit: vetVisit ?? this.vetVisit,
      weight: weight ?? this.weight,
      illness: illness ?? this.illness,
      other: other ?? this.other,
      overdue: overdue ?? this.overdue,
      upcoming: upcoming ?? this.upcoming,
      done: done ?? this.done,
      accent: accent ?? this.accent,
      shadowSoft: shadowSoft ?? this.shadowSoft,
      shadowRaised: shadowRaised ?? this.shadowRaised,
      shadowOverlay: shadowOverlay ?? this.shadowOverlay,
    );
  }

  @override
  PurrColors lerp(ThemeExtension<PurrColors>? other, double t) {
    if (other is! PurrColors) return this;
    return PurrColors(
      vaccination: PurrTone.lerp(vaccination, other.vaccination, t),
      vetVisit: PurrTone.lerp(vetVisit, other.vetVisit, t),
      weight: PurrTone.lerp(weight, other.weight, t),
      illness: PurrTone.lerp(illness, other.illness, t),
      other: PurrTone.lerp(this.other, other.other, t),
      overdue: PurrTone.lerp(overdue, other.overdue, t),
      upcoming: PurrTone.lerp(upcoming, other.upcoming, t),
      done: PurrTone.lerp(done, other.done, t),
      accent: PurrTone.lerp(accent, other.accent, t),
      shadowSoft: BoxShadow.lerpList(shadowSoft, other.shadowSoft, t)!,
      shadowRaised: BoxShadow.lerpList(shadowRaised, other.shadowRaised, t)!,
      shadowOverlay:
          BoxShadow.lerpList(shadowOverlay, other.shadowOverlay, t)!,
    );
  }
}

/// Brand gradient for hero surfaces (login header, cat profile header).
/// White text on every stop is >= 6:1.
extension PurrGradients on ColorScheme {
  LinearGradient get heroGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(primary, secondary, 0.15)!,
          Color.lerp(primary, onSurface, 0.35)!,
        ],
      );
}

/// Shortcut: `context.purr` instead of
/// `Theme.of(context).extension<PurrColors>()!`.
extension PurrThemeContext on BuildContext {
  PurrColors get purr => Theme.of(this).extension<PurrColors>()!;
}
