import 'package:flutter/material.dart';

/// Page background for the signed-in app: the cream base with two soft
/// green hills at the bottom, drawn behind every tab.
class PurrBackdrop extends StatelessWidget {
  const PurrBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Stack(
      children: [
        Positioned.fill(child: ColoredBox(color: scheme.surfaceContainerLowest)),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 300,
          child: IgnorePointer(
            child: CustomPaint(
              painter: _HillsPainter(
                back: scheme.secondary.withValues(alpha: 0.18),
                front: scheme.primary.withValues(alpha: 0.06),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HillsPainter extends CustomPainter {
  final Color back;
  final Color front;

  const _HillsPainter({required this.back, required this.front});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final far = Path()
      ..moveTo(0, h * 0.45)
      ..cubicTo(w * 0.2, h * 0.15, w * 0.45, h * 0.55, w * 0.7, h * 0.3)
      ..cubicTo(w * 0.85, h * 0.15, w * 0.95, h * 0.2, w, h * 0.28)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    final near = Path()
      ..moveTo(0, h * 0.75)
      ..cubicTo(w * 0.3, h * 0.5, w * 0.6, h * 1.0, w, h * 0.6)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    canvas.drawPath(far, Paint()..color = back);
    canvas.drawPath(near, Paint()..color = front);
  }

  @override
  bool shouldRepaint(_HillsPainter old) =>
      old.back != back || old.front != front;
}

/// A line-art cat that peeks over the top edge of the first cat card.
/// Decorative only — wrap in ExcludeSemantics.
class CatPeek extends StatelessWidget {
  final double width;

  const CatPeek({super.key, this.width = 112});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return CustomPaint(
      size: Size(width, width * 100 / 160),
      painter: _CatPeekPainter(scheme.primary.withValues(alpha: 0.7)),
    );
  }
}

class _CatPeekPainter extends CustomPainter {
  final Color color;

  const _CatPeekPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    // Drawn on a 160 x 100 grid.
    canvas.save();
    canvas.scale(size.width / 160);

    final line = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final dot = Paint()..color = color;

    // Head outline with two ears; the bottom disappears behind the card.
    canvas.drawPath(
      Path()
        ..moveTo(28, 100)
        ..lineTo(30, 24)
        ..quadraticBezierTo(46, 26, 62, 42)
        ..quadraticBezierTo(80, 34, 98, 42)
        ..quadraticBezierTo(114, 26, 130, 24)
        ..lineTo(132, 100),
      line,
    );

    canvas.drawCircle(const Offset(58, 68), 3.2, dot);
    canvas.drawCircle(const Offset(102, 68), 3.2, dot);
    canvas.drawCircle(const Offset(80, 76), 2.2, dot);

    final thin = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      Path()
        ..moveTo(72, 82)
        ..quadraticBezierTo(76, 88, 80, 82)
        ..quadraticBezierTo(84, 88, 88, 82),
      thin,
    );
    // Whiskers.
    canvas.drawLine(const Offset(26, 72), const Offset(6, 66), thin);
    canvas.drawLine(const Offset(26, 80), const Offset(4, 82), thin);
    canvas.drawLine(const Offset(134, 72), const Offset(154, 66), thin);
    canvas.drawLine(const Offset(134, 80), const Offset(156, 82), thin);

    canvas.restore();
  }

  @override
  bool shouldRepaint(_CatPeekPainter old) => old.color != color;
}

/// Three faint paw prints, a quiet texture for the top-right of Home.
class PawPrints extends StatelessWidget {
  const PawPrints({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme.secondary.withValues(alpha: 0.32);
    return SizedBox(
      width: 96,
      height: 80,
      child: Stack(
        children: [
          Positioned(
            right: 4,
            top: 0,
            child: Transform.rotate(
                angle: 0.35, child: Icon(Icons.pets, size: 30, color: c)),
          ),
          Positioned(
            left: 8,
            top: 26,
            child: Transform.rotate(
                angle: -0.3, child: Icon(Icons.pets, size: 24, color: c)),
          ),
          Positioned(
            right: 30,
            top: 46,
            child: Transform.rotate(
                angle: 0.2, child: Icon(Icons.pets, size: 20, color: c)),
          ),
        ],
      ),
    );
  }
}
