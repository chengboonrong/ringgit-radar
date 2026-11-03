import 'package:flutter/material.dart';

import '../../core/api/models.dart';
import '../../core/widgets/page_bits.dart';
import 'game_list_view.dart';
import 'list_spec.dart';

/// A titled, filterable, sortable list over /v1/games. Recent Releases, Coming Soon and Sale use it.
class ListPage extends StatefulWidget {
  const ListPage({super.key, required this.title, required this.spec, required this.scope});

  final String title;
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
      leading: [PageTitle(widget.title)],
      emptyText: 'No titles match these filters. Clear a filter to see more.',
    );
  }
}
