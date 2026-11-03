import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../app/theme.dart';
import '../api/models.dart';
import '../format.dart';
import '../game_x.dart';
import '../storage/prefs.dart';
import 'art_image.dart';
import 'price_text.dart';
import 'ring.dart';

enum GameCardStyle {
  list(bandHeight: 18, bodyHeight: 72, titleSize: 13, digitSize: 17),
  tile(bandHeight: 24, bodyHeight: 80, titleSize: 16, digitSize: 20);

  const GameCardStyle({required this.bandHeight, required this.bodyHeight, required this.titleSize, required this.digitSize});

  final double bandHeight;
  final double bodyHeight;
  final double titleSize;
  final double digitSize;

  /// Height of a card [width] wide: band (Switch 2 only), 16:9 art, body. The body grows with the text
  /// scale, which the app clamps to 1.3, so a sale price block never overflows. Grid cells use the
  /// banded height; a Switch card is a band shorter and sits at the bottom of its cell.
  double heightFor(double width, {bool band = true, double textScale = 1}) =>
      (band ? bandHeight : 0) + width * 9 / 16 + bodyHeight * textScale.clamp(1.0, 1.3);
}

/// How much the card body has to grow for the current text scale.
double cardTextScale(BuildContext context) => MediaQuery.textScalerOf(context).scale(1);

/// The id of the card whose game page was just closed. Its ring stays on for about a second.
class RingFlash extends Notifier<String?> {
  Timer? _timer;

  @override
  String? build() {
    ref.onDispose(() => _timer?.cancel());
    return null;
  }

  void flash(String nsuid) {
    _timer?.cancel();
    state = nsuid;
    _timer = Timer(const Duration(milliseconds: 1000), () => state = null);
  }
}

final ringFlashProvider = NotifierProvider<RingFlash, String?>(RingFlash.new);

/// The one game card. Used by every list, grid and tile.
class GameCard extends ConsumerWidget {
  const GameCard({
    super.key,
    required this.game,
    required this.width,
    required this.heroScope,
    this.style = GameCardStyle.list,
    this.showRank = false,
  });

  final Game game;
  final double width;
  final String heroScope;
  final GameCardStyle style;
  final bool showRank;

  static const medals = [Color(0xFFC1A417), Color(0xFF8F949C), Color(0xFFD27119)];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tk = context.tokens;
    final now = DateTime.now();
    final saved = ref.watch(wishlistProvider.select((l) => l.contains(game.nsuid)));
    final flash = ref.watch(ringFlashProvider.select((id) => id == game.nsuid));
    final price = game.price;
    final heroTag = 'art-$heroScope-${game.nsuid}';
    final container = ProviderScope.containerOf(context);

    Future<void> open() async {
      await context.push<void>('/games/${game.nsuid}', extra: GameRouteExtra(game: game, heroTag: heroTag));
      container.read(ringFlashProvider.notifier).flash(game.nsuid);
    }

    final isNew = game.isNewAt(now);
    final chips = <Widget>[
      if (game.isPreorder) const StatusChip(label: 'Pre-order', color: green) else if (isNew) const StatusChip(label: 'NEW', color: amber),
    ];

    final label = [
      game.title,
      if (game.isSwitch2) 'Switch 2',
      if (game.kindLabel.isNotEmpty) game.kindLabel,
      if (showRank && game.rank != null) 'Rank ${game.rank}',
      if (price != null) PriceText.describe(price) else game.noPriceLabel(now),
      if (price?.onSale == true && price?.discountEnd != null) 'Ends ${shortDateMyt(price!.discountEnd!)}',
    ].join(', ');

