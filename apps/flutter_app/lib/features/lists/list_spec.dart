import '../../core/api/models.dart';
import '../../l10n/l10n.dart';

/// The shown name of a sort value. An unknown value shows as it is.
String sortLabel(AppLocalizations l, String sort) => switch (sort) {
      'savings' => l.sortSavings,
      'discount' => l.sortDiscount,
      'price' => l.sortPrice,
      'newest' => l.sortNewest,
      'ending' => l.sortEnding,
      'title' => l.sortTitle,
      'soonest' => l.sortSoonest,
      _ => sort,
    };

String _saleHint(AppLocalizations l) => l.saleHint;
String _comingSoonHint(AppLocalizations l) => l.comingSoonHint;

/// What a list page fixes and offers. [base] is where the list starts and what "clear" returns to.
class ListSpec {
  const ListSpec({
    required this.base,
    this.sorts = const ['savings', 'discount', 'price', 'newest', 'ending', 'title'],
    this.hint,
    this.lockSale = false,
  });

  final ListQuery base;
  final List<String> sorts;
  final String Function(AppLocalizations)? hint;
  final bool lockSale;

  static const all = ListSpec(base: ListQuery());
  static const sale = ListSpec(
    base: ListQuery(sale: true),
    hint: _saleHint,
    lockSale: true,
  );
  static const recent = ListSpec(
    base: ListQuery(release: 'recent', sort: 'newest'),
    sorts: ['newest', 'savings', 'discount', 'price', 'title'],
  );
  static const comingSoon = ListSpec(
    base: ListQuery(release: 'upcoming', sort: 'soonest'),
    sorts: ['soonest', 'title', 'price'],
    hint: _comingSoonHint,
  );
}

/// How many filters differ from the starting point, for the Filter button.
int activeFilters(ListQuery q, ListSpec spec) {
  var n = 0;
  if (q.platforms.isNotEmpty) n++;
  if (q.genres.isNotEmpty) n++;
  if (q.types.length != 1 || q.types.first != 'game') n++;
  if (q.sale && !spec.lockSale) n++;
  if (q.maxPrice != null) n++;
  return n;
}
