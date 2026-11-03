import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Overridden in main() with the loaded instance, so reads stay synchronous.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) => throw UnimplementedError('override in main'));

const wishlistKey = 'wishlist';
const themeKey = 'theme_mode';
const showAllKey = 'show_all';

/// The device-local wish list, newest first.
class WishlistNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => ref.read(sharedPreferencesProvider).getStringList(wishlistKey) ?? const [];

  bool has(String nsuid) => state.contains(nsuid);

  Future<void> toggle(String nsuid) {
    final next = state.contains(nsuid) ? [...state.where((id) => id != nsuid)] : [nsuid, ...state];
    state = next;
    return ref.read(sharedPreferencesProvider).setStringList(wishlistKey, next);
  }
}

final wishlistProvider = NotifierProvider<WishlistNotifier, List<String>>(WishlistNotifier.new);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final name = ref.read(sharedPreferencesProvider).getString(themeKey);
    return ThemeMode.values.firstWhere((m) => m.name == name, orElse: () => ThemeMode.system);
  }

  Future<void> set(ThemeMode mode) {
    state = mode;
    return ref.read(sharedPreferencesProvider).setString(themeKey, mode.name);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

/// "Show all titles": also lists titles the default view hides.
class ShowAllNotifier extends Notifier<bool> {
  @override
  bool build() => ref.read(sharedPreferencesProvider).getBool(showAllKey) ?? false;

  Future<void> set(bool value) {
    state = value;
    return ref.read(sharedPreferencesProvider).setBool(showAllKey, value);
  }
}

final showAllProvider = NotifierProvider<ShowAllNotifier, bool>(ShowAllNotifier.new);
