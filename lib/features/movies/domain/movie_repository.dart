// Path: lib/features/movies/domain/movie_repository.dart
import '../data/tmdb_api.dart';
import '../data/models/movie.dart';
import '../data/models/movie_detail.dart';
import '../data/models/cast.dart';
import '../data/models/video.dart';

class MovieRepository {
  MovieRepository(this._api);
  final TmdbApi _api;

  Future<List<Movie>> trending(int page) => _api.getTrending(page: page);
  Future<List<Movie>> nowPlaying(int page) => _api.getNowPlaying(page: page);
  Future<List<Movie>> topRated(int page) => _api.getTopRated(page: page);

  Future<MovieDetail> detail(int id) => _api.getMovieDetail(id);
  Future<List<Cast>> credits(int id) => _api.getCredits(id);
  Future<List<Video>> videos(int id) => _api.getVideos(id);
  Future<List<Movie>> similar(int id, int page) => _api.getSimilar(id, page: page);

  Future<List<Movie>> search(String query, int page) => _api.searchMovies(query, page: page);
}
