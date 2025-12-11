// Path: lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init Hive for offline watchlist storage
  await Hive.initFlutter();
  await Hive.openBox<Map>(AppConstants.watchlistBox);

  runApp(const ProviderScope(child: MovieHubApp()));
}
