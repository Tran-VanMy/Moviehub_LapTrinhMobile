// Path: lib/features/movies/presentation/providers/watchlist_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../../../core/constants.dart';
import '../../data/models/movie.dart';

final watchlistProvider = StateNotifierProvider<WatchlistNotifier, List<Movie>>((ref) {
  return WatchlistNotifier();
});

class WatchlistNotifier extends StateNotifier<List<Movie>> {
  WatchlistNotifier() : super([]) {
    _load();
  }

  final Box<Map> _box = Hive.box<Map>(AppConstants.watchlistBox);

  void _load() {
    final values = _box.values.map((m) => Movie.fromMap(Map<String, dynamic>.from(m))).toList();
    state = values;
  }

  bool isSaved(int id) => state.any((m) => m.id == id);

  void toggle(Movie movie) {
    if (isSaved(movie.id)) {
      _box.delete(movie.id);
    } else {
      _box.put(movie.id, movie.toMap());
    }
    _load();
  }
}
