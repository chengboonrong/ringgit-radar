import 'package:ringgit_radar/core/api/api_client.dart';
import 'package:ringgit_radar/core/api/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('image urls', () {
    test('an empty API_BASE gives same-origin paths', () {
      expect(imageUrl('abc', width: 320, base: ''), '/v1/img/abc?w=320');
    });

    test('a base is put in front', () {
      expect(imageUrl('abc', base: 'http://127.0.0.1:8088'), 'http://127.0.0.1:8088/v1/img/abc?w=640');
    });
  });

  group('list query to request', () {
    final api = ApiClient();

    test('an age filter is sent as a comma list, and left out when empty', () {
      expect(api.params(const ListQuery(ages: [12, 16]), showAll: false)['age'], '12,16');
      expect(api.params(const ListQuery(), showAll: false).containsKey('age'), isFalse);
    });

    test('show all titles adds all=1', () {
      expect(api.params(const ListQuery(), showAll: true)['all'], '1');
      expect(api.params(const ListQuery(), showAll: false).containsKey('all'), isFalse);
    });

    test('a price cap is sent in sen', () {
      expect(api.params(const ListQuery(maxPrice: 5000), showAll: false)['max_price'], 5000);
    });
  });

  group('game json', () {
    const base = {'nsuid': '1', 'title': 'T', 'publisher': 'P', 'platform': 'switch2', 'category': 'game', 'price': null};

    test('a game with no rating has a null age and null descriptors', () {
      final g = Game.fromJson({...base, 'age': null, 'age_descriptors': null});
      expect(g.age, isNull);
      expect(g.ageDescriptors, isNull);
    });

    test('a rated game keeps its age and descriptors', () {
      final g = Game.fromJson({...base, 'age': 12, 'age_descriptors': ['Violence', 'Bad Language']});
      expect(g.age, 12);
      expect(g.ageDescriptors, ['Violence', 'Bad Language']);
    });

    test('money stays integer sen through json', () {
      final g = Game.fromJson({
        ...base,
        'price': {'currency': 'MYR', 'regular_minor': 7200, 'current_minor': 6480, 'on_sale': true, 'discount_minor': 6480, 'percent_off': 10, 'saved_minor': 720, 'discount_end': '2026-11-15T15:59:59Z'},
      });
      expect(g.price!.currentMinor, 6480);
      expect(g.price!.percentOff, 10);
      expect(g.price!.discountEnd, DateTime.utc(2026, 11, 15, 15, 59, 59));
    });
  });
}
