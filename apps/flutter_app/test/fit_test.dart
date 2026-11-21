import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:ringgit_radar/core/api/api_client.dart';
import 'package:ringgit_radar/core/storage/prefs.dart';
import 'package:ringgit_radar/l10n/l10n.dart';
import 'package:ringgit_radar/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_api.dart';
import 'support/fixtures.dart' as fx;
import 'support/fonts.dart';

/// Each main screen at phone width, in every language, at text scale 1.0 and 1.3, with the shipped fonts.
/// Any RenderFlex overflow or other layout error fails the test named after the screen, language and scale.
void main() {
  setUpAll(loadAppFonts);

  final screens = <String, Future<void> Function(WidgetTester, AppLocalizations)>{
    'Highlights': (t, l) async => go(t, '/'),
    'Sale': (t, l) async => go(t, '/sale'),
    'Ranking': (t, l) async => go(t, '/ranking'),
    'Game page': (t, l) async {
      await go(t, '/games/${fx.onSaleGame.nsuid}');
      // the wish button scales its label down when the label is wider than its room, so a translation must be
      // no wider than the English label in the same style, or it is drawn smaller than English
      final label = t.renderObject<RenderParagraph>(find.text(l.addToWishList));
      final english = TextPainter(
        text: TextSpan(text: lookupAppLocalizations(const Locale('en')).addToWishList, style: label.text.style),
        textDirection: TextDirection.ltr,
        textScaler: label.textScaler,
      )..layout();
      expect(label.size.width, lessThanOrEqualTo(english.width + 1), reason: 'wider than "Add to Wish List"');
      expect(find.textContaining('PEGI'), findsNothing); // age ratings are no longer shown
    },
    'Filter sheet': (t, l) async {
      await go(t, '/sale');
      await t.tap(find.text(l.filter).first);
      await t.pumpAndSettle();
      expect(find.textContaining(l.filterProductType), findsOneWidget); // the sheet is open
      expect(find.textContaining(RegExp(r'\bAge\b|年龄|umur', caseSensitive: false)), findsNothing); // no age filter
    },
    'Settings': (t, l) async => go(t, '/about'),
  };

  for (final code in ['en', 'zh', 'ms']) {
    for (final scale in [1.0, 1.3]) {
      for (final MapEntry(key: name, value: open) in screens.entries) {
        testWidgets('$name $code x$scale', (t) async {
          t.view.physicalSize = const Size(390, 844);
          t.view.devicePixelRatio = 1;
          t.platformDispatcher.textScaleFactorTestValue = scale;
          addTearDown(t.view.reset);
          addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
          SharedPreferences.setMockInitialValues({localeKey: code});
          final prefs = await SharedPreferences.getInstance();
          await t.pumpWidget(ProviderScope(
            overrides: [sharedPreferencesProvider.overrideWithValue(prefs), apiClientProvider.overrideWithValue(FakeApiClient())],
            child: const RinggitRadarApp(),
          ));
          await t.pumpAndSettle();
          await open(t, lookupAppLocalizations(Locale(code)));
          expect(t.takeException(), isNull);
        });
      }
    }
  }
}

Future<void> go(WidgetTester t, String path) async {
  GoRouter.of(t.element(find.byType(Scaffold).first)).go(path);
  await t.pumpAndSettle();
}