    final scale = cardTextScale(context);
    final cardHeight = style.heightFor(width, band: game.isSwitch2, textScale: scale);
    final cell = style.heightFor(width, textScale: scale);
    // a Switch card is a band shorter and bottom-aligned, so art, title and price line up in a row
    return SizedBox(
      width: width,
      height: cell,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: _card(context, ref, tk, open, flash, label, saved, price, chips, now, cardHeight),
      ),
    );
  }

  Widget _card(BuildContext context, WidgetRef ref, Tokens tk, VoidCallback open, bool flash, String label, bool saved, Price? price, List<Widget> chips, DateTime now, double cardHeight) {
    final heroTag = 'art-$heroScope-${game.nsuid}';
    return RingTarget(
      onTap: open,
      radius: 8,
      flash: flash,
      label: label,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: ColoredBox(
              color: tk.card,
              child: SizedBox(
                width: width,
                height: cardHeight,
                child: ExcludeSemantics(
                  child: Column(
                    children: [
                      if (game.isSwitch2)
                        Container(
                          height: style.bandHeight,
                          color: brandRed,
                          alignment: Alignment.center,
                          child: Text('Switch 2',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: style == GameCardStyle.tile ? 13 : 11, height: 1.1)),
                        ),
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Hero(tag: heroTag, child: ArtImage(hash: game.image, logicalWidth: width)),
                            if (style == GameCardStyle.list && chips.isNotEmpty) Positioned(left: 6, top: 6, child: chips.first),
                            if (game.kindLabel.isNotEmpty)
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  color: Colors.black.withValues(alpha: 0.62),
                                  child: Text(game.kindLabel, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                                ),
                              ),
                            if (showRank && game.rank != null) Positioned(left: 0, bottom: 0, child: RankChip(rank: game.rank!)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      game.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: style.titleSize, fontWeight: FontWeight.w500, color: tk.text, height: 1.25),
                                    ),
                                  ),
                                  if (style == GameCardStyle.tile && chips.isNotEmpty) ...[const SizedBox(width: 8), chips.first],
                                ],
                              ),
                              const Spacer(),
                              Align(
                                alignment: Alignment.centerRight,
                                child: price != null
                                    ? PriceText(
                                        price: price,
                                        digitSize: style.digitSize,
                                        note: price.onSale && price.discountEnd != null ? 'Ends ${shortDateMyt(price.discountEnd!)}' : null,
                                      )
                                    : FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(game.noPriceLabel(now), style: TextStyle(fontSize: style.titleSize, fontWeight: FontWeight.w500, color: tk.hint)),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: game.isSwitch2 ? style.bandHeight : 0,
            right: 0,
            child: TapBox(
              ringRadius: 15,
              label: saved ? 'Remove ${game.title} from Wish List' : 'Add ${game.title} to Wish List',
              toggled: saved,
              onTap: () {
                tick();
                ref.read(wishlistProvider.notifier).toggle(game.nsuid);
              },
              child: HeartDisc(filled: saved),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small round heart on the art. 30 across inside a 44 tap box.
class HeartDisc extends StatelessWidget {
  const HeartDisc({super.key, required this.filled});

  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), shape: BoxShape.circle),
      child: Icon(
        filled ? PhosphorIconsFill.heart : PhosphorIconsRegular.heart,
        size: 18,
        color: filled ? brandRed : nearBlack,
      ),
    );
  }
}

/// Rank square on the art. 1, 2 and 3 take medal colours in two tones split along the diagonal, then white.
class RankChip extends StatelessWidget {
  const RankChip({super.key, required this.rank});

  final int rank;

  @override
  Widget build(BuildContext context) {
    final label = Text('$rank', style: const TextStyle(color: nearBlack, fontWeight: FontWeight.w700, fontSize: 15, height: 1));
    if (rank > 3) {
      return Container(width: 30, height: 30, color: Colors.white, alignment: Alignment.center, child: label);
    }
    final base = GameCard.medals[rank - 1];
    return CustomPaint(
      size: const Size(30, 30),
      painter: _MedalPainter(light: Color.lerp(base, Colors.white, 0.28)!, dark: Color.lerp(base, Colors.black, 0.1)!),
      child: SizedBox(width: 30, height: 30, child: Center(child: label)),
    );
  }
}

class _MedalPainter extends CustomPainter {
  _MedalPainter({required this.light, required this.dark});

  final Color light;
  final Color dark;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = light);
    canvas.drawPath(
      Path()
        ..moveTo(size.width, 0)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close(),
      Paint()..color = dark,
    );
  }

  @override
  bool shouldRepaint(_MedalPainter old) => old.light != light || old.dark != dark;
}
