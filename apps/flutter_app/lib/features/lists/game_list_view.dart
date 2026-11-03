import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../app/theme.dart';
import '../../core/api/models.dart';
import '../../core/format.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/ring.dart';
import 'filter_sheet.dart';
import 'game_grid.dart';
import 'list_controller.dart';
import 'list_spec.dart';

/// A list page body: hint, a sticky "Items: N / Filter / sort" row, the grid, infinite scroll.
/// [query] is owned by the page so the filter sheet and sort menu can change it.
class GameListView extends ConsumerStatefulWidget {
  const GameListView({
    super.key,
    required this.spec,
    required this.query,
    required this.onQuery,
    required this.heroScope,
    this.leading = const [],
    this.emptyText = 'Nothing here yet.',
  });

  final ListSpec spec;
  final ListQuery query;
  final ValueChanged<ListQuery> onQuery;
  final String heroScope;
  final List<Widget> leading;
  final String emptyText;

  @override
  ConsumerState<GameListView> createState() => _GameListViewState();
}

class _GameListViewState extends ConsumerState<GameListView> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_maybePrefetch);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _maybePrefetch() {
    if (!_scroll.hasClients) return;
    // two screens ahead, so the next page is usually there before the end is reached
    if (_scroll.position.extentAfter < _scroll.position.viewportDimension * 2) {
      ref.read(gameListProvider(widget.query).notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameListProvider(widget.query));
    final width = MediaQuery.sizeOf(context).width;
    final pad = pagePadding(width);
    final bottom = width < 840 ? 120.0 : 32.0;

    // a short first page leaves the list without scroll; ask for more until the screen is full
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scroll.hasClients && _scroll.position.maxScrollExtent == 0 && !state.loading && state.hasMore && state.error == null) {
        ref.read(gameListProvider(widget.query).notifier).loadMore();
      }
    });

    return CustomScrollView(
      controller: _scroll,
      slivers: [
        ...widget.leading.map((w) => SliverPadding(padding: EdgeInsets.symmetric(horizontal: pad), sliver: SliverToBoxAdapter(child: w))),
        if (widget.spec.hint != null)
          SliverPadding(
            padding: EdgeInsets.fromLTRB(pad, 4, pad, 8),
            sliver: SliverToBoxAdapter(child: Text(widget.spec.hint!, style: Theme.of(context).textTheme.bodySmall)),
          ),
        SliverPersistentHeader(
          pinned: true,
          delegate: _StickyRow(
            height: 60,
            child: Container(
              color: context.tokens.content,
              padding: EdgeInsets.symmetric(horizontal: pad),
              child: _ItemsRow(
                total: state.initialLoad ? null : state.total,
                spec: widget.spec,
                query: widget.query,
                onQuery: widget.onQuery,
              ),
            ),
          ),
        ),
        if (state.error != null && state.items.isEmpty)
          SliverFillRemaining(hasScrollBody: false, child: ErrorView(message: state.error!, onRetry: () => ref.read(gameListProvider(widget.query).notifier).loadMore()))
        else if (!state.loading && state.items.isEmpty)
          SliverFillRemaining(hasScrollBody: false, child: Center(child: Padding(padding: const EdgeInsets.all(32), child: Text(widget.emptyText, textAlign: TextAlign.center))))
        else
          SliverPadding(
            padding: EdgeInsets.fromLTRB(pad, 4, pad, 0),
            sliver: GameGridSliver(
              games: state.items,
              heroScope: widget.heroScope,
              skeletons: state.hasMore && state.error == null ? (state.items.isEmpty ? 8 : 2) : 0,
            ),
          ),
        if (state.error != null && state.items.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(child: RedButton(label: 'Retry loading more', onTap: () => ref.read(gameListProvider(widget.query).notifier).loadMore())),
            ),
          ),
        SliverToBoxAdapter(child: SizedBox(height: bottom)),
      ],
    );
  }
}

class _StickyRow extends SliverPersistentHeaderDelegate {
  _StickyRow({required this.height, required this.child});

  final double height;
  final Widget child;

  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => child;
  @override
  bool shouldRebuild(_StickyRow old) => true;
}

class _ItemsRow extends StatelessWidget {
  const _ItemsRow({required this.total, required this.spec, required this.query, required this.onQuery});

  final int? total;
  final ListSpec spec;
  final ListQuery query;
  final ValueChanged<ListQuery> onQuery;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final active = activeFilters(query, spec);
    return Row(
      children: [
        Expanded(
          child: total == null
              ? Align(alignment: Alignment.centerLeft, child: Container(width: 88, height: 14, decoration: BoxDecoration(color: tk.skeleton, borderRadius: BorderRadius.circular(7))))
              : Text(itemsLabel(total!), style: const TextStyle(fontSize: 14)),
        ),
        RingTarget(
          radius: 8,
          label: active > 0 ? 'Filter, $active selected' : 'Filter',
          onTap: () async {
            final next = await showFilterSheet(context, query: query, spec: spec);
            if (next != null) onQuery(next);
          },
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(border: Border.all(color: tk.hint, width: 1.5), borderRadius: BorderRadius.circular(8)),
            child: ExcludeSemantics(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(PhosphorIconsRegular.funnel, size: 18, color: tk.text),
                const SizedBox(width: 6),
                Text(active > 0 ? 'Filter ($active)' : 'Filter', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ]),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SortMenu(spec: spec, value: query.sort, onChanged: (s) => onQuery(query.copyWith(sort: s))),
      ],
    );
  }
}

/// The sort dropdown: text, chevron and an underline.
class SortMenu extends StatelessWidget {
  const SortMenu({super.key, required this.spec, required this.value, required this.onChanged});

  final ListSpec spec;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final options = spec.sorts.contains(value) ? spec.sorts : [value, ...spec.sorts];
    return PopupMenuButton<String>(
      tooltip: 'Sort order',
      onSelected: onChanged,
      color: tk.card,
      offset: const Offset(0, 44),
      itemBuilder: (context) => [
        for (final s in options)
          PopupMenuItem<String>(
            value: s,
            height: 48,
            child: Text(sortLabels[s] ?? s, style: TextStyle(fontWeight: s == value ? FontWeight.w700 : FontWeight.w400, color: tk.text)),
          ),
      ],
      child: Semantics(
        button: true,
        label: 'Sort: ${sortLabels[value] ?? value}',
        excludeSemantics: true,
        child: Container(
          height: 44,
          constraints: const BoxConstraints(minWidth: 96),
          alignment: Alignment.center,
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: tk.hint, width: 1.5))),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Flexible(child: Text(sortLabels[value] ?? value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
            const SizedBox(width: 4),
            Icon(PhosphorIconsRegular.caretDown, size: 14, color: tk.text),
          ]),
        ),
      ),
    );
  }
}
