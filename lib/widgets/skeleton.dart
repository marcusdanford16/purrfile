import 'package:flutter/material.dart';

import '../utils/app_spacing.dart';

/// A softly pulsing placeholder block shown while data loads. Stays still
/// when the device asks for reduced motion.
class SkeletonBox extends StatefulWidget {
  final double? width;
  final double height;
  final BorderRadius borderRadius;

  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = AppRadius.md,
  });

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final still = MediaQuery.disableAnimationsOf(context);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = still ? 0.0 : Curves.easeInOut.transform(_controller.value);
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Color.lerp(
                scheme.surfaceContainer, scheme.surfaceContainerHigh, t),
            borderRadius: widget.borderRadius,
          ),
        );
      },
    );
  }
}

/// A column of [count] card-shaped skeletons.
class SkeletonList extends StatelessWidget {
  final int count;
  final double itemHeight;

  const SkeletonList({super.key, this.count = 3, this.itemHeight = 76});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading',
      child: Column(
        children: [
          for (var i = 0; i < count; i++) ...[
            SkeletonBox(height: itemHeight),
            if (i != count - 1) const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}
