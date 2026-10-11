import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:purrfile/theme/app_theme.dart';

/// WCAG contrast ratio between two colors (1.0 = identical, 21.0 = black on
/// white). AA needs 4.5 for normal text and 3.0 for icons / UI borders.
double contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final lighter = la > lb ? la : lb;
  final darker = la > lb ? lb : la;
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  const s = AppTheme.lightScheme;
  const p = PurrColors.light;

  group('Text contrast is WCAG AA (4.5:1)', () {
    final textPairs = <String, List<Color>>{
      'onPrimary on primary': [s.onPrimary, s.primary],
      'onSurface on page': [s.onSurface, s.surfaceContainerLowest],
      'onSurface on card': [s.onSurface, s.surface],
      'muted text on page': [s.onSurfaceVariant, s.surfaceContainerLowest],
      'muted text on card': [s.onSurfaceVariant, s.surface],
      'onSecondary on sage': [s.onSecondary, s.secondary],
      'onTertiary on sand': [s.onTertiary, s.tertiary],
      'onError on error': [s.onError, s.error],
      'onErrorContainer on errorContainer': [
        s.onErrorContainer,
        s.errorContainer
      ],
      'onPrimaryContainer on primaryContainer': [
        s.onPrimaryContainer,
        s.primaryContainer
      ],
      'primary text on page': [s.primary, s.surfaceContainerLowest],
      'snackbar text': [s.onInverseSurface, s.inverseSurface],
      'snackbar action': [s.inversePrimary, s.inverseSurface],
    };
    textPairs.forEach((name, c) {
      test(name, () => expect(contrast(c[0], c[1]), greaterThanOrEqualTo(4.5)));
    });
  });

  group('Badge / tone text contrast is AA (4.5:1)', () {
    final tones = <String, PurrTone>{
      'vaccination': p.vaccination,
      'vetVisit': p.vetVisit,
      'weight': p.weight,
      'illness': p.illness,
      'other': p.other,
      'overdue': p.overdue,
      'upcoming': p.upcoming,
      'done': p.done,
      'accent': p.accent,
    };
    tones.forEach((name, t) {
      test(name, () {
        expect(
            contrast(t.onContainer, t.container), greaterThanOrEqualTo(4.5));
      });
    });
  });

  group('Hero gradient keeps white text readable', () {
    final g = s.heroGradient;
    for (var i = 0; i < g.colors.length; i++) {
      test('white on gradient stop $i', () {
        expect(contrast(s.onPrimary, g.colors[i]), greaterThanOrEqualTo(4.5));
      });
      test('white on translucent dark pill over stop $i', () {
        final pill = Color.alphaBlend(
            s.onSurface.withValues(alpha: 0.28), g.colors[i]);
        expect(contrast(s.onPrimary, pill), greaterThanOrEqualTo(4.5));
      });
    }
  });

  group('Icons, dots and borders are visible (3:1)', () {
    final tones = <String, PurrTone>{
      'vaccination': p.vaccination,
      'vetVisit': p.vetVisit,
      'weight': p.weight,
      'illness': p.illness,
      'other': p.other,
      'overdue': p.overdue,
      'upcoming': p.upcoming,
      'done': p.done,
      'accent': p.accent,
    };
    tones.forEach((name, t) {
      test('$name color on page', () {
        expect(contrast(t.color, s.surfaceContainerLowest),
            greaterThanOrEqualTo(3.0));
      });
    });
    test('input border on card', () {
      expect(contrast(s.outline, s.surface), greaterThanOrEqualTo(3.0));
    });
    test('input border on page', () {
      expect(contrast(s.outline, s.surfaceContainerLowest),
          greaterThanOrEqualTo(3.0));
    });
  });
}
