import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../api/api_client.dart';

/// 16:9 art from the store's image server. Grey first, then a fade in. Decorative: the title carries the meaning.
///
/// That server sends no CORS header, so on the web the picture is a plain <img> element; elsewhere it is decoded
/// at display size, not at its full 1920 pixels.
class ArtImage extends StatelessWidget {
  const ArtImage({super.key, required this.hash, required this.logicalWidth, this.fit = BoxFit.cover});

  final String hash;
  final double logicalWidth;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final grey = ColoredBox(color: context.tokens.skeleton, child: const SizedBox.expand());
    if (hash.isEmpty) return grey;
    return ExcludeSemantics(
      child: Stack(
        fit: StackFit.expand,
        children: [
          grey,
          Image.network(
            imageUrl(hash),
            fit: fit,
            webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
            cacheWidth: kIsWeb ? null : imageWidthFor(logicalWidth, MediaQuery.devicePixelRatioOf(context)),
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
