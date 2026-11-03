import 'package:flutter/material.dart';

import '../../app/theme.dart';
import 'game_card.dart';

/// Art-first skeleton: a grey art block and a grey pill where the price will be. Never a spinner.
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key, required this.width, this.style = GameCardStyle.list});

  final double width;
  final GameCardStyle style;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: ColoredBox(
          color: tk.card,
          child: Column(
            children: [
              SizedBox(height: style.bandHeight),
              AspectRatio(aspectRatio: 16 / 9, child: ColoredBox(color: tk.skeleton)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      width: width * 0.36,
                      height: 12,
                      decoration: BoxDecoration(color: tk.skeletonPill, borderRadius: BorderRadius.circular(6)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Grey bar for a line of text that has not arrived.
class SkeletonLine extends StatelessWidget {
  const SkeletonLine({super.key, required this.width, this.height = 14});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(color: context.tokens.skeleton, borderRadius: BorderRadius.circular(height / 2)),
        ),
      );
}
