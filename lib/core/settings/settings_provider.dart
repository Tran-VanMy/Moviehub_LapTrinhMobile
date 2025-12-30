// Path: lib/core/settings/settings_provider.dart
export 'app_settings.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../constants.dart';
import 'app_settings.dart';

class SettingsState {
  final AppThemeMode themeMode;
  final AppPalette palette;
  final Locale locale;

  const SettingsState({
    this.themeMode = AppThemeMode.system,
    this.palette = AppPalette.ocean,
    this.locale = const Locale('en'),
  });

  SettingsState copyWith({
    AppThemeMode? themeMode,
    AppPalette? palette,
    Locale? locale,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      palette: palette ?? this.palette,
      locale: locale ?? this.locale,
    );
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState()) {
    _load();
  }

  late final Box _box = Hive.box(AppConstants.settingsBox);

  static const _kThemeMode = "theme_mode";
  static const _kPalette = "palette";
  static const _kLocale = "locale";

  void _load() {
    final themeIndex = _box.get(_kThemeMode);
    final paletteIndex = _box.get(_kPalette);
    final localeCode = _box.get(_kLocale);

    AppThemeMode mode = state.themeMode;
    AppPalette palette = state.palette;
    Locale locale = state.locale;

    if (themeIndex is int &&
        themeIndex >= 0 &&
        themeIndex < AppThemeMode.values.length) {
      mode = AppThemeMode.values[themeIndex];
    }
    if (paletteIndex is int &&
        paletteIndex >= 0 &&
        paletteIndex < AppPalette.values.length) {
      palette = AppPalette.values[paletteIndex];
    }
    if (localeCode is String && localeCode.isNotEmpty) {
      locale = Locale(localeCode);
    }

    state = state.copyWith(themeMode: mode, palette: palette, locale: locale);
  }

  void setThemeMode(AppThemeMode mode) {
    state = state.copyWith(themeMode: mode);
    _box.put(_kThemeMode, mode.index);
  }

  void setPalette(AppPalette palette) {
    state = state.copyWith(palette: palette);
    _box.put(_kPalette, palette.index);
  }

  void setLocale(Locale locale) {
    state = state.copyWith(locale: locale);
    _box.put(_kLocale, locale.languageCode);
  }
}
