import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../app/theme.dart';
import '../../core/api/models.dart';
import '../../core/api/providers.dart';
import '../../core/widgets/art_image.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/page_bits.dart';
import '../../core/widgets/skeleton.dart';
import '../../core/widgets/ring.dart';
import '../lists/game_grid.dart';
import '../lists/game_list_view.dart';
import '../lists/list_spec.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _text = TextEditingController();
  Timer? _debounce;
  // what the results are for; empty means the landing view with banner and genres
  ListQuery _query = const ListQuery();
  bool _browsing = false; // banner or genre tile chosen without a keyword

  bool get _showResults => _browsing || _query.q.trim().isNotEmpty;

  @override
  void dispose() {
    _debounce?.cancel();
    _text.dispose();
    super.dispose();
  }

  void _typed(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) setState(() => _query = _query.copyWith(q: value.trim()));
    });
  }

  void _browse(ListQuery q) => setState(() {
        _query = q.copyWith(q: _text.text.trim());
        _browsing = true;
      });

  void _clear() => setState(() {
        _text.clear();
        _query = const ListQuery();
        _browsing = false;
      });

  @override
  Widget build(BuildContext context) {
    final pad = pagePadding(MediaQuery.sizeOf(context).width);
    final field = _SearchField(controller: _text, onChanged: _typed, onClear: _text.text.isEmpty && !_browsing ? null : _clear);
    final header = Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Some products may not be included.', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          field,
        ],
      ),
    );

    if (_showResults) {
      return GameListView(
        key: const ValueKey('search-results'),
        spec: ListSpec.all,
        query: _query,
        onQuery: (q) => setState(() => _query = q),
        heroScope: 'search',
        leading: [header],
        emptyText: 'No titles found. Try another keyword, or clear a filter.',
      );
    }
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(pad, 4, pad, 0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                header,
                const SizedBox(height: 4),
                _Switch2Banner(onTap: () => _browse(const ListQuery(platforms: ['switch2']))),
                const SectionHeading('Genre'),
              ],
            ),
          ),
        ),
        _GenreTiles(pad: pad, onPick: (name) => _browse(ListQuery(genres: [name]))),
        SliverToBoxAdapter(child: SizedBox(height: MediaQuery.sizeOf(context).width < 840 ? 120 : 32)),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged, required this.onClear});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Semantics(
      textField: true,
      label: 'Search by keyword/title',
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          hintText: 'Search by keyword/title',
          hintStyle: TextStyle(color: tk.hint, fontSize: 16),
          filled: true,
          fillColor: tk.card,
          isDense: false,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          prefixIcon: Icon(PhosphorIconsRegular.magnifyingGlass, color: tk.hint),
          suffixIcon: onClear == null ? null : TapBox(label: 'Clear search', onTap: onClear!, child: Icon(PhosphorIconsRegular.x, color: tk.text, size: 20)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide(color: tk.divider)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide(color: tk.divider)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: const BorderSide(color: brandRed, width: 2)),
        ),
      ),
    );
  }
}

class _Switch2Banner extends StatelessWidget {
  const _Switch2Banner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return RingTarget(
      radius: 8,
      label: 'Switch 2, View All Software',
      onTap: onTap,
      child: Container(
        height: 96,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(color: brandRed, borderRadius: BorderRadius.circular(8)),
        child: ExcludeSemantics(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Switch 2', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 24, height: 1.2)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                      child: const Text('View All Software', style: TextStyle(color: brandRed, fontWeight: FontWeight.w700, fontSize: 13, height: 1.3)),
                    ),
                  ],
                ),
              ),
              const Icon(PhosphorIconsBold.caretRight, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _GenreTiles extends ConsumerWidget {
  const _GenreTiles({required this.pad, required this.onPick});

  final double pad;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tk = context.tokens;
    final cols = columnsFor(MediaQuery.sizeOf(context).width);
    final genres = ref.watch(genresProvider);
    const gap = 12.0;
    const inset = 8.0;
    const titleRow = 44.0;
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: pad),
      sliver: SliverLayoutBuilder(
        builder: (context, c) {
          final w = (c.crossAxisExtent - gap * (cols - 1)) / cols;
          final art = w - inset * 2;
          final extent = titleRow + art * 9 / 16 + inset;
          SliverGridDelegate delegate() => SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: cols, mainAxisSpacing: gap, crossAxisSpacing: gap, mainAxisExtent: extent);
          return genres.when(
            loading: () => SliverGrid.builder(
              gridDelegate: delegate(),
              itemCount: cols * 3,
              itemBuilder: (context, i) => ExcludeSemantics(
                child: Container(
                  decoration: BoxDecoration(color: tk.card, borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.fromLTRB(inset, 0, inset, inset),
                  child: Column(children: [
                    const SizedBox(height: titleRow, child: Align(alignment: Alignment.centerLeft, child: SkeletonLine(width: 80))),
                    AspectRatio(aspectRatio: 16 / 9, child: ClipRRect(borderRadius: BorderRadius.circular(6), child: ColoredBox(color: tk.skeleton))),
                  ]),
                ),
              ),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: Column(children: [
                Text(e.toString()),
                const SizedBox(height: 8),
                RedButton(label: 'Retry', onTap: () => ref.invalidate(genresProvider)),
              ]),
            ),
            data: (list) => SliverGrid.builder(
              gridDelegate: delegate(),
              itemCount: list.length,
              itemBuilder: (context, i) => RingTarget(
                radius: 8,
                label: '${list[i].name}, ${list[i].count} games',
                onTap: () => onPick(list[i].name),
                child: Container(
                  decoration: BoxDecoration(color: tk.card, borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.fromLTRB(inset, 0, inset, inset),
                  child: ExcludeSemantics(
                    child: Column(
                      children: [
                        SizedBox(
                          height: titleRow,
                          child: Row(
                            children: [
                              Expanded(child: Text(list[i].name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16))),
                              Text('${list[i].count}', style: TextStyle(color: tk.hint, fontSize: 13)),
                            ],
                          ),
                        ),
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: ClipRRect(borderRadius: BorderRadius.circular(6), child: ArtImage(hash: list[i].cover, logicalWidth: art)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
