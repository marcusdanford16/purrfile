import 'package:flutter/material.dart';

import '../models/cat.dart';
import '../theme/app_theme.dart';

/// A cat's photo as a soft rounded square. Falls back to a green tile with
/// the cat's initial when there is no photo, or the photo fails to load.
class CatAvatar extends StatelessWidget {
  final Cat cat;
  final double size;

  /// Draws a white ring around the photo (for use on the green hero).
  final bool ring;

  const CatAvatar({
    super.key,
    required this.cat,
    this.size = 56,
    this.ring = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(size * 0.32);
    final photo = cat.photo;

    final initial = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(gradient: scheme.heroGradient),
      child: Text(
        cat.name.isNotEmpty ? cat.name[0].toUpperCase() : '?',
        style: text.titleLarge?.copyWith(
          color: scheme.onPrimary,
          fontSize: size * 0.42,
        ),
      ),
    );

    final Widget content = (photo == null || photo.isEmpty)
        ? initial
        : Image.network(
            photo,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => initial,
            loadingBuilder: (context, child, progress) => progress == null
                ? child
                : SizedBox(
                    width: size,
                    height: size,
                    child: ColoredBox(color: scheme.primaryContainer),
                  ),
          );

    return Semantics(
      image: true,
      label: 'Photo of ${cat.name}',
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: radius,
          border: ring ? Border.all(color: scheme.surface, width: 3) : null,
        ),
        child: ClipRRect(borderRadius: radius, child: content),
      ),
    );
  }
}
