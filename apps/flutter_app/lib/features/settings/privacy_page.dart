import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/widgets/page_bits.dart';
import '../lists/game_grid.dart';

/// What the app and its server do with your data. Every line here is something the code does; if the
/// code changes, this page changes with it.
class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  static const sections = <(String, String)>[
    ('No accounts', 'There is no sign-in. Ringgit Radar does not ask for your name, email or phone number, and it has no ads and no analytics.'),
    (
      'Your Wish List stays on your device',
      'Your Wish List, your theme choice and the "Show all titles" setting are saved on this device only: in the browser\'s local storage on the web, in the app\'s preferences on Android. '
          'When you open your Wish List, the app asks our server for those games by their ids, so the server receives the ids in that request to answer it. It does not keep them or link them to you.'
    ),
    (
      'What our server logs',
      'Our server writes no access log. It logs only errors, for example a database error or an image that could not be fetched, and those lines hold an image id or an error message, not your address. '
          'To stop one visitor from overloading it, the server counts requests per internet address, in memory only. Those addresses are never written to disk.'
    ),
    (
      'Pictures come through our server',
      'Game art is fetched from the store\'s image servers by our server and passed on to you, and may be kept in Vercel\'s cache for reuse. Your browser or phone does not contact Nintendo.'
    ),
    (
      'Who else sees your visit',
      'The site and its server run on Vercel. Vercel keeps request logs under its own policy, which can include the page you asked for, the time, your internet address and your browser type. '
          'Price data is stored with Supabase; it holds game prices and nothing about visitors, and it only ever hears from our server. '
          'The web version loads everything, fonts included, from our own address. The Android app talks to our server and to nobody else.'
    ),
    (
      'Not Nintendo',
      'Ringgit Radar is an independent, unofficial app. Not affiliated with or endorsed by Nintendo. Prices are collected from the Malaysian Nintendo eShop and shown with their history; to buy a game, use your Switch.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
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
              const PageTitle('Privacy'),
              for (final (heading, body) in sections) ...[
                const SizedBox(height: 20),
                Semantics(header: true, child: Text(heading, style: Theme.of(context).textTheme.titleMedium)),
                const SizedBox(height: 6),
                Text(body, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: tk.text, fontSize: 15)),
              ],
              const SizedBox(height: 28),
              OutlineChip(label: 'Back to About', onTap: () => context.go('/about')),
            ],
          ),
        ),
      ),
    );
  }
}
