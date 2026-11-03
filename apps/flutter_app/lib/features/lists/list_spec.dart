import '../../core/api/models.dart';

const sortLabels = {
  'savings': 'Biggest savings',
  'discount': 'Biggest discount',
  'price': 'Lowest price',
  'newest': 'Newest',
  'ending': 'Ending soon',
  'title': 'Title',
  'soonest': 'Soonest',
};

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
  final String? hint;
  final bool lockSale;

  static const all = ListSpec(base: ListQuery());
  static const sale = ListSpec(
    base: ListQuery(sale: true),
    hint: 'Sale end dates are shown in Malaysia time.',
    lockSale: true,
  );
  static const recent = ListSpec(
    base: ListQuery(release: 'recent', sort: 'newest'),
    sorts: ['newest', 'savings', 'discount', 'price', 'title'],
  );
  static const comingSoon = ListSpec(
    base: ListQuery(release: 'upcoming', sort: 'soonest'),
    sorts: ['soonest', 'title', 'price'],
    hint: 'Release dates come from the store listing.',
  );
}

/// How many filters differ from the starting point, for the Filter button.
int activeFilters(ListQuery q, ListSpec spec) {
  var n = 0;
  if (q.platforms.isNotEmpty) n++;
  if (q.genres.isNotEmpty) n++;
  if (q.types.length != 1 || q.types.first != 'game') n++;
  if (q.ages.isNotEmpty) n++;
  if (q.sale && !spec.lockSale) n++;
  if (q.maxPrice != null) n++;
  return n;
}
