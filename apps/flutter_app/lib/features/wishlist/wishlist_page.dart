import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../app/theme.dart';
import '../../core/api/models.dart';
import '../../core/api/providers.dart';
import '../../core/storage/prefs.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/page_bits.dart';
import '../lists/game_grid.dart';

class WishlistPage extends ConsumerStatefulWidget {
  const WishlistPage({super.key});

  @override
  ConsumerState<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends ConsumerState<WishlistPage> {
  bool _onSaleOnly = false;

  @override
  Widget build(BuildContext context) {
    final ids = ref.watch(wishlistProvider);
    final width = MediaQuery.sizeOf(context).width;
    final pad = pagePadding(width);
    final bottom = width < 840 ? 120.0 : 32.0;
    if (ids.isEmpty) return const _EmptyWishlist();

    final games = ref.watch(wishlistGamesProvider);
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(pad, 4, pad, 0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PageTitle('Wish List'),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Align(alignment: Alignment.centerLeft, child: OutlineChip(label: 'On Sale', selected: _onSaleOnly, onTap: () => setState(() => _onSaleOnly = !_onSaleOnly))),
                ),
              ],
            ),
          ),
        ),
        games.when(
          error: (e, _) => SliverFillRemaining(hasScrollBody: false, child: ErrorView(message: e.toString(), onRetry: () => ref.invalidate(wishlistGamesProvider))),
          loading: () => SliverPadding(
            padding: EdgeInsets.fromLTRB(pad, 0, pad, bottom),
            sliver: GameGridSliver(games: const [], heroScope: 'wish', skeletons: ids.length.clamp(2, 6)),
          ),
          data: (all) {
            final shown = _onSaleOnly ? all.where((g) => g.onSale).toList() : all;
            if (shown.isEmpty) {
              return const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Padding(padding: EdgeInsets.all(32), child: Text('None of the games on your Wish List are on sale right now.', textAlign: TextAlign.center))),
              );
            }
            return SliverPadding(
              padding: EdgeInsets.fromLTRB(pad, 0, pad, bottom),
              sliver: GameGridSliver(games: shown, heroScope: 'wish'),
            );
          },
        ),
      ],
    );
  }
}

/// Three grey skeleton cards with a heart speech bubble, as on the console.
class _EmptyWishlist extends StatelessWidget {
  const _EmptyWishlist();

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 130,
                width: 280,
                child: ExcludeSemantics(
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 36,
                        child: Row(
                          children: [
                            for (var i = 0; i < 3; i++)
                              Container(
                                width: 84,
                                height: 70,
                                margin: const EdgeInsets.only(right: 6),
                                decoration: BoxDecoration(color: tk.card, borderRadius: BorderRadius.circular(4)),
                                child: Column(
                                  children: [
                                    Expanded(child: Container(decoration: BoxDecoration(color: tk.skeleton, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))))),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(0, 6, 8, 6),
                                      child: Align(alignment: Alignment.centerRight, child: Container(width: 26, height: 5, decoration: BoxDecoration(color: tk.skeletonPill, borderRadius: BorderRadius.circular(3)))),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 6,
                        top: 4,
                        child: Container(
                          width: 66,
                          height: 66,
                          decoration: BoxDecoration(color: tk.isDark ? tk.card : Colors.white, shape: BoxShape.circle),
                          child: Icon(PhosphorIconsFill.heart, size: 34, color: tk.skeleton.withValues(alpha: 1)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Semantics(
                header: true,
                child: Text("You can add software you're interested in to your Wish List!", textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500, height: 1.4)),
              ),
              const SizedBox(height: 10),
              Text('Tap the heart on any game, in a list or on its page, to add it here.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: tk.hint)),
            ],
          ),
        ),
      ),
    );
  }
}
