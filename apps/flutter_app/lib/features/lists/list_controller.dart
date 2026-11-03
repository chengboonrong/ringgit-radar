import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../core/api/models.dart';
import '../../core/storage/prefs.dart';

class GameListState {
  const GameListState({this.items = const [], this.total = 0, this.pages = 0, this.loading = true, this.error});

  final List<Game> items;
  final int total;
  final int pages;
  final bool loading;
  final String? error;

  bool get hasMore => pages == 0 || items.length < total;
  bool get initialLoad => pages == 0 && error == null;

  GameListState copyWith({List<Game>? items, int? total, int? pages, bool? loading, String? error, bool clearError = false}) =>
      GameListState(
        items: items ?? this.items,
        total: total ?? this.total,
        pages: pages ?? this.pages,
        loading: loading ?? this.loading,
        error: clearError ? null : (error ?? this.error),
      );
}

const listPageSize = 24;

/// Pages through /v1/games for one query. Infinite scroll calls [loadMore].
class GameListController extends Notifier<GameListState> {
  GameListController(this.query);

  final ListQuery query;
  bool _busy = false;

  @override
  GameListState build() {
    ref.watch(showAllProvider);
    Future.microtask(loadMore);
    return const GameListState();
  }

  Future<void> loadMore() async {
    if (_busy || !state.hasMore) return;
    _busy = true;
    state = state.copyWith(loading: true, clearError: true);
    try {
      final page = await ref.read(apiClientProvider).games(
            query,
            showAll: ref.read(showAllProvider),
            page: state.pages + 1,
            limit: listPageSize,
          );
      if (!ref.mounted) return;
      state = state.copyWith(items: [...state.items, ...page.items], total: page.total, pages: state.pages + 1, loading: false);
    } on ApiException catch (e) {
      if (ref.mounted) state = state.copyWith(loading: false, error: e.message);
    } finally {
      _busy = false;
    }
  }
}

final gameListProvider = NotifierProvider.autoDispose.family<GameListController, GameListState, ListQuery>(GameListController.new);
