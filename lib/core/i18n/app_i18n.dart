// Path: lib/core/i18n/app_i18n.dart
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class AppI18n {
  final Locale locale;
  final Map<String, dynamic> _map;

  AppI18n(this.locale, this._map);

  static const supportedLocales = [
    Locale('en'),
    Locale('vi'),
    Locale('ja'),
  ];

  static const localizationsDelegates = [
    _AppI18nDelegate(),
  ];

  static AppI18n of(BuildContext context) {
    final i18n = Localizations.of<AppI18n>(context, AppI18n);
    assert(i18n != null, 'No AppI18n found in context');
    return i18n!;
  }

  String t(String key) => (_map[key] ?? key).toString();
}

class _AppI18nDelegate extends LocalizationsDelegate<AppI18n> {
  const _AppI18nDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'vi', 'ja'].contains(locale.languageCode);

  @override
  Future<AppI18n> load(Locale locale) async {
    final code = locale.languageCode;
    final jsonString = await rootBundle.loadString('assets/i18n/$code.json');
    final map = json.decode(jsonString) as Map<String, dynamic>;
    return AppI18n(locale, map);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppI18n> old) => false;
}
