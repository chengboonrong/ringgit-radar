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

import 'support/fonts.dart';

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
    SharedPreferences.setMockInitialValues({localeKey: 'en'});
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
}
