// Path: lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router.dart';
import 'core/theme.dart';
import 'core/i18n/app_i18n.dart';
import 'core/settings/settings_provider.dart';

class MovieHubApp extends ConsumerWidget {
  const MovieHubApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      title: 'MovieHub',
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.lightTheme(settings.palette),
      darkTheme: AppTheme.darkTheme(settings.palette),
      themeMode: AppTheme.toFlutterThemeMode(settings.themeMode),

      // Locale
      locale: settings.locale,
      supportedLocales: AppI18n.supportedLocales,
      localizationsDelegates: const [
        ...AppI18n.localizationsDelegates,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: AppRouter.login,
    );
  }
}
