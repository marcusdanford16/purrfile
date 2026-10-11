import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/app_spacing.dart';

/// The one surface every list row, stat and info tile sits on: a white,
/// softly shadowed rounded panel. Pass [onTap] to make it tappable (with a
/// proper ink ripple).
class PurrCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final Color? color;
  final bool outlined;

  const PurrCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.borderRadius = AppRadius.md,
    this.color,
    this.outlined = true,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: context.purr.shadowSoft,
      ),
      child: Material(
        color: color ?? scheme.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: outlined
              ? BorderSide(color: scheme.outlineVariant)
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
