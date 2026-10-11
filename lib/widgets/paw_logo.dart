import 'package:flutter/material.dart';

/// The PurrFile mark: a paw whose main pad holds a little cat face.
/// Drawn in code (no image file), so it stays sharp at any size and can be
/// recoloured: green on cream, white on the green login header.
class PawMarkPainter extends CustomPainter {
  /// Paw (toes + pad) colour.
  final Color color;

  /// Cat-face colour (the "cut-out" inside the pad).
  final Color faceColor;

  const PawMarkPainter({required this.color, required this.faceColor});

  @override
  void paint(Canvas canvas, Size size) {
    // Everything below is drawn on a 100 x 100 grid.
    canvas.save();
    canvas.scale(size.shortestSide / 100);

    final paw = Paint()
      ..color = color
      ..isAntiAlias = true;
    final face = Paint()
      ..color = faceColor
      ..isAntiAlias = true;

    void oval(double cx, double cy, double w, double h, double rot, Paint p) {
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(rot);
      canvas.drawOval(
          Rect.fromCenter(center: Offset.zero, width: w, height: h), p);
      canvas.restore();
    }

    // Four toes.
    oval(16, 47, 14, 20, -0.5, paw);
    oval(36, 25, 16, 23, -0.2, paw);
    oval(64, 25, 16, 23, 0.2, paw);
    oval(84, 47, 14, 20, 0.5, paw);

    // Main pad.
    oval(50, 69, 66, 58, 0, paw);

    // Cat head: rounded face + two pointed ears.
    oval(50, 70, 38, 31, 0, face);
    canvas.drawPath(
      Path()
        ..moveTo(33, 62)
        ..lineTo(36, 46)
        ..lineTo(47, 56)
        ..close(),
      face,
    );
    canvas.drawPath(
      Path()
        ..moveTo(67, 62)
        ..lineTo(64, 46)
        ..lineTo(53, 56)
        ..close(),
      face,
    );

    // Eyes and nose.
    oval(42, 68, 5, 5.6, 0, paw);
    oval(58, 68, 5, 5.6, 0, paw);
    oval(50, 73, 4.4, 3.4, 0, paw);

    canvas.restore();
  }

  @override
  bool shouldRepaint(PawMarkPainter old) =>
      old.color != color || old.faceColor != faceColor;
}

/// Mark + "PurrFile" wordmark (+ optional tagline).
///
/// Defaults to brand green on a light surface. On the green header use
/// `color: scheme.onPrimary, faceColor: scheme.primary`.
class PurrLogo extends StatelessWidget {
  final double markSize;
  final Color? color;
  final Color? faceColor;
  final Axis direction;
  final String? tagline;

  const PurrLogo({
    super.key,
    this.markSize = 48,
    this.color,
    this.faceColor,
    this.direction = Axis.horizontal,
    this.tagline,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final ink = color ?? scheme.primary;
    final face = faceColor ?? scheme.surface;

    final mark = CustomPaint(
      size: Size.square(markSize),
      painter: PawMarkPainter(color: ink, faceColor: face),
    );
    final word = Text(
      'PurrFile',
      style: text.headlineMedium?.copyWith(
        color: ink,
        fontSize: markSize * 0.6,
        height: 1.1,
        fontWeight: FontWeight.w800,
      ),
    );

    final Widget content;
    if (direction == Axis.horizontal) {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: [mark, SizedBox(width: markSize * 0.14), word],
      );
    } else {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          mark,
          SizedBox(height: markSize * 0.08),
          word,
          if (tagline != null) ...[
            const SizedBox(height: 4),
            Text(
              tagline!,
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(color: ink.withValues(alpha: 0.92)),
            ),
          ],
        ],
      );
    }

    return Semantics(
      label: tagline == null ? 'PurrFile' : 'PurrFile — $tagline',
      child: ExcludeSemantics(child: content),
    );
  }
}
