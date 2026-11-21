import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../app/theme.dart';
import '../../core/api/models.dart';
import '../../core/api/providers.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/ring.dart';
import '../../core/widgets/skeleton.dart';
import 'list_spec.dart';
import '../../l10n/l10n.dart';
import '../../l10n/genres.dart';

/// Opens the filter bottom sheet. Returns the chosen query, or null if it was dismissed.
Future<ListQuery?> showFilterSheet(BuildContext context, {required ListQuery query, required ListSpec spec}) {
  return showModalBottomSheet<ListQuery>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
    backgroundColor: context.tokens.sidebar,
    constraints: const BoxConstraints(maxWidth: 560),
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (context) => FractionallySizedBox(heightFactor: 0.82, child: _FilterSheet(initial: query, spec: spec)),
  );
}

List<(String, String)> _types(AppLocalizations l) => [('game', l.kindGame), ('bundle', l.kindBundle), ('addon', l.kindAddon)];
const _platforms = [('switch2', 'Switch 2'), ('switch', 'Switch')];
const _caps = [2000, 5000, 10000, 20000];

class _FilterSheet extends ConsumerStatefulWidget {
  const _FilterSheet({required this.initial, required this.spec});

  final ListQuery initial;
  final ListSpec spec;

  @override
  ConsumerState<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<_FilterSheet> {
  late ListQuery _draft = widget.initial;
  String? _section;

  List<String> _toggle(List<String> list, String v, {bool keepOne = false}) {
    if (list.contains(v)) {
      if (keepOne && list.length == 1) return list;
      return [...list.where((e) => e != v)];
    }
    return [...list, v];
  }

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final count = ref.watch(resultCountProvider(_draft));
    final l = context.l10n;
    final label = count.maybeWhen(data: l.showResults, orElse: () => l.showResultsNoCount);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: Row(
            children: [
              TapBox(
                label: _section == null ? l.closeFilters : l.backToFilters,
                onTap: () => _section == null ? Navigator.of(context).pop() : setState(() => _section = null),
                child: Icon(_section == null ? PhosphorIconsRegular.x : PhosphorIconsRegular.arrowLeft, color: tk.text),
              ),
              Expanded(child: Text(_sectionTitle(l), style: Theme.of(context).textTheme.titleMedium)),
              if (_section == null)
                TextButton(
                  onPressed: () => setState(() => _draft = widget.spec.base),
                  style: TextButton.styleFrom(minimumSize: const Size(64, 44), foregroundColor: tk.text),
                  child: Text(l.clear, style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
            ],
          ),
        ),
        Divider(height: 1, color: tk.divider),
        Expanded(child: SingleChildScrollView(child: _section == null ? _root() : _options())),
        Divider(height: 1, color: tk.divider),
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: RedButton(label: label, expand: true, onTap: () => Navigator.of(context).pop(_draft)),
          ),
        ),
      ],
    );
  }

  String _sectionTitle(AppLocalizations l) => switch (_section) {
        'type' => l.filterProductType,
        'platform' => l.platform,
        'genre' => l.genre,
        'price' => l.filterPrice,
        _ => l.filter,
      };

  Widget _root() {
    final l = context.l10n;
    final priceCount = (_draft.sale && !widget.spec.lockSale ? 1 : 0) + (_draft.maxPrice != null ? 1 : 0);
    Widget row(String id, String name, int n) => _SectionRow(label: n > 0 ? '$name ($n)' : name, onTap: () => setState(() => _section = id));
    return Column(
      children: [
        row('type', l.filterProductType, _draft.types.length),
        row('platform', l.platform, _draft.platforms.length),
        row('genre', l.genre, _draft.genres.length),
        row('price', l.filterPrice, priceCount),
      ],
    );
  }

  Widget _options() {
    final l = context.l10n;
    switch (_section) {
      case 'type':
        return Column(children: [
          for (final (id, name) in _types(l))
            _CheckRow(
              label: name,
              checked: _draft.types.contains(id),
              onChanged: () => setState(() => _draft = _draft.copyWith(types: _toggle(_draft.types, id, keepOne: true))),
            ),
        ]);
      case 'platform':
        return Column(children: [
          for (final (id, name) in _platforms)
            _CheckRow(
              label: name,
              checked: _draft.platforms.contains(id),
              onChanged: () => setState(() => _draft = _draft.copyWith(platforms: _toggle(_draft.platforms, id))),
            ),
        ]);
      case 'genre':
        final genres = ref.watch(genresProvider);
        return genres.when(
          data: (list) => Column(children: [
            for (final g in list)
              _CheckRow(
                label: '${genreLabel(l, g.name)} (${g.count})',
                checked: _draft.genres.contains(g.name),
                onChanged: () => setState(() => _draft = _draft.copyWith(genres: _toggle(_draft.genres, g.name))),
              ),
          ]),
          loading: () => const Padding(
            padding: EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SkeletonLine(width: 160), SizedBox(height: 28), SkeletonLine(width: 120), SizedBox(height: 28), SkeletonLine(width: 190),
            ]),
          ),
          error: (e, _) => SizedBox(height: 240, child: ErrorView(error: e, onRetry: () => ref.invalidate(genresProvider))),
        );
      default:
        return Column(children: [
          if (!widget.spec.lockSale)
            _CheckRow(label: l.onSaleOnly, checked: _draft.sale, onChanged: () => setState(() => _draft = _draft.copyWith(sale: !_draft.sale))),
          for (final sen in _caps)
            _CheckRow(
              label: l.upToRm(sen ~/ 100),
              checked: _draft.maxPrice == sen,
              onChanged: () => setState(() => _draft = _draft.copyWith(maxPrice: _draft.maxPrice == sen ? null : sen)),
            ),
        ]);
    }
  }
}

class _SectionRow extends StatelessWidget {
  const _SectionRow({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Semantics(
      button: true,
      label: label,
      onTap: onTap,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 60),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: tk.divider))),
          child: Row(
            children: [
              Expanded(child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
              Icon(PhosphorIconsRegular.caretRight, color: tk.hint),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({required this.label, required this.checked, required this.onChanged});

  final String label;
  final bool checked;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Semantics(
      checked: checked,
      label: label,
      onTap: onChanged,
      excludeSemantics: true,
      child: InkWell(
        onTap: onChanged,
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: tk.divider.withValues(alpha: 0.6)))),
          child: Row(
            children: [
              IgnorePointer(child: Checkbox(value: checked, onChanged: (_) {})),
              const SizedBox(width: 4),
              Expanded(child: Text(label, style: const TextStyle(fontSize: 15))),
            ],
          ),
        ),
      ),
    );
  }
}
