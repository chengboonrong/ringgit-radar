import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/api/providers.dart';
import '../../core/format.dart';
import '../../core/storage/prefs.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/page_bits.dart';
import '../../core/widgets/skeleton.dart';
import '../lists/game_grid.dart';

class AboutPage extends ConsumerWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tk = context.tokens;
    final width = MediaQuery.sizeOf(context).width;
    final pad = pagePadding(width);
    final status = ref.watch(statusProvider);
    final mode = ref.watch(themeModeProvider);
    final showAll = ref.watch(showAllProvider);
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(pad, 4, pad, width < 840 ? 120 : 32),
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PageTitle('About'),
              Text('Ringgit Radar is an independent, unofficial app. Not affiliated with or endorsed by Nintendo.', style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 8),
              Text('It keeps its own record of Malaysian eShop prices in ringgit. To buy a game, use your Switch.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: tk.hint)),
              const SizedBox(height: 16),
              Align(alignment: Alignment.centerLeft, child: OutlineChip(label: 'Privacy', onTap: () => context.go('/privacy'))),
              const SectionHeading('Data'),
              status.when(
                loading: () => const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [SkeletonLine(width: 240), SizedBox(height: 12), SkeletonLine(width: 180)]),
                error: (e, _) => SizedBox(height: 180, child: ErrorView(message: e.toString(), onRetry: () => ref.invalidate(statusProvider))),
                data: (s) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Fact('Prices last checked', s.lastRunAt == null ? 'Not yet' : '${longDateTimeMyt(s.lastRunAt!)} (Malaysia time)'),
                    _Fact('Tracking began', s.historySince == null ? 'Not yet' : longDateMyt(s.historySince!)),
                    _Fact('Products tracked', '${s.productCount}'),
                  ],
                ),
              ),
              const SectionHeading('Appearance'),
              Row(
                children: [
                  for (final (m, name) in [(ThemeMode.system, 'System'), (ThemeMode.light, 'Light'), (ThemeMode.dark, 'Dark')]) ...[
                    OutlineChip(label: name, selected: mode == m, onTap: () => ref.read(themeModeProvider.notifier).set(m)),
                    const SizedBox(width: 10),
                  ],
                ],
              ),
              const SectionHeading('Lists'),
              MergeSemantics(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  minTileHeight: 56,
                  title: const Text('Show all titles'),
                  subtitle: Text('Also lists titles hidden by default, such as ones flagged by keyword.', style: TextStyle(color: tk.hint, fontSize: 13)),
                  trailing: Switch(value: showAll, onChanged: (v) => ref.read(showAllProvider.notifier).set(v)),
                  onTap: () => ref.read(showAllProvider.notifier).set(!showAll),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text('$label  ', style: TextStyle(color: tk.hint, fontSize: 14)),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
