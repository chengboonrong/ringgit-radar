import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../app/theme.dart';
import '../../core/api/models.dart';
import '../../core/api/providers.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/ring.dart';
import '../../core/widgets/skeleton.dart';
import 'list_spec.dart';

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

const _types = [('game', 'Game'), ('bundle', 'Bundle'), ('addon', 'Add-on')];
const _platforms = [('switch2', 'Switch 2'), ('switch', 'Switch')];
const _ages = [3, 7, 12, 16, 18];
const _caps = [(2000, 'Up to RM 20'), (5000, 'Up to RM 50'), (10000, 'Up to RM 100'), (20000, 'Up to RM 200')];

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
    final label = count.maybeWhen(data: (n) => 'Show ${NumberFormat.decimalPattern('en').format(n)} results', orElse: () => 'Show results');
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: Row(
            children: [
              TapBox(
                label: _section == null ? 'Close filters' : 'Back to filters',
                onTap: () => _section == null ? Navigator.of(context).pop() : setState(() => _section = null),
                child: Icon(_section == null ? PhosphorIconsRegular.x : PhosphorIconsRegular.arrowLeft, color: tk.text),
              ),
              Expanded(child: Text(_sectionTitle(), style: Theme.of(context).textTheme.titleMedium)),
              if (_section == null)
                TextButton(
                  onPressed: () => setState(() => _draft = widget.spec.base),
                  style: TextButton.styleFrom(minimumSize: const Size(64, 44), foregroundColor: tk.text),
                  child: const Text('Clear', style: TextStyle(fontWeight: FontWeight.w700)),
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

  String _sectionTitle() => switch (_section) {
        'type' => 'Product Type',
        'platform' => 'Platform',
        'genre' => 'Genre',
        'price' => 'On Sale / Price Cap',
        'age' => 'Age Rating',
        _ => 'Filter',
      };

  Widget _root() {
    final priceCount = (_draft.sale && !widget.spec.lockSale ? 1 : 0) + (_draft.maxPrice != null ? 1 : 0);
    Widget row(String id, String name, int n) => _SectionRow(label: n > 0 ? '$name ($n)' : name, onTap: () => setState(() => _section = id));
    return Column(
      children: [
        row('type', 'Product Type', _draft.types.length),
        row('platform', 'Platform', _draft.platforms.length),
        row('genre', 'Genre', _draft.genres.length),
        row('price', 'On Sale / Price Cap', priceCount),
        row('age', 'Age Rating', _draft.ages.length),
      ],
    );
  }

  Widget _options() {
    switch (_section) {
      case 'type':
        return Column(children: [
          for (final (id, name) in _types)
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
                label: '${g.name} (${g.count})',
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
          error: (e, _) => SizedBox(height: 240, child: ErrorView(message: e.toString(), onRetry: () => ref.invalidate(genresProvider))),
        );
      case 'age':
        return Column(children: [
          for (final a in _ages)
            _CheckRow(
              label: 'Age $a (UK PEGI)',
              checked: _draft.ages.contains(a),
              onChanged: () => setState(() => _draft = _draft.copyWith(ages: _draft.ages.contains(a) ? [..._draft.ages.where((e) => e != a)] : [..._draft.ages, a])),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Text('Games with no rating found stay in the list until you pick an age.', style: Theme.of(context).textTheme.bodySmall),
          ),
        ]);
      default:
        return Column(children: [
          if (!widget.spec.lockSale)
            _CheckRow(label: 'On sale only', checked: _draft.sale, onChanged: () => setState(() => _draft = _draft.copyWith(sale: !_draft.sale))),
          for (final (sen, name) in _caps)
            _CheckRow(
              label: name,
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
