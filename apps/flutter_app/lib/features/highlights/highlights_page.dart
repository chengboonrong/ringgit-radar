import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/api/models.dart';
import '../../core/api/providers.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/game_card.dart';
import '../../core/widgets/page_bits.dart';
import '../../core/widgets/skeleton.dart';
import '../lists/game_grid.dart';

class HighlightsPage extends ConsumerWidget {
  const HighlightsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(highlightsProvider);
    final width = MediaQuery.sizeOf(context).width;
    final pad = pagePadding(width);
    final bottom = width < 840 ? 120.0 : 32.0;

    return data.when(
      error: (e, _) => ErrorView(message: e.toString(), onRetry: () => ref.invalidate(highlightsProvider)),
      loading: () => _scroll(
        pad,
        bottom,
        [
          const SliverToBoxAdapter(child: _ChipRow()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: LayoutBuilder(builder: (context, c) => SizedBox(height: GameCardStyle.tile.heightFor(c.maxWidth, textScale: cardTextScale(context)), child: SkeletonCard(width: c.maxWidth, style: GameCardStyle.tile))),
            ),
          ),
        ],
      ),
      data: (h) => _scroll(pad, bottom, [
        const SliverToBoxAdapter(child: _ChipRow()),
        if (h.topSavings.isNotEmpty) ...[
          const SliverToBoxAdapter(child: SectionHeading('Biggest Switch 2 savings')),
          if (width >= 840)
            GameGridSliverTiles(games: h.topSavings)
          else
            SliverToBoxAdapter(child: _TileCarousel(games: h.topSavings)),
        ],
        if (h.endingSoon.isNotEmpty) ...[
          const SliverToBoxAdapter(child: SectionHeading('Ending Soon')),
          GameGridSliver(games: h.endingSoon, heroScope: 'ending'),
        ],
        if (h.newSales.isNotEmpty) ...[
          const SliverToBoxAdapter(child: SectionHeading('New Sales')),
          GameGridSliver(games: h.newSales, heroScope: 'newsales'),
        ],
      ]),
    );
  }

  Widget _scroll(double pad, double bottom, List<Widget> slivers) => CustomScrollView(
        slivers: [
          SliverPadding(padding: EdgeInsets.fromLTRB(pad, 4, pad, bottom), sliver: SliverMainAxisGroup(slivers: slivers)),
        ],
      );
}

/// Recent Releases and Coming Soon. On wide screens the sidebar lists them, so the row is phone only.
class _ChipRow extends StatelessWidget {
  const _ChipRow();

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.sizeOf(context).width >= 840) return const SizedBox.shrink();
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        OutlineChip(label: 'Recent Releases', onTap: () => context.go('/recent')),
        OutlineChip(label: 'Coming Soon', onTap: () => context.go('/coming-soon')),
      ],
    );
  }
}

/// Two-column tiles from 840 wide.
class GameGridSliverTiles extends StatelessWidget {
  const GameGridSliverTiles({super.key, required this.games});

  final List<Game> games;

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, c) {
        const gap = 16.0;
        final w = (c.crossAxisExtent - gap) / 2;
        return SliverGrid.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: gap,
            crossAxisSpacing: gap,
            mainAxisExtent: GameCardStyle.tile.heightFor(w, textScale: cardTextScale(context)),
          ),
          itemCount: games.length,
          itemBuilder: (context, i) => GameCard(game: games[i], width: w, heroScope: 'tile', style: GameCardStyle.tile),
        );
      },
    );
  }
}

/// Full-width 16:9 tiles with the next one peeking, and dots.
class _TileCarousel extends StatefulWidget {
  const _TileCarousel({required this.games});

  final List<Game> games;

  @override
  State<_TileCarousel> createState() => _TileCarouselState();
}

class _TileCarouselState extends State<_TileCarousel> {
  final _controller = PageController(viewportFraction: 0.9);
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return LayoutBuilder(
      builder: (context, c) {
        // the page is 90% of the width; the tile leaves 6 either side so the neighbour shows
        final tileWidth = c.maxWidth * 0.9 - 12;
        final height = GameCardStyle.tile.heightFor(tileWidth, textScale: cardTextScale(context));
        return Column(
          children: [
            SizedBox(
              height: height + 8,
              child: PageView.builder(
                controller: _controller,
                padEnds: false,
                itemCount: widget.games.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) => Padding(
                  padding: const EdgeInsets.fromLTRB(0, 4, 12, 4),
                  child: GameCard(game: widget.games[i], width: tileWidth, heroScope: 'tile', style: GameCardStyle.tile),
                ),
              ),
            ),
            const SizedBox(height: 8),
            ExcludeSemantics(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < widget.games.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: i == _page ? 16 : 6,
                      height: 6,
                      decoration: BoxDecoration(color: i == _page ? tk.text : tk.hint.withValues(alpha: 0.45), borderRadius: BorderRadius.circular(3)),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
