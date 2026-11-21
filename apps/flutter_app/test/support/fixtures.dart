import 'package:ringgit_radar/core/api/models.dart';

/// 23:59:59 on 31 Dec in Malaysia.
final saleEnd = DateTime.utc(2026, 12, 31, 15, 59, 59);

Price sale(int regular, int current, int percent) => Price(
      currency: 'MYR',
      regularMinor: regular,
      currentMinor: current,
      onSale: true,
      discountMinor: current,
      percentOff: percent,
      savedMinor: regular - current,
      discountStart: DateTime.utc(2026, 11, 1),
      discountEnd: saleEnd,
    );

Price regular(int minor) => Price(currency: 'MYR', regularMinor: minor, currentMinor: minor, onSale: false);

/// Titles as long as the longest real ones, so a translated label next to them is tested at its worst.
final games = [
  Game(nsuid: '70010000000001', title: 'The Legend of Zelda: Tears of the Kingdom – Nintendo Switch 2 Edition', publisher: 'Nintendo', platform: 'switch2', category: 'game', releaseDate: '2025-06-05', price: sale(32900, 26320, 20), rank: 1),
  Game(nsuid: '70010000000002', title: 'Atelier Ryza 3: Alchemist of the End & the Secret Key Ultimate Edition', publisher: 'KOEI TECMO GAMES CO., LTD.', platform: 'switch', category: 'bundle', releaseDate: '2023-03-24', price: sale(129900, 64950, 50), rank: 2),
  Game(nsuid: '70010000000003', title: 'Mario + Rabbids Sparks of Hope Gold Edition', publisher: 'Ubisoft', platform: 'switch', category: 'addon', releaseDate: '2022-10-20', price: sale(24900, 2490, 90), rank: 3),
  Game(nsuid: '70010000000004', title: 'Pokémon Legends: Z-A Nintendo Switch 2 Edition', publisher: 'The Pokémon Company', platform: 'switch2', category: 'game', releaseDate: '2027-03-08', sourceStatus: 'unreleased', salesStatus: 'preorder'),
  Game(nsuid: '70010000000005', title: 'Untitled Puzzle Game With No Price Yet', publisher: 'Indie', platform: 'switch', category: 'game', sourceStatus: 'unreleased'),
  Game(nsuid: '70010000000006', title: 'Stardew Valley', publisher: 'ConcernedApe', platform: 'switch', category: 'game', releaseDate: '2026-11-10', price: regular(5500)),
];

final onSaleGame = games.first;

final highlights = Highlights(topSavings: [games[0], games[1]], endingSoon: [games[0], games[1], games[2]], newSales: [games[2], games[1]]);

final genres = [
  for (final (n, c) in [('Action', 1727), ('First-Person Shooter', 68), ('Communication', 134), ('Board Game', 183), ('Visual Novel Deluxe', 3)])
    GenreCount(name: n, count: c),
];

final status = PriceStatus(lastRunAt: DateTime.utc(2026, 11, 20, 16, 10), productCount: 7827, historySince: DateTime.utc(2026, 10, 1));

GameDetail detailOf(Game g) => GameDetail(
      nsuid: g.nsuid,
      title: g.title,
      publisher: g.publisher,
      platform: g.platform,
      category: g.category,
      releaseDate: g.releaseDate,
      price: g.price,
      genres: const ['Action', 'Adventure', 'Visual Novel Deluxe'],
      description: 'A long English description from the store. ' * 6,
      players: '1-4',
      history: [
        HistoryPoint(observedAt: DateTime.utc(2026, 10, 1), regularMinor: 32900, priceMinor: 32900),
        HistoryPoint(observedAt: DateTime.utc(2026, 11, 1), regularMinor: 32900, priceMinor: 26320, discountEnd: saleEnd),
      ],
      firstObservedAt: DateTime.utc(2026, 10, 1),
      lowest: Lowest(priceMinor: 26320, since: DateTime.utc(2026, 11, 1), isSale: true),
      addons: [games[2]],
      age: 12,
      ageDescriptors: const ['Violence'],
    );
