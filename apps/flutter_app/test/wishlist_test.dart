import 'package:ringgit_radar/core/storage/prefs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> open() async {
  final prefs = await SharedPreferences.getInstance();
  return ProviderContainer(overrides: [sharedPreferencesProvider.overrideWithValue(prefs)]);
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('starts empty', () async {
    final c = await open();
    addTearDown(c.dispose);
    expect(c.read(wishlistProvider), isEmpty);
  });

  test('adds survive a restart, newest first, and removing is remembered too', () async {
    var c = await open();
    await c.read(wishlistProvider.notifier).toggle('111');
    await c.read(wishlistProvider.notifier).toggle('222');
    expect(c.read(wishlistProvider), ['222', '111']);
    c.dispose();

    c = await open(); // a new container reading the same store is a restart
    addTearDown(c.dispose);
    expect(c.read(wishlistProvider), ['222', '111']);
    await c.read(wishlistProvider.notifier).toggle('222');
    expect(c.read(wishlistProvider), ['111']);

    final again = await open();
    addTearDown(again.dispose);
    expect(again.read(wishlistProvider), ['111']);
  });

  test('theme and show-all are stored as well', () async {
    var c = await open();
    await c.read(themeModeProvider.notifier).set(ThemeMode.dark);
    await c.read(showAllProvider.notifier).set(true);
    c.dispose();
    c = await open();
    addTearDown(c.dispose);
    expect(c.read(themeModeProvider), ThemeMode.dark);
    expect(c.read(showAllProvider), isTrue);
  });
}
