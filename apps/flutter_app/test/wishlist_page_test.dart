import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ringgit_radar/core/api/api_client.dart';
import 'package:ringgit_radar/core/api/models.dart';
import 'package:ringgit_radar/core/storage/prefs.dart';
import 'package:ringgit_radar/l10n/l10n.dart';
import 'package:ringgit_radar/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_api.dart';
import 'support/fonts.dart';

/// The API no longer lists anything on the wish list: every game on it was removed.
class _AllRemovedApi extends FakeApiClient {
  @override
  Future<GamePage> games(ListQuery q, {required bool showAll, int page = 1, int limit = 24}) async =>
      GamePage(items: const [], total: 0, page: page);
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('a wish list whose games were all removed says so, not "none on sale"', (t) async {
    t.view.physicalSize = const Size(390, 844);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    t.platformDispatcher.defaultRouteNameTestValue = '/wish-list';
    addTearDown(t.platformDispatcher.clearDefaultRouteNameTestValue);
    SharedPreferences.setMockInitialValues({noticeSeenKey: true, wishlistKey: ['70010000000001', '70010000000002']});
    final prefs = await SharedPreferences.getInstance();
    await t.pumpWidget(ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs), apiClientProvider.overrideWithValue(_AllRemovedApi())],
      child: const RinggitRadarApp(),
    ));
    await t.pumpAndSettle();
    final en = lookupAppLocalizations(const Locale('en'));
    const gone = 'The games on your Wish List are no longer shown in Ringgit Radar.';
    expect(find.text(gone), findsOneWidget);
    expect(find.text(en.noneOnSale), findsNothing);

    await t.tap(find.text(en.onSaleChip)); // the on-sale filter does not hide why the list is empty
    await t.pumpAndSettle();
    expect(find.text(gone), findsOneWidget);
    expect(t.takeException(), isNull);
  });
}
