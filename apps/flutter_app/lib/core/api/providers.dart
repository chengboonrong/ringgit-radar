import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/prefs.dart';
import 'api_client.dart';
import 'models.dart';

final highlightsProvider = FutureProvider.autoDispose<Highlights>((ref) => ref.watch(apiClientProvider).highlights());

final rankingProvider =
    FutureProvider.autoDispose.family<List<Game>, String>((ref, platform) => ref.watch(apiClientProvider).ranking(platform));

final genresProvider = FutureProvider<List<GenreCount>>((ref) => ref.watch(apiClientProvider).genres());

final statusProvider = FutureProvider.autoDispose<PriceStatus>((ref) => ref.watch(apiClientProvider).status());

final gameDetailProvider =
    FutureProvider.autoDispose.family<GameDetail, String>((ref, nsuid) => ref.watch(apiClientProvider).detail(nsuid));

/// How many results a filter choice would give, for "Show N results".
final resultCountProvider = FutureProvider.autoDispose.family<int, ListQuery>((ref, query) async {
  final showAll = ref.watch(showAllProvider);
  final page = await ref.watch(apiClientProvider).games(query, showAll: showAll, limit: 1);
  return page.total;
});

/// The wish list as games, on-sale first. Empty list means no request.
final wishlistGamesProvider = FutureProvider.autoDispose<List<Game>>((ref) async {
  final ids = ref.watch(wishlistProvider);
  if (ids.isEmpty) return const [];
  final page = await ref.watch(apiClientProvider).games(
        ListQuery(ids: ids.take(100).toList(), types: const [], sort: 'title'),
        showAll: true,
        limit: 100,
      );
  final byId = {for (final g in page.items) g.nsuid: g};
  final ordered = [for (final id in ids) if (byId[id] != null) byId[id]!];
  // on sale first, otherwise the order they were added in
  return [...ordered.where((g) => g.onSale), ...ordered.where((g) => !g.onSale)];
});
