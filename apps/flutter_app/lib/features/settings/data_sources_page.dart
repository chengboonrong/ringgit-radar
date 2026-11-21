import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/widgets/page_bits.dart';
import '../lists/game_grid.dart';
import '../../l10n/l10n.dart';

/// Where rights holders write to have content removed or corrected. Never translated.
const contactEmail = 'ringgitradar@snitco.com';
const sourceCodeUrl = 'https://github.com/chengboonrong/ringgit-radar';

/// Where the data comes from and what is kept. Every line here is something the code and the database do;
/// if they change, this page changes with them.
class DataSourcesPage extends StatelessWidget {
  const DataSourcesPage({super.key});

  /// Heading and paragraph, in the reader's language.
  static List<(String, String)> sections(AppLocalizations l) => [
        (l.dataFromTitle, l.dataFromBody),
        (l.dataKeptTitle, l.dataKeptBody),
        (l.dataNotKeptTitle, l.dataNotKeptBody),
        (l.dataRightsTitle, l.dataRightsBody(contactEmail)),
        (l.dataSourceCodeTitle, l.dataSourceCodeBody),
      ];

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final l = context.l10n;
    final width = MediaQuery.sizeOf(context).width;
    final pad = pagePadding(width);
    final body = Theme.of(context).textTheme.bodyLarge?.copyWith(color: tk.text, fontSize: 15);
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(pad, 4, pad, width < 840 ? 120 : 32),
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageTitle(l.dataSourcesTitle),
              for (final (heading, text) in sections(l)) ...[
                const SizedBox(height: 20),
                Semantics(header: true, child: Text(heading, style: Theme.of(context).textTheme.titleMedium)),
                const SizedBox(height: 6),
                // the rights paragraph can be selected, so the address can be copied
                if (heading == l.dataRightsTitle) SelectableText(text, style: body) else Text(text, style: body),
                if (heading == l.dataSourceCodeTitle) ...[
                  const SizedBox(height: 4),
                  SelectableText(sourceCodeUrl, style: body),
                ],
              ],
              const SizedBox(height: 28),
              OutlineChip(label: l.backToAbout, onTap: () => context.go('/about')),
            ],
          ),
        ),
      ),
    );
  }
}
