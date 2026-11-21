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
import '../../l10n/l10n.dart';

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
    final locale = ref.watch(localeProvider);
    final l = context.l10n;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(pad, 4, pad, width < 840 ? 120 : 32),
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageTitle(l.aboutTitle),
              Text(l.aboutUnofficial, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 8),
              Text(l.aboutRecord, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: tk.hint)),
              const SizedBox(height: 16),
              Wrap(spacing: 8, runSpacing: 8, children: [
                OutlineChip(label: l.privacy, onTap: () => context.go('/privacy')),
                OutlineChip(label: l.dataSourcesTitle, onTap: () => context.go('/data-sources')),
              ]),
              SectionHeading(l.dataHeading),
              status.when(
                loading: () => const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [SkeletonLine(width: 240), SizedBox(height: 12), SkeletonLine(width: 180)]),
                error: (e, _) => SizedBox(height: 180, child: ErrorView(error: e, onRetry: () => ref.invalidate(statusProvider))),
                data: (s) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Fact(l.pricesLastChecked, s.lastRunAt == null ? l.notYet : l.malaysiaTime(longDateTimeMyt(s.lastRunAt!, l.localeName))),
                    _Fact(l.trackingBeganLabel, s.historySince == null ? l.notYet : longDateMyt(s.historySince!, l.localeName)),
                    _Fact(l.productsTracked, '${s.productCount}'),
                  ],
                ),
              ),
              SectionHeading(l.appearanceHeading),
              Row(
                children: [
                  for (final (m, name) in [(ThemeMode.system, l.themeSystem), (ThemeMode.light, l.themeLight), (ThemeMode.dark, l.themeDark)]) ...[
                    OutlineChip(label: name, selected: mode == m, onTap: () => ref.read(themeModeProvider.notifier).set(m)),
                    const SizedBox(width: 10),
                  ],
                ],
              ),
              SectionHeading(l.languageHeading),
              // each language is named in itself, so a reader can find their own whatever the app shows now
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final (code, name) in [(null, l.appLanguageSystem), ('en', l.languageEnglish), ('zh', l.languageChinese), ('ms', l.languageMalay)])
                    // 简体中文 in the Chinese font in every language, not part Japanese-style kanji from M PLUS
                    DefaultTextStyle.merge(
                      style: code == 'zh' ? const TextStyle(fontFamily: zhFontFamily) : null,
                      child: OutlineChip(
                        label: name,
                        selected: locale?.languageCode == code,
                        onTap: () => ref.read(localeProvider.notifier).set(code == null ? null : Locale(code)),
                      ),
                    ),
                ],
              ),
              SectionHeading(l.listsHeading),
              MergeSemantics(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  minTileHeight: 56,
                  title: Text(l.showAllTitles),
                  subtitle: Text(l.showAllSubtitle, style: TextStyle(color: tk.hint, fontSize: 13)),
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
