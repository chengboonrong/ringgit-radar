import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/first_launch_notice.dart';
import 'app/router.dart';
import 'app/theme.dart';
import 'core/storage/prefs.dart';
import 'l10n/html_lang.dart';
import 'l10n/l10n.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  // pushed pages such as a game page show in the address bar, so the browser's back button works
  GoRouter.optionURLReflectsImperativeAPIs = true;
  await initializeDateFormatting();
  final prefs = await SharedPreferences.getInstance();
  runApp(ProviderScope(overrides: [sharedPreferencesProvider.overrideWithValue(prefs)], child: const RinggitRadarApp()));
}

class RinggitRadarApp extends ConsumerStatefulWidget {
  const RinggitRadarApp({super.key});

  @override
  ConsumerState<RinggitRadarApp> createState() => _RinggitRadarAppState();
}

class _RinggitRadarAppState extends ConsumerState<RinggitRadarApp> with WidgetsBindingObserver {
  final _router = buildRouter();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (!ref.read(noticeSeenProvider)) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final nav = _router.routerDelegate.navigatorKey.currentContext;
        if (nav == null || !mounted) return;
        await showFirstLaunchNotice(nav, onDataSources: () => _router.go('/data-sources'));
        await ref.read(noticeSeenProvider.notifier).markSeen();
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _router.dispose();
    super.dispose();
  }

  // System follows the device, so the theme's fonts must follow a device language change too
  @override
  void didChangeLocales(List<Locale>? locales) => setState(() {});

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    // the same answer MaterialApp reaches, needed here because the theme is built above it
    final code = (locale ?? resolveAppLocale(WidgetsBinding.instance.platformDispatcher.locales)).languageCode;
    return MaterialApp.router(
      title: 'Ringgit Radar',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      themeMode: ref.watch(themeModeProvider),
      theme: buildTheme(Brightness.light, languageCode: code),
      darkTheme: buildTheme(Brightness.dark, languageCode: code),
      locale: locale,
      supportedLocales: appLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      localeListResolutionCallback: (device, _) => resolveAppLocale(device),
      builder: (context, child) {
        setHtmlLang(Localizations.localeOf(context).languageCode);
        return MediaQuery.withClampedTextScaling(minScaleFactor: 0.9, maxScaleFactor: 1.3, child: child!);
      },
    );
  }
}
