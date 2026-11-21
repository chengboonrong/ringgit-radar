import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ringgit_radar/app/theme.dart';
import 'package:ringgit_radar/features/settings/data_sources_page.dart';
import 'package:ringgit_radar/features/settings/privacy_page.dart';
import 'package:ringgit_radar/l10n/app_localizations.dart';

void main() {
  testWidgets('the privacy page says what is true and names the third parties', (t) async {
    t.view.physicalSize = const Size(900, 3000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(MaterialApp(locale: const Locale('en'), localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, theme: buildTheme(Brightness.light), home: const Scaffold(body: PrivacyPage())));
    final all = t.widgetList<Text>(find.byType(Text)).map((w) => w.data ?? '').join('\n');
    for (final must in ['No accounts', 'Wish List stays on your device', 'writes no access log', 'Pictures come from Nintendo\'s image server', 'img-eshop.cdn.nintendo.net', 'Vercel', 'Supabase', 'nothing about visitors', 'Not affiliated with or endorsed by Nintendo', contactEmail, 'forwarded by Cloudflare']) {
      expect(all, contains(must), reason: must);
    }
    // nothing on the page is a promise the code does not keep. Cloudflare and Google appear only where the
    // contact address's forwarding is described; the app itself uses neither.
    final notNintendo = lookupAppLocalizations(const Locale('en')).privacyNotNintendoBody(contactEmail);
    final rest = all.replaceAll(notNintendo, '');
    for (final mustNot in ['private', 'personal', 'we never', 'anonymous', 'cloudflare', 'gstatic', 'google']) {
      expect(rest.toLowerCase(), isNot(contains(mustNot)), reason: mustNot);
    }
    for (final mustNot in ['private', 'personal', 'we never', 'anonymous', 'gstatic']) {
      expect(notNintendo.toLowerCase(), isNot(contains(mustNot)), reason: mustNot);
    }
    expect(t.takeException(), isNull);
  });
}
