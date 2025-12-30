// Path: lib/features/movies/presentation/providers/favorite_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../../../core/constants.dart';
import '../../data/models/movie.dart';

final favoriteProvider =
    StateNotifierProvider<FavoriteNotifier, List<Movie>>((ref) {
  return FavoriteNotifier();
});

class FavoriteNotifier extends StateNotifier<List<Movie>> {
  FavoriteNotifier() : super([]) {
    _load();
  }

  final Box<Map> _box = Hive.box<Map>(AppConstants.favoriteBox);

  void _load() {
    final values = _box.values
        .map((m) => Movie.fromMap(Map<String, dynamic>.from(m)))
        .toList();
    state = values;
  }

  bool isFav(int id) => state.any((m) => m.id == id);

  void toggle(Movie movie) {
    if (isFav(movie.id)) {
      _box.delete(movie.id);
    } else {
      _box.put(movie.id, movie.toMap());
    }
    _load();
  }
}
