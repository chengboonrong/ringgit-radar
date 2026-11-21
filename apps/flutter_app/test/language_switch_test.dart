import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:ringgit_radar/core/api/api_client.dart';
import 'package:ringgit_radar/core/api/models.dart';
import 'package:ringgit_radar/core/storage/prefs.dart';
import 'package:ringgit_radar/l10n/genres.dart';
import 'package:ringgit_radar/l10n/l10n.dart';
import 'package:ringgit_radar/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/rendering.dart';
import 'package:ringgit_radar/core/widgets/error_view.dart';

import 'support/fake_api.dart';
import 'support/fixtures.dart' as fx;
import 'support/fonts.dart';

/// Fails Highlights and genres, answers the rest from the fixtures, and counts every request.
class _CountingApi extends FakeApiClient {
  int calls = 0;
  @override
  Future<Highlights> highlights() async { calls++; throw ApiException(ApiWhat.highlights, ApiFailure.unreachable); }
  @override
  Future<List<GenreCount>> genres() async { calls++; throw ApiException(ApiWhat.genres, ApiFailure.status, 503); }
  @override
  Future<GamePage> games(ListQuery q, {required bool showAll, int page = 1, int limit = 24}) { calls++; return super.games(q, showAll: showAll, page: page, limit: limit); }
}

Future<(SharedPreferences, ProviderContainer)> _pumpApp(WidgetTester t, ApiClient api, String code) async {
  t.view.physicalSize = const Size(390, 1600);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  SharedPreferences.setMockInitialValues({localeKey: code, noticeSeenKey: true});
  final prefs = await SharedPreferences.getInstance();
  await t.pumpWidget(ProviderScope(
    retry: (_, _) => null, // show a failure at once rather than after Riverpod's retries
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs), apiClientProvider.overrideWithValue(api)],
    child: const RinggitRadarApp(),
  ));
  await t.pumpAndSettle();
  return (prefs, ProviderScope.containerOf(t.element(find.byType(Scaffold).first)));
}

Future<void> _go(WidgetTester t, String path) async {
  GoRouter.of(t.element(find.byType(Scaffold).first)).go(path);
  await t.pumpAndSettle();
}

class _StatusApi extends ApiClient {
  @override
  Future<PriceStatus> status() async => PriceStatus(lastRunAt: DateTime.utc(2026, 11, 20, 16), productCount: 7827, historySince: DateTime.utc(2026, 10, 1));
  @override
  Future<Highlights> highlights() => Completer<Highlights>().future;
}

void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  final zh = lookupAppLocalizations(const Locale('zh'));
  final ms = lookupAppLocalizations(const Locale('ms'));
  setUpAll(loadAppFonts);

  testWidgets('choosing a language in Settings changes the page at once and is stored', (t) async {
    t.view.physicalSize = const Size(390, 1600);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    SharedPreferences.setMockInitialValues({localeKey: 'en', noticeSeenKey: true});
    final prefs = await SharedPreferences.getInstance();
    await t.pumpWidget(ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs), apiClientProvider.overrideWithValue(_StatusApi())],
      child: const RinggitRadarApp(),
    ));
    await t.pump();
    GoRouter.of(t.element(find.byType(Scaffold).first)).go('/about');
    await t.pumpAndSettle();
    expect(find.text(en.languageHeading), findsOneWidget);

    await t.ensureVisible(find.text('简体中文'));
    await t.tap(find.text('简体中文'));
    await t.pumpAndSettle();
    expect(find.text(zh.languageHeading), findsOneWidget);
    expect(Localizations.localeOf(t.element(find.text(zh.languageHeading))), const Locale('zh'));
    expect(prefs.getString(localeKey), 'zh');
    expect(Theme.of(t.element(find.text(zh.languageHeading))).textTheme.bodyMedium!.fontFamily, 'RinggitZh');

    await t.tap(find.text('Bahasa Melayu'));
    await t.pumpAndSettle();
    expect(find.text(ms.languageHeading), findsOneWidget);
    expect(Localizations.localeOf(t.element(find.text(ms.languageHeading))), const Locale('ms'));
    expect(prefs.getString(localeKey), 'ms');
  });

  test('genre labels: known names translate, unknown names show as the API sends them', () {
    expect(genreLabel(en, 'Action'), en.genreAction);
    expect(genreLabel(zh, 'Action'), zh.genreAction);
    expect(genreLabel(zh, 'Visual Novel Deluxe'), 'Visual Novel Deluxe');
    expect(genreLabel(ms, ''), '');
  });

  for (final (path, error) in [
    ('/', ApiException(ApiWhat.highlights, ApiFailure.unreachable)),
    ('/search', ApiException(ApiWhat.genres, ApiFailure.status, 503)),
  ]) {
    testWidgets('an error on $path is rewritten in the new language without asking the server again', (t) async {
      final api = _CountingApi();
      final (_, container) = await _pumpApp(t, api, 'en');
      await _go(t, path);
      expect(find.text(errorText(en, error)), findsOneWidget);
      final before = api.calls;

      await container.read(localeProvider.notifier).set(const Locale('zh'));
      await t.pumpAndSettle();
      expect(find.text(errorText(zh, error)), findsOneWidget);
      expect(api.calls, before, reason: 'switching language must not refetch');
    });
  }

  testWidgets('a loaded list is relabelled in the new language without asking the server again', (t) async {
    final api = _CountingApi();
    final (_, container) = await _pumpApp(t, api, 'en');
    await _go(t, '/sale');
    expect(find.text(en.itemsCount(fx.games.length)), findsOneWidget);
    final before = api.calls;

    await container.read(localeProvider.notifier).set(const Locale('ms'));
    await t.pumpAndSettle();
    expect(find.text(ms.itemsCount(fx.games.length)), findsOneWidget);
    expect(api.calls, before);
  });

  testWidgets('the 简体中文 chip is drawn in the Chinese font in English and Malay too', (t) async {
    for (final code in ['en', 'ms']) {
      await _pumpApp(t, FakeApiClient(), code);
      await _go(t, '/about');
      final chip = t.renderObject<RenderParagraph>(find.text('简体中文'));
      expect(chip.text.style!.fontFamily, 'RinggitZh', reason: code);
    }
  });

  testWidgets('the wish button tells a screen reader which game it saves, in Malay', (t) async {
    final handle = t.ensureSemantics();
    await _pumpApp(t, FakeApiClient(), 'ms');
    await _go(t, '/games/${fx.onSaleGame.nsuid}');
    expect(find.bySemanticsLabel(ms.wishAdd(fx.onSaleGame.title)), findsOneWidget);
    handle.dispose();
  });

}
