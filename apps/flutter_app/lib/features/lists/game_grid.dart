import 'package:flutter/material.dart';

import '../../core/api/models.dart';
import '../../core/widgets/game_card.dart';
import '../../core/widgets/skeleton.dart';

int columnsFor(double width) => width >= 1400 ? 4 : (width >= 840 ? 3 : 2);

double pagePadding(double width) => width >= 840 ? 24 : 16;

/// Cards in 2 columns on a phone, 3 from 840 wide, 4 from 1400. Skeleton cards follow the real ones.
class GameGridSliver extends StatelessWidget {
  const GameGridSliver({
    super.key,
    required this.games,
    required this.heroScope,
    this.showRank = false,
    this.skeletons = 0,
    this.style = GameCardStyle.list,
  });

  final List<Game> games;
  final String heroScope;
  final bool showRank;
  final int skeletons;
  final GameCardStyle style;

  @override
  Widget build(BuildContext context) {
    final cols = columnsFor(MediaQuery.sizeOf(context).width);
    return SliverLayoutBuilder(
      builder: (context, c) {
        const gap = 12.0;
        final w = (c.crossAxisExtent - gap * (cols - 1)) / cols;
        return SliverGrid.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            mainAxisSpacing: gap,
            crossAxisSpacing: gap,
            mainAxisExtent: style.heightFor(w, textScale: cardTextScale(context)),
          ),
          itemCount: games.length + skeletons,
          itemBuilder: (context, i) => i < games.length
              ? GameCard(key: ValueKey('$heroScope-${games[i].nsuid}'), game: games[i], width: w, heroScope: heroScope, style: style, showRank: showRank)
              : SkeletonCard(width: w, style: style),
        );
      },
    );
  }
}
