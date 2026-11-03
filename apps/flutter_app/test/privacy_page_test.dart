import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ringgit_radar/app/theme.dart';
import 'package:ringgit_radar/features/settings/privacy_page.dart';

void main() {
  testWidgets('the privacy page says what is true and names the third parties', (t) async {
    t.view.physicalSize = const Size(900, 3000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(MaterialApp(theme: buildTheme(Brightness.light), home: const Scaffold(body: PrivacyPage())));
    final all = t.widgetList<Text>(find.byType(Text)).map((w) => w.data ?? '').join('\n');
    for (final must in ['No accounts', 'Wish List stays on your device', 'writes no access log', 'Pictures come through our server', 'Vercel', 'Supabase', 'nothing about visitors', 'Not affiliated with or endorsed by Nintendo']) {
      expect(all, contains(must), reason: must);
    }
    // nothing on the page is a promise the code does not keep
    for (final mustNot in ['private', 'personal', 'we never', 'anonymous', 'Cloudflare', 'gstatic', 'Google']) {
      expect(all.toLowerCase(), isNot(contains(mustNot)), reason: mustNot);
    }
    expect(t.takeException(), isNull);
  });
}
