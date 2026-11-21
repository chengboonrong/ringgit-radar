import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/widgets/page_bits.dart';
import '../lists/game_grid.dart';
import 'data_sources_page.dart';
import '../../l10n/l10n.dart';

/// What the app and its server do with your data. Every line here is something the code does; if the
/// code changes, this page changes with it.
class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  /// Heading and paragraph, in the reader's language. English is the definitive version.
  static List<(String, String)> sections(AppLocalizations l) => [
        (l.privacyNoAccountsTitle, l.privacyNoAccountsBody),
        (l.privacyDeviceTitle, l.privacyDeviceBody),
        (l.privacyLogsTitle, l.privacyLogsBody),
        (l.privacyPicturesTitle, l.privacyPicturesBody),
        (l.privacyOthersTitle, l.privacyOthersBody),
        (l.privacyNotNintendoTitle, l.privacyNotNintendoBody(contactEmail)),
      ];

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final l = context.l10n;
    final width = MediaQuery.sizeOf(context).width;
    final pad = pagePadding(width);
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(pad, 4, pad, width < 840 ? 120 : 32),
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageTitle(l.privacy),
              for (final (heading, body) in sections(l)) ...[
                const SizedBox(height: 20),
                Semantics(header: true, child: Text(heading, style: Theme.of(context).textTheme.titleMedium)),
                const SizedBox(height: 6),
                Text(body, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: tk.text, fontSize: 15)),
              ],
              if (l.privacyEnglishPrevails.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(l.privacyEnglishPrevails, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: tk.hint)),
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
