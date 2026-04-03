import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shimmer/shimmer.dart';

/// A shimmer effect to be used as a placeholder for loading content.
class ShimmerCover extends StatelessWidget {
  /// Initializes the shimmer cover.
  const ShimmerCover({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      highlightColor: Theme.of(context).colorScheme.surface,
      child: Icon(Symbols.music_note),
    );
  }
}
