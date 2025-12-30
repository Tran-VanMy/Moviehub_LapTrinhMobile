// Path: lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox<Map>(AppConstants.watchlistBox);
  await Hive.openBox<Map>(AppConstants.favoriteBox);
  await Hive.openBox(AppConstants.settingsBox);

  runApp(const ProviderScope(child: MovieHubApp()));
}
