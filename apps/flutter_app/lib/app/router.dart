import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/game_x.dart';
import '../features/game/game_page.dart';
import '../features/highlights/highlights_page.dart';
import '../features/lists/list_page.dart';
import '../features/lists/list_spec.dart';
import '../features/ranking/ranking_page.dart';
import '../features/sale/sale_page.dart';
import '../features/search/search_page.dart';
import '../features/settings/about_page.dart';
import '../features/settings/privacy_page.dart';
import '../features/wishlist/wishlist_page.dart';
import 'shell.dart';

Page<void> _instant(GoRouterState state, Widget child) => NoTransitionPage<void>(key: state.pageKey, child: child);

GoRouter buildRouter() => GoRouter(
      routes: [
        ShellRoute(
          builder: (context, state, child) => AppShell(location: state.uri.path, child: child),
          routes: [
            GoRoute(path: '/', pageBuilder: (c, s) => _instant(s, const HighlightsPage())),
            GoRoute(path: '/search', pageBuilder: (c, s) => _instant(s, const SearchPage())),
            GoRoute(path: '/sale', pageBuilder: (c, s) => _instant(s, const SalePage())),
            GoRoute(path: '/ranking', pageBuilder: (c, s) => _instant(s, const RankingPage())),
            GoRoute(path: '/recent', pageBuilder: (c, s) => _instant(s, const ListPage(title: 'Recent Releases', spec: ListSpec.recent, scope: 'recent'))),
            GoRoute(path: '/coming-soon', pageBuilder: (c, s) => _instant(s, const ListPage(title: 'Coming Soon', spec: ListSpec.comingSoon, scope: 'soon'))),
            GoRoute(path: '/wish-list', pageBuilder: (c, s) => _instant(s, const WishlistPage())),
            GoRoute(path: '/about', pageBuilder: (c, s) => _instant(s, const AboutPage())),
            GoRoute(path: '/privacy', pageBuilder: (c, s) => _instant(s, const PrivacyPage())),
          ],
        ),
        GoRoute(
          path: '/games/:id',
          pageBuilder: (context, state) {
            final extra = state.extra is GameRouteExtra ? state.extra! as GameRouteExtra : null;
            return CustomTransitionPage<void>(
              key: state.pageKey,
              transitionDuration: const Duration(milliseconds: 250),
              reverseTransitionDuration: const Duration(milliseconds: 250),
              child: GamePage(nsuid: state.pathParameters['id']!, extra: extra),
              transitionsBuilder: (context, animation, secondary, child) =>
                  FadeTransition(opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic), child: child),
            );
          },
        ),
      ],
    );
