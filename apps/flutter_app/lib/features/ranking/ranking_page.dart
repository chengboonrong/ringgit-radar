import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../core/api/providers.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/page_bits.dart';
import '../../core/widgets/ring.dart';
import '../lists/game_grid.dart';

class RankingPage extends ConsumerStatefulWidget {
  const RankingPage({super.key});

  @override
  ConsumerState<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends ConsumerState<RankingPage> with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 2, vsync: this)..addListener(() => setState(() {}));

  static const _platforms = ['switch2', 'switch'];
  static const _names = ['Switch 2', 'Switch'];

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final width = MediaQuery.sizeOf(context).width;
    final pad = pagePadding(width);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(padding: EdgeInsets.symmetric(horizontal: pad), child: const PageTitle('Ranking')),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: pad),
          child: Row(
            children: [
              for (var i = 0; i < 2; i++)
                Expanded(
                  child: RingTarget(
                    radius: 6,
                    selected: _tabs.index == i,
                    label: _names[i],
                    onTap: () => _tabs.animateTo(i),
                    child: Container(
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: _tabs.index == i ? brandRed : Colors.transparent, width: 3))),
                      child: ExcludeSemantics(
                        child: Text(_names[i],
                            style: TextStyle(fontWeight: _tabs.index == i ? FontWeight.w700 : FontWeight.w500, fontSize: 15, color: _tabs.index == i ? tk.saleText : tk.text)),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(pad, 10, pad, 6),
          child: Text('Ranked by ringgit saved', style: Theme.of(context).textTheme.bodySmall),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabs,
            children: [for (final p in _platforms) _RankedGrid(platform: p)],
          ),
        ),
      ],
    );
  }
}

class _RankedGrid extends ConsumerWidget {
  const _RankedGrid({required this.platform});

  final String platform;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(rankingProvider(platform));
    final width = MediaQuery.sizeOf(context).width;
    final pad = pagePadding(width);
    final bottom = width < 840 ? 120.0 : 32.0;
    return data.when(
      error: (e, _) => ErrorView(message: e.toString(), onRetry: () => ref.invalidate(rankingProvider(platform))),
      loading: () => CustomScrollView(slivers: [
        SliverPadding(padding: EdgeInsets.fromLTRB(pad, 4, pad, bottom), sliver: const GameGridSliver(games: [], heroScope: 'rank', skeletons: 8)),
      ]),
      data: (games) => games.isEmpty
          ? const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('Nothing is on sale for this console right now.', textAlign: TextAlign.center)))
          : CustomScrollView(slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(pad, 4, pad, bottom),
                sliver: GameGridSliver(games: games, heroScope: 'rank-$platform', showRank: true),
              ),
            ]),
    );
  }
}
