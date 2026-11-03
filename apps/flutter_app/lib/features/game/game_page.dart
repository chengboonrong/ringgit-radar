import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../app/theme.dart';
import '../../core/api/models.dart';
import '../../core/api/providers.dart';
import '../../core/format.dart';
import '../../core/game_x.dart';
import '../../core/storage/prefs.dart';
import '../../core/widgets/art_image.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/game_card.dart';
import '../../core/widgets/price_text.dart';
import '../../core/widgets/ring.dart';
import '../../core/widgets/skeleton.dart';
import 'price_history_chart.dart';

const _wideBreakpoint = 1200.0;

class GamePage extends ConsumerWidget {
  const GamePage({super.key, required this.nsuid, this.extra});

  final String nsuid;
  final GameRouteExtra? extra;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tk = context.tokens;
    final detail = ref.watch(gameDetailProvider(nsuid));
    final preview = extra?.game;
    final heroTag = extra?.heroTag ?? 'art-direct-$nsuid';
    final width = MediaQuery.sizeOf(context).width;
    final wide = width >= _wideBreakpoint;

    // the card the visitor came from gives the title, art and price at once; the rest arrives after
    final GameDetail? d = detail.value;
    final Game? game = d?.asGame ?? preview;

    ({Widget left, Widget? right}) body;
    if (game == null) {
      body = (
        left: detail.hasError
            ? ErrorView(
                message: detail.error.toString(),
                onRetry: () => ref.invalidate(gameDetailProvider(nsuid)),
              )
            : const _PageSkeleton(),
        right: null,
      );
    } else {
      body = (
        left: _Facts(
          game: game,
          detail: d,
          loadError: detail.hasError ? detail.error.toString() : null,
          heroTag: heroTag,
          nsuid: nsuid,
        ),
        right: wide
            ? Container(
                width: (width / 3).clamp(380, 520),
                color: tk.card,
                child: _PricePanel(game: game, wide: true),
              )
            : _PricePanel(game: game, wide: false),
      );
    }

    final top = MediaQuery.paddingOf(context).top;
    final isSwitch2 = (game?.isSwitch2 ?? false);
    final header = Container(
      height: top + 48,
      color: isSwitch2 ? brandRed : tk.content,
      padding: EdgeInsets.only(top: top),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isSwitch2)
            const Text(
              'Switch 2',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
                height: 1.2,
              ),
            ),
          Positioned(
            left: 4,
            child: TapBox(
              ringRadius: 20,
              label: 'Back',
              onTap: () => context.canPop() ? context.pop() : context.go('/'),
              child: Icon(
                PhosphorIconsBold.arrowLeft,
                size: 22,
                color: isSwitch2 ? Colors.white : tk.text,
              ),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: tk.content,
      body: wide
          ? Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      header,
                      Expanded(child: body.left),
                    ],
                  ),
                ),
                if (body.right != null) body.right!,
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                header,
                Expanded(child: body.left),
                if (body.right != null) body.right!,
              ],
            ),
    );
  }
}

class _PageSkeleton extends StatelessWidget {
  const _PageSkeleton();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SkeletonLine(width: 220, height: 24),
        const SizedBox(height: 10),
        const SkeletonLine(width: 120),
        const SizedBox(height: 18),
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(color: context.tokens.skeleton),
        ),
      ],
    ),
  );
}

/// The scrolling side: band, title, media, then facts in order.
class _Facts extends ConsumerWidget {
  const _Facts({
    required this.game,
    required this.detail,
    required this.loadError,
    required this.heroTag,
    required this.nsuid,
  });

  final Game game;
  final GameDetail? detail;
  final String? loadError;
  final String heroTag;
  final String nsuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tk = context.tokens;
    final width = MediaQuery.sizeOf(context).width;
    final side = width >= 840 ? 40.0 : 16.0;
    final now = DateTime.now();
    final d = detail;
    final price = d?.price ?? game.price;

