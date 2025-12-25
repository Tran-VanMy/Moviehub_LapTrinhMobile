// Path: lib/features/movies/presentation/providers/movie_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/tmdb_api.dart';
import '../../domain/movie_repository.dart';
import '../../data/models/movie.dart';
import '../../data/models/movie_detail.dart';
import '../../data/models/cast.dart';
import '../../data/models/video.dart';
import '../../data/models/genre.dart';
import '../../data/models/person.dart';
import '../../data/models/person_detail.dart';

/// Provider khởi tạo TmdbApi
final apiProvider = Provider<TmdbApi>((ref) => TmdbApi());

/// Provider khởi tạo Repository dùng chung
final repoProvider =
    Provider<MovieRepository>((ref) => MovieRepository(ref.read(apiProvider)));

/// State cho list movie có phân trang (trending, now playing, top rated, discover,...)
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

/// State generic notifier cho các list movie dạng "load more"
class MovieListNotifier extends StateNotifier<MovieListState> {
  MovieListNotifier(this._repo, {required this.type}) : super(MovieListState()) {
    fetchNext();
  }

  final MovieRepository _repo;

  /// type: "trending", "nowplaying", "toprated"
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

// ====== Providers list phim chính trên Home ======
final trendingProvider = StateNotifierProvider<MovieListNotifier, MovieListState>(
  (ref) => MovieListNotifier(ref.read(repoProvider), type: "trending"),
);

final nowPlayingProvider =
    StateNotifierProvider<MovieListNotifier, MovieListState>(
  (ref) => MovieListNotifier(ref.read(repoProvider), type: "nowplaying"),
);

final topRatedProvider =
    StateNotifierProvider<MovieListNotifier, MovieListState>(
  (ref) => MovieListNotifier(ref.read(repoProvider), type: "toprated"),
);

// ===== DETAIL PROVIDERS =====
final movieDetailProvider =
    FutureProvider.family<MovieDetail, int>((ref, id) {
  return ref.read(repoProvider).detail(id);
});

final movieCreditsProvider =
    FutureProvider.family<List<Cast>, int>((ref, id) {
  return ref.read(repoProvider).credits(id);
});

final movieVideosProvider =
    FutureProvider.family<List<Video>, int>((ref, id) {
  return ref.read(repoProvider).videos(id);
});

final similarMoviesProvider =
    FutureProvider.family<List<Movie>, int>((ref, id) {
  return ref.read(repoProvider).similar(id, 1);
});

final recommendationsProvider =
    FutureProvider.family<List<Movie>, int>((ref, id) {
  return ref.read(repoProvider).recommendations(id, 1);
});

// ===== GENRES & DISCOVER =====

/// Lấy toàn bộ danh sách thể loại để show dưới dạng chip filter
final genresProvider = FutureProvider<List<Genre>>((ref) {
  return ref.read(repoProvider).genres();
});

/// State cho Discover filter (selected genres, year, minVote, sort)
class DiscoverFilterState {
  final List<Genre> allGenres;
  final List<int> selectedGenreIds;
  final int? year;
  final double? minVote;
  final String sortBy;

  DiscoverFilterState({
    this.allGenres = const [],
    this.selectedGenreIds = const [],
    this.year,
    this.minVote,
    this.sortBy = "popularity.desc",
  });

  DiscoverFilterState copyWith({
    List<Genre>? allGenres,
    List<int>? selectedGenreIds,
    int? year,
    double? minVote,
    String? sortBy,
  }) {
    return DiscoverFilterState(
      allGenres: allGenres ?? this.allGenres,
      selectedGenreIds: selectedGenreIds ?? this.selectedGenreIds,
      year: year ?? this.year,
      minVote: minVote ?? this.minVote,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

/// Notifier quản lý filter cho Discover
class DiscoverFilterNotifier extends StateNotifier<DiscoverFilterState> {
  DiscoverFilterNotifier(this._repo) : super(DiscoverFilterState()) {
    _init();
  }

  final MovieRepository _repo;

  Future<void> _init() async {
    final genres = await _repo.genres();
    state = state.copyWith(allGenres: genres);
  }

  void toggleGenre(int genreId) {
    final current = [...state.selectedGenreIds];
    if (current.contains(genreId)) {
      current.remove(genreId);
    } else {
      current.add(genreId);
    }
    state = state.copyWith(selectedGenreIds: current);
  }

  void setYear(int? year) {
    state = state.copyWith(year: year);
  }

  void setMinVote(double? vote) {
    state = state.copyWith(minVote: vote);
  }

  void setSortBy(String sortBy) {
    state = state.copyWith(sortBy: sortBy);
  }

  void reset() {
    state = DiscoverFilterState(allGenres: state.allGenres);
  }
}

final discoverFilterProvider =
    StateNotifierProvider<DiscoverFilterNotifier, DiscoverFilterState>(
  (ref) => DiscoverFilterNotifier(ref.read(repoProvider)),
);

/// Kết quả Discover theo filter hiện tại
final discoverResultsProvider = FutureProvider<List<Movie>>((ref) async {
  final repo = ref.read(repoProvider);
  final filter = ref.watch(discoverFilterProvider);

  return repo.discover(
    page: 1,
    genreIds: filter.selectedGenreIds.isEmpty
        ? null
        : filter.selectedGenreIds,
    year: filter.year,
    minVote: filter.minVote,
    sortBy: filter.sortBy,
  );
});

// ===== PEOPLE =====

/// Danh sách người nổi tiếng
final popularPeopleProvider =
    FutureProvider.autoDispose<List<Person>>((ref) async {
  return ref.read(repoProvider).popularPeople(1);
});

/// Chi tiết người nổi tiếng
final personDetailProvider =
    FutureProvider.family<PersonDetail, int>((ref, id) {
  return ref.read(repoProvider).personDetail(id);
});

/// Movie credits của 1 người (đã tham gia phim nào)
final personCreditsProvider =
    FutureProvider.family<List<Movie>, int>((ref, id) {
  return ref.read(repoProvider).personMovieCredits(id);
});
