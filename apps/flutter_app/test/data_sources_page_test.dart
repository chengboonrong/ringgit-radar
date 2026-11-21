import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ringgit_radar/app/theme.dart';
import 'package:ringgit_radar/core/api/api_client.dart';
import 'package:ringgit_radar/core/storage/prefs.dart';
import 'package:ringgit_radar/features/settings/data_sources_page.dart';
import 'package:ringgit_radar/l10n/l10n.dart';
import 'package:ringgit_radar/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_api.dart';
import 'support/fonts.dart';

void main() {
  setUpAll(loadAppFonts);

  testWidgets('the data page says only what is true, with the removal contact', (t) async {
    t.view.physicalSize = const Size(900, 3000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(MaterialApp(locale: const Locale('en'), localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, theme: buildTheme(Brightness.light), home: const Scaffold(body: DataSourcesPage())));
    final all = [
      ...t.widgetList<Text>(find.byType(Text)).map((w) => w.data ?? ''),
      ...t.widgetList<SelectableText>(find.byType(SelectableText)).map((w) => w.data ?? ''),
    ].join('\n');
    for (final must in ['Malaysian Nintendo eShop', '1 November 2026', 'description', 'only the first part', 'Nintendo\'s image server', 'no Buy button', contactEmail, sourceCodeUrl]) {
      expect(all, contains(must), reason: must);
    }
    // no turnaround promise, nothing official, and no claim that descriptions are not stored
    for (final mustNot in RegExp(r'within|\d+\s*(working |business )?(days?|hours?)|(?<!un)official|we don.t (keep|store) (the )?descriptions?', caseSensitive: false).allMatches(all)) {
      fail('promise or claim the code does not keep: "${mustNot.group(0)}"');
    }
    expect(t.takeException(), isNull);
  });

  testWidgets('About links to the data page', (t) async {
    t.view.physicalSize = const Size(390, 844);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    SharedPreferences.setMockInitialValues({noticeSeenKey: true});
    final prefs = await SharedPreferences.getInstance();
    await t.pumpWidget(ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs), apiClientProvider.overrideWithValue(FakeApiClient())],
      child: const RinggitRadarApp(),
    ));
    await t.pumpAndSettle();
    final en = lookupAppLocalizations(const Locale('en'));
    await t.tap(find.bySemanticsLabel(en.aboutApp));
    await t.pumpAndSettle();
    await t.tap(find.text(en.dataSourcesTitle));
    await t.pumpAndSettle();
    expect(find.textContaining(contactEmail), findsOneWidget);
    expect(t.takeException(), isNull);
  });
}