    final sections = <Widget>[
      if (price?.onSale == true && price?.discountEnd != null)
        _Fact(
          icon: PhosphorIconsRegular.tag,
          text: saleEndsMyt(price!.discountEnd!),
          strong: true,
        ),
      _HistorySection(
        detail: d,
        error: loadError,
        onRetry: () => ref.invalidate(gameDetailProvider(nsuid)),
        now: now,
      ),
      if (d != null && (d.tagline.isNotEmpty || d.description.isNotEmpty))
        _Description(tagline: d.tagline, text: d.description),
      if (d != null && d.addons.isNotEmpty)
        _Dlc(addons: d.addons, ownerNsuid: nsuid),
      if (d != null) _Details(detail: d, game: game),
    ];

    return Scrollbar(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(side, 8, side, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      game.title,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontSize: width >= 840 ? 30 : 23),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    game.publisher,
                    style: TextStyle(fontSize: 15, color: tk.hint),
                  ),
                  const SizedBox(height: 16),
                  _Media(
                    game: game,
                    screenshots: d?.screenshots ?? const [],
                    heroTag: heroTag,
                    flash: ref.watch(
                      ringFlashProvider.select((id) => id == 'hero-$nsuid'),
                    ),
                  ),
                  for (final s in sections) ...[const SizedBox(height: 24), s],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Media extends StatefulWidget {
  const _Media({
    required this.game,
    required this.screenshots,
    required this.heroTag,
    required this.flash,
  });

  final bool flash;
  final Game game;
  final List<String> screenshots;
  final String heroTag;

  @override
  State<_Media> createState() => _MediaState();
}

class _MediaState extends State<_Media> {
  final _controller = PageController();
  int _page = 0;
  bool _focused = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _go(int to, int count) => _controller.animateToPage(
    to.clamp(0, count - 1),
    duration: const Duration(milliseconds: 250),
    curve: Curves.easeOutCubic,
  );

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final hashes = [
      if (widget.game.image.isNotEmpty) widget.game.image,
      ...widget.screenshots,
    ];
    final wide = MediaQuery.sizeOf(context).width >= 840;
    if (hashes.isEmpty) {
      return AspectRatio(aspectRatio: 16 / 9, child: Container(color: tk.skeleton));
    }
    return LayoutBuilder(
      builder: (context, c) => Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              children: [
                Positioned.fill(
                  child: FocusableActionDetector(
                    onShowFocusHighlight: (v) => setState(() => _focused = v),
                    shortcuts: const {
                      SingleActivator(LogicalKeyboardKey.arrowLeft):
                          _StepIntent(-1),
                      SingleActivator(LogicalKeyboardKey.arrowRight):
                          _StepIntent(1),
                    },
                    actions: {
                      _StepIntent: CallbackAction<_StepIntent>(
                        onInvoke: (i) {
                          _go(_page + i.by, hashes.length);
                          return null;
                        },
                      ),
                    },
                    child: GradientRing(
                      show: _focused || widget.flash,
                      radius: 10,
                      child: Semantics(
                        label: 'Media, ${_page + 1} of ${hashes.length}',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: PageView.builder(
                            controller: _controller,
                            itemCount: hashes.length,
                            onPageChanged: (i) => setState(() => _page = i),
                            itemBuilder: (context, i) {
                              final art = ArtImage(
                                hash: hashes[i],
                                logicalWidth: c.maxWidth,
                              );
                              return i == 0
                                  ? Hero(tag: widget.heroTag, child: art)
                                  : art;
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (wide && hashes.length > 1) ...[
                  Positioned(
                    left: 4,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: _Arrow(
                        forward: false,
                        enabled: _page > 0,
                        onTap: () => _go(_page - 1, hashes.length),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 4,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: _Arrow(
                        forward: true,
                        enabled: _page < hashes.length - 1,
                        onTap: () => _go(_page + 1, hashes.length),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (hashes.length > 1) ...[
            const SizedBox(height: 10),
            ExcludeSemantics(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < hashes.length; i++)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == _page
                            ? tk.text
                            : tk.hint.withValues(alpha: 0.4),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StepIntent extends Intent {
  const _StepIntent(this.by);
  final int by;
}

class _Arrow extends StatelessWidget {
  const _Arrow({
    required this.forward,
    required this.enabled,
    required this.onTap,
  });

  final bool forward;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return const SizedBox(width: 44, height: 44);
    return TapBox(
      label: forward ? 'Next image' : 'Previous image',
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.55),
          shape: BoxShape.circle,
        ),
        child: Icon(
          forward ? PhosphorIconsBold.caretRight : PhosphorIconsBold.caretLeft,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.icon, required this.text, this.strong = false});

  final IconData icon;
  final String text;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: strong ? tk.saleText : tk.hint),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: strong ? FontWeight.w700 : FontWeight.w400,
              color: strong ? tk.saleText : tk.text,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _HistorySection extends StatelessWidget {
  const _HistorySection({
    required this.detail,
    required this.error,
    required this.onRetry,
    required this.now,
  });

  final GameDetail? detail;
  final String? error;
  final VoidCallback onRetry;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final d = detail;
    Widget content;
    if (d == null) {
      content = error != null
          ? Row(
              children: [
                Expanded(child: Text(error!)),
                const SizedBox(width: 12),
                RedButton(label: 'Retry', onTap: onRetry, minWidth: 80),
              ],
            )
          : const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLine(width: 260),
                SizedBox(height: 10),
                SkeletonLine(width: 180),
              ],
            );
    } else if (d.history.isEmpty) {
      content = Text(
        'No price recorded yet.',
        style: TextStyle(fontSize: 15, color: tk.hint),
      );
    } else if (d.history.length < 2 && d.firstObservedAt != null) {
      // one observation so far: the whole story is one line, with no lowest price and no chart
      content = Text(
        "Tracking began ${longDateMyt(d.firstObservedAt!)}. We've only seen this price so far.",
        style: TextStyle(fontSize: 15, color: tk.hint, height: 1.4),
      );
    } else {
      final lowest = d.lowest;
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (lowest != null)
            Text(
              "Lowest we've seen: ${plainMoney(lowest.priceMinor)} since ${longDateMyt(lowest.since)}",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          if (d.firstObservedAt != null) ...[
            const SizedBox(height: 4),
            Text(
              'Tracking began ${longDateMyt(d.firstObservedAt!)}',
              style: TextStyle(fontSize: 14, color: tk.hint, height: 1.4),
            ),
          ],
          const SizedBox(height: 14),
          PriceHistoryChart(history: d.history, now: now),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            'What our history shows',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 8),
        content,
      ],
    );
  }
}

class _Description extends StatelessWidget {
  const _Description({required this.tagline, required this.text});

  final String tagline;
  final String text;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            'Description',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 8),
        if (tagline.isNotEmpty) ...[
          Text(
            tagline,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 8),
        ],
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Text(
            text,
            style: TextStyle(fontSize: 15, height: 1.6, color: tk.text),
          ),
        ),
      ],
    );
  }
}

class _Dlc extends StatelessWidget {
  const _Dlc({required this.addons, required this.ownerNsuid});

  final List<Game> addons;
  final String ownerNsuid;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final now = DateTime.now();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            'Downloadable Content',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 8),
        for (final a in addons)
          RingTarget(
            radius: 8,
            label:
                '${a.title}, ${a.price == null ? a.noPriceLabel(now) : PriceText.describe(a.price!)}',
            onTap: () async {
              final container = ProviderScope.containerOf(context);
              await context.push<void>(
                '/games/${a.nsuid}',
                extra: GameRouteExtra(game: a, heroTag: 'art-dlc-${a.nsuid}'),
              );
              // back on this page, the hero holds the ring for a second so people keep their place
              container
                  .read(ringFlashProvider.notifier)
                  .flash('hero-$ownerNsuid');
            },
            child: Container(
              constraints: const BoxConstraints(minHeight: 56),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: tk.card,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ExcludeSemantics(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        a.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (a.price != null)
                      PriceText(price: a.price!, digitSize: 15)
                    else
                      Text(
                        a.noPriceLabel(now),
                        style: TextStyle(color: tk.hint, fontSize: 13),
                      ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({required this.detail, required this.game});

  final GameDetail detail;
  final Game game;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final rows = <(String, String)>[
      ('Publisher', game.publisher),
      if (game.platformLabel.isNotEmpty) ('Platform', game.platformLabel),
      (
        'Product type',
        switch (game.category) {
          'bundle' => 'Bundle',
          'addon' => 'Add-on',
          _ => 'Game',
        },
      ),
      if (game.releaseDate != null)
        ('Release date', releaseDateLabel(game.releaseDate!))
      else if (game.releaseText.isNotEmpty)
        ('Release date', game.releaseText),
      if (detail.genres.isNotEmpty) ('Genre', detail.genres.join(', ')),
      if (detail.players.isNotEmpty) ('Players', detail.players),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            'Details',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          detail.age == null
              ? 'No age rating found'
              : 'Age rating: ${detail.age} (UK PEGI)',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
        ),
        if ((detail.ageDescriptors ?? const []).isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            detail.ageDescriptors!.join(', '),
            style: TextStyle(fontSize: 14, color: tk.hint, height: 1.4),
          ),
        ],
        const SizedBox(height: 10),
        for (final (k, v) in rows)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: tk.divider.withValues(alpha: 0.7)),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 120,
                  child: Text(
                    k,
                    style: TextStyle(color: tk.hint, fontSize: 14),
                  ),
                ),
                Expanded(
                  child: Text(
                    v,
                    style: const TextStyle(fontSize: 14, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// The price and the red button: a sticky bar on a phone, the right column from 1200 wide.
class _PricePanel extends ConsumerWidget {
  const _PricePanel({required this.game, required this.wide});

  final Game game;
  final bool wide;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tk = context.tokens;
    final now = DateTime.now();
    final saved = ref.watch(
      wishlistProvider.select((l) => l.contains(game.nsuid)),
    );
    final price = game.price;
    final chips = [
      if (game.isPreorder)
        const StatusChip(label: 'Pre-order', color: green, size: 13)
      else if (game.isNewAt(now))
        const StatusChip(label: 'NEW', color: amber, size: 13),
    ];

    final button = RedButton(
      label: saved ? 'On Wish List' : 'Add to Wish List',
      icon: saved ? PhosphorIconsFill.heart : PhosphorIconsRegular.heart,
      minWidth: wide ? 0 : 150,
      expand: wide,
      onTap: () {
        tick();
        ref.read(wishlistProvider.notifier).toggle(game.nsuid);
      },
    );
    final priceWidget = price != null
        ? PriceText(price: price, digitSize: wide ? 44 : 22)
        : Text(
            game.noPriceLabel(now),
            style: TextStyle(
              fontSize: wide ? 22 : 16,
              fontWeight: FontWeight.w700,
              color: tk.hint,
            ),
          );
    final quiet = Text(
      "Buy on your Switch's Nintendo eShop.",
      style: TextStyle(fontSize: 13, color: tk.hint, height: 1.3),
    );

    if (wide) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 72, 32, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ...chips,
              const SizedBox(height: 16),
              priceWidget,
              const SizedBox(height: 24),
              SizedBox(width: double.infinity, child: button),
              const SizedBox(height: 12),
              quiet,
            ],
          ),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: tk.card,
        border: Border(top: BorderSide(color: tk.divider)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        10,
        16,
        8 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 5,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FittedBox(fit: BoxFit.scaleDown, child: button),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 6,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ...chips,
                    if (chips.isNotEmpty) const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: priceWidget,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          quiet,
        ],
      ),
    );
  }
}
