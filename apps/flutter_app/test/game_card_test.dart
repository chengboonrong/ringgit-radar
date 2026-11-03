import 'package:ringgit_radar/app/theme.dart';
import 'package:ringgit_radar/core/api/models.dart';
import 'package:ringgit_radar/core/storage/prefs.dart';
import 'package:ringgit_radar/core/widgets/art_image.dart';
import 'package:ringgit_radar/core/widgets/game_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

Game game(String id, String platform, {bool sale = true, String title = 'A very long title that cannot fit on one line of a narrow card'}) => Game(
      nsuid: id,
      title: title,
      publisher: 'P',
      platform: platform,
      category: 'game',
      price: Price(
        currency: 'MYR',
        regularMinor: 129900,
        currentMinor: sale ? 12990 : 129900,
        onSale: sale,
        discountMinor: sale ? 12990 : null,
        percentOff: sale ? 90 : 0,
        savedMinor: sale ? 116910 : 0,
        discountEnd: sale ? DateTime.utc(2026, 11, 15, 15, 59, 59) : null,
      ),
    );

Future<void> pump(WidgetTester t, List<Game> games, {double textScale = 1, double width = 171, GameCardStyle style = GameCardStyle.list}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  await t.pumpWidget(ProviderScope(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    child: MaterialApp(
      theme: buildTheme(Brightness.light),
      builder: (context, child) => MediaQuery(data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)), child: child!),
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [for (final g in games) GameCard(game: g, width: width, heroScope: 'test', style: style)],
          ),
        ),
      ),
    ),
  ));
}

void main() {
  setUpAll(() => initializeDateFormatting('en'));

  for (final scale in [1.0, 1.3]) {
    testWidgets('a sale card at text scale $scale fits its body without overflow', (t) async {
      await pump(t, [game('1', 'switch2'), game('2', 'switch'), game('3', 'switch', sale: false)], textScale: scale);
      expect(t.takeException(), isNull);
      expect(find.text('Ends 15 Nov'), findsNWidgets(2));
    });

    testWidgets('a tile at text scale $scale fits its body without overflow', (t) async {
      await pump(t, [game('1', 'switch2')], textScale: scale, width: 300, style: GameCardStyle.tile);
      expect(t.takeException(), isNull);
    });
  }

  testWidgets('art lines up across a Switch 2 card and a Switch card, which is a band shorter', (t) async {
    await pump(t, [game('1', 'switch2'), game('2', 'switch')]);
    final arts = find.byType(ArtImage);
    expect(t.getTopLeft(arts.at(0)).dy, t.getTopLeft(arts.at(1)).dy);
    final cards = find.byType(GameCard);
    final h2 = t.getSize(find.descendant(of: cards.at(0), matching: find.byType(ClipRRect)).first).height;
    final h1 = t.getSize(find.descendant(of: cards.at(1), matching: find.byType(ClipRRect)).first).height;
    expect(h2 - h1, GameCardStyle.list.bandHeight);
    // both sit on the same bottom edge of the cell
    expect(t.getBottomLeft(cards.at(0)).dy, t.getBottomLeft(cards.at(1)).dy);
  });

  test('card height grows with the text scale up to 1.3 and not past it', () {
    final base = GameCardStyle.list.heightFor(171);
    expect(GameCardStyle.list.heightFor(171, textScale: 1.3), closeTo(base + GameCardStyle.list.bodyHeight * 0.3, 0.001));
    expect(GameCardStyle.list.heightFor(171, textScale: 2), GameCardStyle.list.heightFor(171, textScale: 1.3));
    expect(GameCardStyle.list.heightFor(171, band: false), base - GameCardStyle.list.bandHeight);
    expect(GameCardStyle.list.bodyHeight, 72);
    expect(GameCardStyle.tile.bodyHeight, 80);
  });
}
