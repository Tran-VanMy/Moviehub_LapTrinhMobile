// Path: lib/features/movies/presentation/pages/settings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/i18n/app_i18n.dart';
import '../../../../core/router.dart';
import '../../../../core/settings/app_settings.dart';
import '../../../../core/settings/settings_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i18n = AppI18n.of(context);
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(i18n.t("settings"))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ===== Theme mode =====
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(i18n.t("theme"),
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: Text(i18n.t("system")),
                        selected: settings.themeMode == AppThemeMode.system,
                        onSelected: (_) => notifier.setThemeMode(AppThemeMode.system),
                      ),
                      ChoiceChip(
                        label: Text(i18n.t("light")),
                        selected: settings.themeMode == AppThemeMode.light,
                        onSelected: (_) => notifier.setThemeMode(AppThemeMode.light),
                      ),
                      ChoiceChip(
                        label: Text(i18n.t("dark")),
                        selected: settings.themeMode == AppThemeMode.dark,
                        onSelected: (_) => notifier.setThemeMode(AppThemeMode.dark),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ===== Palette =====
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(i18n.t("palette"),
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  Column(
                    children: AppPalette.values.map((p) {
                      final selected = settings.palette == p;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: p.gradient,
                          ),
                        ),
                        title: Text(p.label),
                        trailing: selected
                            ? Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary)
                            : const Icon(Icons.circle_outlined),
                        onTap: () => notifier.setPalette(p),
                      );
                    }).toList(),
                  )
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ===== Language =====
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(i18n.t("language"),
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text("English"),
                        selected: settings.locale.languageCode == 'en',
                        onSelected: (_) => notifier.setLocale(const Locale('en')),
                      ),
                      ChoiceChip(
                        label: const Text("Tiếng Việt"),
                        selected: settings.locale.languageCode == 'vi',
                        onSelected: (_) => notifier.setLocale(const Locale('vi')),
                      ),
                      ChoiceChip(
                        label: const Text("日本語"),
                        selected: settings.locale.languageCode == 'ja',
                        onSelected: (_) => notifier.setLocale(const Locale('ja')),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ===== About =====
          ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            tileColor: theme.cardColor,
            leading: const Icon(Icons.info_outline_rounded),
            title: Text(i18n.t("about")),
            subtitle: Text(i18n.t("how_to_use")),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.pushNamed(context, AppRouter.about),
          ),
        ],
      ),
    );
  }
}
