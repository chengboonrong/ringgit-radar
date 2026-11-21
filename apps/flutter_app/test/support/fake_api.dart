import 'package:ringgit_radar/core/api/api_client.dart';
import 'package:ringgit_radar/core/api/models.dart';

import 'fixtures.dart' as fx;

/// Answers every request at once from the fixtures.
class FakeApiClient extends ApiClient {
  @override
  Future<GamePage> games(ListQuery q, {required bool showAll, int page = 1, int limit = 24}) async =>
      GamePage(items: page == 1 ? fx.games.take(limit).toList() : const [], total: fx.games.length, page: page);
  @override
  Future<Highlights> highlights() async => fx.highlights;
  @override
  Future<List<Game>> ranking(String platform) async => fx.games.where((g) => g.price?.onSale == true).toList();
  @override
  Future<List<GenreCount>> genres() async => fx.genres;
  @override
  Future<PriceStatus> status() async => fx.status;
  @override
  Future<GameDetail> detail(String nsuid) async => fx.detailOf(fx.games.firstWhere((g) => g.nsuid == nsuid));
}
