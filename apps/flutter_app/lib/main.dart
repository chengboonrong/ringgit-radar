import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/router.dart';
import 'app/theme.dart';
import 'core/storage/prefs.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  // pushed pages such as a game page show in the address bar, so the browser's back button works
  GoRouter.optionURLReflectsImperativeAPIs = true;
  await initializeDateFormatting('en');
  final prefs = await SharedPreferences.getInstance();
  runApp(ProviderScope(overrides: [sharedPreferencesProvider.overrideWithValue(prefs)], child: const RinggitRadarApp()));
}

class RinggitRadarApp extends ConsumerStatefulWidget {
  const RinggitRadarApp({super.key});

  @override
  ConsumerState<RinggitRadarApp> createState() => _RinggitRadarAppState();
}

class _RinggitRadarAppState extends ConsumerState<RinggitRadarApp> {
  final _router = buildRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Ringgit Radar',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      themeMode: ref.watch(themeModeProvider),
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      builder: (context, child) => MediaQuery.withClampedTextScaling(minScaleFactor: 0.9, maxScaleFactor: 1.3, child: child!),
    );
  }
}
