// Path: lib/core/settings/app_settings.dart
import 'package:flutter/material.dart';

enum AppThemeMode { system, light, dark }

/// Palette để đổi màu “vibe” của app (seed + gradient)
enum AppPalette { ocean, sunset, neon, grape }

extension AppPaletteX on AppPalette {
  String get key => switch (this) {
        AppPalette.ocean => "ocean",
        AppPalette.sunset => "sunset",
        AppPalette.neon => "neon",
        AppPalette.grape => "grape",
      };

  String get label => switch (this) {
        AppPalette.ocean => "Ocean",
        AppPalette.sunset => "Sunset",
        AppPalette.neon => "Neon",
        AppPalette.grape => "Grape",
      };

  Color get seed => switch (this) {
        AppPalette.ocean => const Color(0xFF1976D2),
        AppPalette.sunset => const Color(0xFFFF7043),
        AppPalette.neon => const Color(0xFF00E5FF),
        AppPalette.grape => const Color(0xFF7E57C2),
      };

  LinearGradient get gradient => switch (this) {
        AppPalette.ocean => const LinearGradient(
            colors: [Color(0xFF1565C0), Color(0xFF00B0FF), Color(0xFF00E5FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        AppPalette.sunset => const LinearGradient(
            colors: [Color(0xFFFF5252), Color(0xFFFFA726), Color(0xFFFFD54F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        AppPalette.neon => const LinearGradient(
            colors: [Color(0xFF00E676), Color(0xFF00B0FF), Color(0xFFD500F9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        AppPalette.grape => const LinearGradient(
            colors: [Color(0xFF5E35B1), Color(0xFF7E57C2), Color(0xFFEC407A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
      };
}
