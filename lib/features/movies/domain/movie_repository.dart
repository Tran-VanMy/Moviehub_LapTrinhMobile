// Path: lib/features/movies/domain/movie_repository.dart
import '../data/tmdb_api.dart';
import '../data/models/movie.dart';
import '../data/models/movie_detail.dart';
import '../data/models/cast.dart';
import '../data/models/video.dart';
import '../data/models/genre.dart';
import '../data/models/person.dart';
import '../data/models/person_detail.dart';

// NEW
import '../data/models/review.dart';
import '../data/models/watch_provider.dart';

class MovieRepository {
  MovieRepository(this._api);
  final TmdbApi _api;

  // ========= LIST CƠ BẢN =========
  Future<List<Movie>> trending(int page) => _api.getTrending(page: page);
  Future<List<Movie>> nowPlaying(int page) => _api.getNowPlaying(page: page);
  Future<List<Movie>> topRated(int page) => _api.getTopRated(page: page);
  Future<List<Movie>> popular(int page) => _api.getPopular(page: page);
  Future<List<Movie>> upcoming(int page) => _api.getUpcoming(page: page);

  // ========= DETAIL =========
  Future<MovieDetail> detail(int id) => _api.getMovieDetail(id);
  Future<List<Cast>> credits(int id) => _api.getCredits(id);
  Future<List<Video>> videos(int id) => _api.getVideos(id);
  Future<List<Movie>> similar(int id, int page) => _api.getSimilar(id, page: page);
  Future<List<Movie>> recommendations(int id, int page) =>
      _api.getRecommendations(id, page: page);

  Future<List<Movie>> search(String query, int page) =>
      _api.searchMovies(query, page: page);

  // ========= REVIEWS =========
  Future<List<Review>> reviews(int id, {int page = 1}) =>
      _api.getReviews(id, page: page);

  // ========= WATCH PROVIDERS =========
  Future<WatchProvidersResult?> watchProviders(int id, {required String region}) =>
      _api.getWatchProviders(id, region: region);

  // ========= GENRES & DISCOVER =========
  Future<List<Genre>> genres() => _api.getGenres();

  Future<List<Movie>> discover({
    int page = 1,
    List<int>? genreIds,
    int? year,
    double? minVote,
    String sortBy = "popularity.desc",
  }) =>
      _api.discoverMovies(
        page: page,
        genreIds: genreIds,
        year: year,
        minVoteAverage: minVote,
        sortBy: sortBy,
      );

  // ========= PEOPLE =========
  Future<List<Person>> popularPeople(int page) => _api.getPopularPeople(page: page);
  Future<PersonDetail> personDetail(int id) => _api.getPersonDetail(id);
  Future<List<Movie>> personMovieCredits(int id) => _api.getPersonMovieCredits(id);
}
