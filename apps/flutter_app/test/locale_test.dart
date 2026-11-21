import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ringgit_radar/core/api/api_client.dart';
import 'package:ringgit_radar/core/api/models.dart';
import 'package:ringgit_radar/core/storage/prefs.dart';
import 'package:ringgit_radar/l10n/l10n.dart';
import 'package:ringgit_radar/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// An API that never answers, so pages stay in their loading state.
class _SilentApi extends ApiClient {
  @override
  Future<Highlights> highlights() => Completer<Highlights>().future;
  @override
  Future<PriceStatus> status() => Completer<PriceStatus>().future;
  @override
  Future<List<GenreCount>> genres() => Completer<List<GenreCount>>().future;
  @override
  Future<GamePage> games(ListQuery q, {required bool showAll, int page = 1, int limit = 24}) => Completer<GamePage>().future;
  @override
  Future<List<Game>> ranking(String platform) => Completer<List<Game>>().future;
  @override
  Future<GameDetail> detail(String nsuid) => Completer<GameDetail>().future;
}

ProviderContainer container(SharedPreferences prefs) =>
    ProviderContainer(overrides: [sharedPreferencesProvider.overrideWithValue(prefs)]);

void main() {
  test('device locales resolve to one of the three, Chinese of any script to zh', () {
    expect(resolveAppLocale([const Locale('ms', 'MY')]), const Locale('ms'));
    expect(resolveAppLocale([const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant', countryCode: 'TW')]), const Locale('zh'));
    expect(resolveAppLocale([const Locale('zh', 'HK')]), const Locale('zh'));
    expect(resolveAppLocale([const Locale('ta', 'MY'), const Locale('ms')]), const Locale('ms'));
    expect(resolveAppLocale([const Locale('fr')]), const Locale('en'));
    expect(resolveAppLocale(null), const Locale('en'));
  });

  test('the language choice is stored and read back, System as null', () async {
    SharedPreferences.setMockInitialValues({});
    final c = container(await SharedPreferences.getInstance());
    addTearDown(c.dispose);
    expect(c.read(localeProvider), isNull);
    await c.read(localeProvider.notifier).set(const Locale('zh'));
    expect(c.read(localeProvider), const Locale('zh'));
    expect(c.read(sharedPreferencesProvider).getString(localeKey), 'zh');
    await c.read(localeProvider.notifier).set(null);
    expect(c.read(localeProvider), isNull);
    expect(c.read(sharedPreferencesProvider).getString(localeKey), 'system');
  });

  testWidgets('the app shows the stored language', (t) async {
    SharedPreferences.setMockInitialValues({localeKey: 'ms'});
    final prefs = await SharedPreferences.getInstance();
    await t.pumpWidget(ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs), apiClientProvider.overrideWithValue(_SilentApi())],
      child: const RinggitRadarApp(),
    ));
    await t.pump();
    final ctx = t.element(find.byType(Scaffold).first);
    expect(Localizations.localeOf(ctx), const Locale('ms'));
  });
}
