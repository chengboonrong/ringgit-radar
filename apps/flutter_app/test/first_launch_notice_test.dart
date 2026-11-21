import 'package:flutter/material.dart';
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

final en = lookupAppLocalizations(const Locale('en'));

Future<SharedPreferences> start(WidgetTester t, Map<String, Object> initial) async {
  t.view.physicalSize = const Size(390, 844);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  SharedPreferences.setMockInitialValues(initial);
  final prefs = await SharedPreferences.getInstance();
  await t.pumpWidget(ProviderScope(
    key: UniqueKey(),
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs), apiClientProvider.overrideWithValue(FakeApiClient())],
    child: const RinggitRadarApp(),
  ));
  await t.pumpAndSettle();
  return prefs;
}

String location(WidgetTester t) =>
    GoRouter.of(t.element(find.byType(Scaffold).first)).routerDelegate.currentConfiguration.uri.toString();

void main() {
  testWidgets('a fresh install shows the notice once', (t) async {
    final prefs = await start(t, {});
    expect(find.text(en.noticeTitle), findsOneWidget);
    await t.tap(find.text(en.noticeOk));
    await t.pumpAndSettle();
    expect(find.text(en.noticeTitle), findsNothing);
    expect(prefs.getBool(noticeSeenKey), isTrue);

    await t.pumpWidget(const SizedBox());
    SharedPreferences.setMockInitialValues({noticeSeenKey: true});
    await start(t, {noticeSeenKey: true});
    expect(find.text(en.noticeTitle), findsNothing);
  });

  testWidgets('an existing install sees it after updating and keeps its settings', (t) async {
    final before = <String, Object>{wishlistKey: ['70010000000001'], themeKey: 'dark', showAllKey: true, localeKey: 'ms'};
    final prefs = await start(t, before);
    final ms = lookupAppLocalizations(const Locale('ms'));
    expect(find.text(ms.noticeTitle), findsOneWidget);
    await t.tap(find.text(ms.noticeOk));
    await t.pumpAndSettle();
    expect(prefs.getStringList(wishlistKey), ['70010000000001']);
    expect(prefs.getString(themeKey), 'dark');
    expect(prefs.getBool(showAllKey), isTrue);
    expect(prefs.getString(localeKey), 'ms');
    expect(prefs.getBool(noticeSeenKey), isTrue);
  });

  testWidgets('a deep link to a game shows the notice over the game page', (t) async {
    t.platformDispatcher.defaultRouteNameTestValue = '/games/${fx.onSaleGame.nsuid}';
    addTearDown(t.platformDispatcher.clearDefaultRouteNameTestValue);
    await start(t, {});
    expect(find.text(en.noticeTitle), findsOneWidget);
    expect(find.text(fx.onSaleGame.title, skipOffstage: false), findsWidgets);
  });

  testWidgets('back dismisses the notice, not the page, and counts as seen', (t) async {
    t.platformDispatcher.defaultRouteNameTestValue = '/games/${fx.onSaleGame.nsuid}';
    addTearDown(t.platformDispatcher.clearDefaultRouteNameTestValue);
    final prefs = await start(t, {});
    await t.binding.handlePopRoute();
    await t.pumpAndSettle();
    expect(find.text(en.noticeTitle), findsNothing);
    expect(location(t), '/games/${fx.onSaleGame.nsuid}');
    expect(prefs.getBool(noticeSeenKey), isTrue);
  });

  testWidgets('the data link closes the notice and opens /data-sources', (t) async {
    final prefs = await start(t, {});
    await t.tap(find.text(en.dataSourcesTitle));
    await t.pumpAndSettle();
    expect(find.text(en.noticeTitle), findsNothing);
    expect(prefs.getBool(noticeSeenKey), isTrue);
    expect(location(t), '/data-sources');
  });
}
