import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../api/api_client.dart';

/// 16:9 art from our image proxy. Grey first, then a fade in. Decorative: the title carries the meaning.
class ArtImage extends StatelessWidget {
  const ArtImage({super.key, required this.hash, required this.logicalWidth, this.fit = BoxFit.cover});

  final String hash;
  final double logicalWidth;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final grey = ColoredBox(color: context.tokens.skeleton, child: const SizedBox.expand());
    if (hash.isEmpty) return grey;
    final url = imageUrl(hash, width: imageWidthFor(logicalWidth, MediaQuery.devicePixelRatioOf(context)));
    return ExcludeSemantics(
      child: Stack(
        fit: StackFit.expand,
        children: [
          grey,
          Image.network(
            url,
            fit: fit,
            gaplessPlayback: true,
            frameBuilder: (context, child, frame, sync) => AnimatedOpacity(
              opacity: frame == null ? 0 : 1,
              duration: sync ? Duration.zero : const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              child: child,
            ),
            errorBuilder: (context, error, stack) => grey,
          ),
        ],
      ),
    );
  }
}
