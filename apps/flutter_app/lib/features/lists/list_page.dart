import 'package:flutter/material.dart';

import '../../core/api/models.dart';
import '../../core/widgets/page_bits.dart';
import 'game_list_view.dart';
import 'list_spec.dart';
import '../../l10n/l10n.dart';

/// A titled, filterable, sortable list over /v1/games. Recent Releases, Coming Soon and Sale use it.
class ListPage extends StatefulWidget {
  const ListPage({super.key, required this.title, required this.spec, required this.scope});

  final String Function(AppLocalizations) title;
  final ListSpec spec;
  final String scope;

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  late ListQuery _query = widget.spec.base;

  @override
  Widget build(BuildContext context) {
    return GameListView(
      spec: widget.spec,
      query: _query,
      onQuery: (q) => setState(() => _query = q),
      heroScope: widget.scope,
      leading: [PageTitle(widget.title(context.l10n))],
      emptyText: context.l10n.noFilterMatch,
    );
  }
}
