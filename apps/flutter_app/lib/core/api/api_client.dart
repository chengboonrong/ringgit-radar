import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models.dart';

/// Set with --dart-define=API_BASE=https://host. The default is the local dev server. An empty value
/// (--dart-define=API_BASE=) means same-origin: every request is a path like /v1/games, for a build
/// the API serves itself.
const apiBase = String.fromEnvironment('API_BASE', defaultValue: 'http://127.0.0.1:8088');

/// An API failure phrased for the person looking at the screen.
class ApiException implements Exception {
  ApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Where art comes from: the store's own image server, full size (1920x1080). Ringgit Radar keeps no copies.
String imageUrl(String hash) => 'https://img-eshop.cdn.nintendo.net/i/$hash.jpg';

/// Picks the decode width that covers [logicalWidth] at [pixelRatio] without going far over.
int imageWidthFor(double logicalWidth, double pixelRatio) {
  final px = logicalWidth * pixelRatio;
  if (px <= 320) return 320;
  if (px <= 640) return 640;
  return 1280;
}

class ApiClient {
  ApiClient([Dio? dio])
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: apiBase,
              connectTimeout: const Duration(seconds: 8),
              receiveTimeout: const Duration(seconds: 20),
            ));

  final Dio _dio;

  Future<T> _get<T>(String what, String path, T Function(dynamic json) parse, [Map<String, dynamic>? query]) async {
    try {
      final res = await _dio.get<dynamic>(path, queryParameters: query);
      return parse(res.data);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status != null) throw ApiException("Couldn't load $what. The server answered $status.");
      throw ApiException("Couldn't load $what. The Ringgit Radar server can't be reached.");
    } on Object {
      throw ApiException("Couldn't load $what. The answer was not in the expected shape.");
    }
  }

  Map<String, dynamic> params(ListQuery q, {required bool showAll, int page = 1, int limit = 24}) => {
        if (q.q.trim().isNotEmpty) 'q': q.q.trim(),
        if (q.platforms.isNotEmpty) 'platform': q.platforms.join(','),
        if (q.types.isNotEmpty) 'type': q.types.join(','),
        if (q.genres.isNotEmpty) 'genre': q.genres.join(','),
        if (q.ages.isNotEmpty) 'age': q.ages.join(','),
        if (q.sale) 'sale': '1',
        if (q.maxPrice != null) 'max_price': q.maxPrice,
        'sort': q.sort,
        if (q.release != null) 'release': q.release,
        if (q.ids.isNotEmpty) 'ids': q.ids.join(','),
        if (showAll) 'all': '1',
        'page': page,
        'limit': limit,
      };

  Future<GamePage> games(ListQuery q, {required bool showAll, int page = 1, int limit = 24}) =>
      _get('the list', '/v1/games', (j) => GamePage.fromJson(j as Map<String, dynamic>),
          params(q, showAll: showAll, page: page, limit: limit));

  Future<Highlights> highlights() =>
      _get('Highlights', '/v1/highlights', (j) => Highlights.fromJson(j as Map<String, dynamic>));

  Future<List<Game>> ranking(String platform) => _get(
        'the ranking',
        '/v1/ranking',
        (j) => GamePage.fromJson(j as Map<String, dynamic>).items,
        {'platform': platform},
      );

  Future<List<GenreCount>> genres() => _get(
        'genres',
        '/v1/genres',
        (j) => [for (final g in (j as Map<String, dynamic>)['items'] as List) GenreCount.fromJson(g as Map<String, dynamic>)],
      );

  Future<PriceStatus> status() =>
      _get('data status', '/v1/status/prices', (j) => PriceStatus.fromJson(j as Map<String, dynamic>));

  Future<GameDetail> detail(String nsuid) =>
      _get('this game', '/v1/games/$nsuid', (j) => GameDetail.fromJson(j as Map<String, dynamic>));
}

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());
