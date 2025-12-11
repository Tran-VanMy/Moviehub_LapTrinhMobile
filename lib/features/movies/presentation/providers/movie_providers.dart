// Path: lib/features/movies/presentation/providers/movie_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/tmdb_api.dart';
import '../../domain/movie_repository.dart';
import '../../data/models/movie.dart';
import '../../data/models/movie_detail.dart';
import '../../data/models/cast.dart';
import '../../data/models/video.dart';

final apiProvider = Provider<TmdbApi>((ref) => TmdbApi());
final repoProvider = Provider<MovieRepository>((ref) => MovieRepository(ref.read(apiProvider)));

/// Pagination state for movie lists
class MovieListState {
  final List<Movie> movies;
  final int page;
  final bool isLoading;
  final bool hasMore;

  MovieListState({
    this.movies = const [],
    this.page = 1,
    this.isLoading = false,
    this.hasMore = true,
  });

  MovieListState copyWith({
    List<Movie>? movies,
    int? page,
    bool? isLoading,
    bool? hasMore,
  }) =>
      MovieListState(
        movies: movies ?? this.movies,
        page: page ?? this.page,
        isLoading: isLoading ?? this.isLoading,
        hasMore: hasMore ?? this.hasMore,
      );
}

// ====== Trending Provider ======
final trendingProvider =
    StateNotifierProvider<MovieListNotifier, MovieListState>((ref) => MovieListNotifier(ref.read(repoProvider), type: "trending"));

// ====== Now Playing Provider ======
final nowPlayingProvider =
    StateNotifierProvider<MovieListNotifier, MovieListState>((ref) => MovieListNotifier(ref.read(repoProvider), type: "nowplaying"));

// ====== Top Rated Provider ======
final topRatedProvider =
    StateNotifierProvider<MovieListNotifier, MovieListState>((ref) => MovieListNotifier(ref.read(repoProvider), type: "toprated"));

class MovieListNotifier extends StateNotifier<MovieListState> {
  MovieListNotifier(this._repo, {required this.type}) : super(MovieListState()) {
    fetchNext();
  }
  final MovieRepository _repo;
  final String type;

  Future<void> fetchNext() async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoading: true);

    try {
      List<Movie> newMovies;
      if (type == "trending") {
        newMovies = await _repo.trending(state.page);
      } else if (type == "nowplaying") {
        newMovies = await _repo.nowPlaying(state.page);
      } else {
        newMovies = await _repo.topRated(state.page);
      }

      state = state.copyWith(
        movies: [...state.movies, ...newMovies],
        page: state.page + 1,
        hasMore: newMovies.isNotEmpty,
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }
}

// ===== DETAIL PROVIDERS =====
final movieDetailProvider = FutureProvider.family<MovieDetail, int>((ref, id) => ref.read(repoProvider).detail(id));
final movieCreditsProvider = FutureProvider.family<List<Cast>, int>((ref, id) => ref.read(repoProvider).credits(id));
final movieVideosProvider = FutureProvider.family<List<Video>, int>((ref, id) => ref.read(repoProvider).videos(id));
final similarMoviesProvider = FutureProvider.family<List<Movie>, int>((ref, id) => ref.read(repoProvider).similar(id, 1));
