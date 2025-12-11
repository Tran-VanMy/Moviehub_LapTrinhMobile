// Path: lib/features/movies/data/tmdb_api.dart
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import 'models/movie.dart';
import 'models/movie_detail.dart';
import 'models/cast.dart';
import 'models/video.dart';

class TmdbApi {
  final Dio _dio = DioClient.dio;

  // Generic list fetcher for endpoints returning "results"
  Future<List<Movie>> _fetchMovieList(String path, {int page = 1, Map<String, dynamic>? params}) async {
    final response = await _dio.get(path, queryParameters: {"page": page, ...?params});
    final results = (response.data["results"] as List? ?? []);
    return results.map((e) => Movie.fromJson(e)).toList();
  }

  Future<List<Movie>> getTrending({int page = 1}) => _fetchMovieList("/trending/movie/day", page: page);

  Future<List<Movie>> getNowPlaying({int page = 1}) => _fetchMovieList("/movie/now_playing", page: page);

  Future<List<Movie>> getTopRated({int page = 1}) => _fetchMovieList("/movie/top_rated", page: page);

  Future<List<Movie>> searchMovies(String query, {int page = 1}) =>
      _fetchMovieList("/search/movie", page: page, params: {"query": query, "include_adult": false});

  Future<MovieDetail> getMovieDetail(int movieId) async {
    final res = await _dio.get("/movie/$movieId");
    return MovieDetail.fromJson(res.data);
  }

  Future<List<Cast>> getCredits(int movieId) async {
    final res = await _dio.get("/movie/$movieId/credits");
    final castJson = (res.data["cast"] as List? ?? []);
    return castJson.map((e) => Cast.fromJson(e)).toList();
  }

  Future<List<Video>> getVideos(int movieId) async {
    final res = await _dio.get("/movie/$movieId/videos");
    final videosJson = (res.data["results"] as List? ?? []);
    return videosJson.map((e) => Video.fromJson(e)).toList();
  }

  Future<List<Movie>> getSimilar(int movieId, {int page = 1}) =>
      _fetchMovieList("/movie/$movieId/similar", page: page);
}
