import 'package:ringgit_radar/core/api/models.dart';
import 'package:ringgit_radar/core/format.dart';
import 'package:ringgit_radar/core/game_x.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

Game game({String? releaseDate, String releaseText = '', String status = 'onsale'}) => Game(
      nsuid: '1',
      title: 'T',
      publisher: 'P',
      platform: 'switch2',
      category: 'game',
      releaseDate: releaseDate,
      releaseText: releaseText,
      sourceStatus: status,
    );

void main() {
  setUpAll(() => initializeDateFormatting('en'));

  group('money', () {
    test('splits integer sen into grouped whole and two-digit fraction', () {
      expect(splitMinor(0), (whole: '0', fraction: '00'));
      expect(splitMinor(5), (whole: '0', fraction: '05'));
      expect(splitMinor(6480), (whole: '64', fraction: '80'));
      expect(splitMinor(7200), (whole: '72', fraction: '00'));
      expect(splitMinor(129900), (whole: '1,299', fraction: '00'));
      expect(splitMinor(123456789), (whole: '1,234,567', fraction: '89'));
    });

    test('plain money is RM, a no-break space and always two decimals', () {
      expect(plainMoney(1250), 'RM\u00A012.50');
      expect(plainMoney(30000), 'RM\u00A0300.00');
    });
  });

  group('percent', () {
    test('shows the whole percent with OFF', () {
      expect(percentOffLabel(10), '10% OFF');
      expect(percentOffLabel(92), '92% OFF');
    });
  });

  group('Malaysia time', () {
    test('a sale that ends 15 Nov 23:59:59 in Kuala Lumpur reads 15 Nov 11:59 pm', () {
      final end = DateTime.parse('2026-11-15T15:59:59Z');
      expect(shortDateMyt(end), '15 Nov');
      expect(dateTimeMyt(end), '15 Nov 11:59 pm');
      expect(saleEndsMyt(end), 'Sale ends 15 Nov 2026, 11:59 pm');
    });

    test('a sale that starts at 16:00Z reads as the next day, midnight', () {
      final start = DateTime.parse('2026-10-25T16:00:00Z');
      expect(dateTimeMyt(start), '26 Oct 12:00 am');
      expect(longDateMyt(start), '26 Oct 2026');
    });

    test('conversion does not depend on the device zone', () {
      // a UTC instant and the same instant carrying an offset give the same Malaysia time
      final a = DateTime.parse('2026-12-16T15:59:59Z');
      final b = DateTime.parse('2026-12-16T10:59:59-05:00');
      expect(a.isAtSameMomentAs(b), isTrue);
      expect(saleEndsMyt(a), saleEndsMyt(b));
      expect(saleEndsMyt(a), 'Sale ends 16 Dec 2026, 11:59 pm');
    });

    test('release dates have no zone and are not shifted', () {
      expect(releaseDateLabel('2027-03-08'), '8 Mar 2027');
    });

    test('today is the Malaysian calendar day', () {
      // 2026-11-01 17:00Z is already 2 Nov in Kuala Lumpur
      expect(todayMyt(DateTime.parse('2026-11-01T17:00:00Z')), DateTime.utc(2026, 11, 2));
      expect(todayMyt(DateTime.parse('2026-11-01T15:59:59Z')), DateTime.utc(2026, 11, 1));
    });
  });

  group('game labels', () {
    final now = DateTime.parse('2026-11-02T04:00:00Z'); // 2 Nov, midday in Malaysia

    test('NEW covers the last 30 days up to today, not the future', () {
      expect(game(releaseDate: '2026-11-02').isNewAt(now), isTrue);
      expect(game(releaseDate: '2026-10-03').isNewAt(now), isTrue);
      expect(game(releaseDate: '2026-10-02').isNewAt(now), isFalse);
      expect(game(releaseDate: '2026-11-03').isNewAt(now), isFalse);
      expect(game().isNewAt(now), isFalse);
    });

    test('a title with no price shows its date, the source text, or Coming soon', () {
      expect(game(releaseDate: '2027-03-08', status: 'unreleased').noPriceLabel(now), '8 Mar 2027');
      expect(game(releaseText: '2027', status: 'unreleased').noPriceLabel(now), '2027');
      expect(game(status: 'unreleased').noPriceLabel(now), 'Coming soon');
      expect(game(releaseDate: '2026-01-01').noPriceLabel(now), 'Price unavailable');
    });
  });
}
