// Path: lib/features/movies/data/tmdb_api.dart
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import 'models/movie.dart';
import 'models/movie_detail.dart';
import 'models/cast.dart';
import 'models/video.dart';
import 'models/genre.dart';
import 'models/person.dart';
import 'models/person_detail.dart';

/// Tầng gọi TMDB API.
/// Tất cả request sẽ dùng Dio đã cấu hình sẵn Bearer Token ở DioClient.
class TmdbApi {
  final Dio _dio = DioClient.dio;

  /// Hàm generic để parse các endpoint trả về danh sách movie trong field "results"
  Future<List<Movie>> _fetchMovieList(
    String path, {
    int page = 1,
    Map<String, dynamic>? params,
  }) async {
    final response = await _dio.get(
      path,
      queryParameters: {
        "page": page,
        ...?params,
      },
    );
    final results = (response.data["results"] as List? ?? []);
    return results.map((e) => Movie.fromJson(e)).toList();
  }

  // ================= BASIC LISTS =================

  /// Trending movie trong ngày
  /// API: GET /trending/movie/day
  Future<List<Movie>> getTrending({int page = 1}) =>
      _fetchMovieList("/trending/movie/day", page: page);

  /// Đang chiếu (Now Playing)
  /// API: GET /movie/now_playing
  Future<List<Movie>> getNowPlaying({int page = 1}) =>
      _fetchMovieList("/movie/now_playing", page: page);

  /// Top rated
  /// API: GET /movie/top_rated
  Future<List<Movie>> getTopRated({int page = 1}) =>
      _fetchMovieList("/movie/top_rated", page: page);

  /// Search movie theo từ khóa
  /// API: GET /search/movie
  Future<List<Movie>> searchMovies(
    String query, {
    int page = 1,
  }) =>
      _fetchMovieList(
        "/search/movie",
        page: page,
        params: {"query": query, "include_adult": false},
      );

  // ================= MOVIE DETAIL + EXTRAS =================

  /// Chi tiết movie
  /// API: GET /movie/{movie_id}
  Future<MovieDetail> getMovieDetail(int movieId) async {
    final res = await _dio.get("/movie/$movieId");
    return MovieDetail.fromJson(res.data);
  }

  /// Credits (diễn viên, đoàn làm phim) của movie
  /// API: GET /movie/{movie_id}/credits
  Future<List<Cast>> getCredits(int movieId) async {
    final res = await _dio.get("/movie/$movieId/credits");
    final castJson = (res.data["cast"] as List? ?? []);
    return castJson.map((e) => Cast.fromJson(e)).toList();
  }

  /// Videos (trailer, teaser, v.v...) của movie
  /// API: GET /movie/{movie_id}/videos
  Future<List<Video>> getVideos(int movieId) async {
    final res = await _dio.get("/movie/$movieId/videos");
    final videosJson = (res.data["results"] as List? ?? []);
    return videosJson.map((e) => Video.fromJson(e)).toList();
  }

  /// Similar movies
  /// API: GET /movie/{movie_id}/similar
  Future<List<Movie>> getSimilar(
    int movieId, {
    int page = 1,
  }) =>
      _fetchMovieList("/movie/$movieId/similar", page: page);

  /// Recommendations – gợi ý phim dựa trên 1 movie_id
  /// API: GET /movie/{movie_id}/recommendations
  Future<List<Movie>> getRecommendations(
    int movieId, {
    int page = 1,
  }) =>
      _fetchMovieList("/movie/$movieId/recommendations", page: page);

  // ================= DISCOVER & GENRES =================

  /// Lấy danh sách thể loại (genres)
  /// API: GET /genre/movie/list
  Future<List<Genre>> getGenres() async {
    final res = await _dio.get("/genre/movie/list");
    final list = (res.data["genres"] as List? ?? []);
    return list.map((e) => Genre.fromJson(e)).toList();
  }

  /// Discover movie nâng cao:
  /// Cho phép filter theo:
  /// - with_genres: list id thể loại (ngăn cách bằng dấu phẩy)
  /// - primary_release_year: năm phát hành chính
  /// - vote_average.gte: điểm đánh giá tối thiểu
  /// - sort_by: tiêu chí sắp xếp (vd: popularity.desc, vote_average.desc,...)
  ///
  /// API: GET /discover/movie
  Future<List<Movie>> discoverMovies({
    int page = 1,
    List<int>? genreIds,
    int? year,
    double? minVoteAverage,
    String sortBy = "popularity.desc",
  }) async {
    final params = <String, dynamic>{
      "page": page,
      "sort_by": sortBy,
    };

    if (genreIds != null && genreIds.isNotEmpty) {
      params["with_genres"] = genreIds.join(",");
    }
    if (year != null) {
      params["primary_release_year"] = year;
    }
    if (minVoteAverage != null) {
      params["vote_average.gte"] = minVoteAverage;
    }

    return _fetchMovieList("/discover/movie", page: page, params: params);
  }

  // ================= PEOPLE =================

  /// People nổi tiếng (Popular People)
  /// API: GET /person/popular
  Future<List<Person>> getPopularPeople({int page = 1}) async {
    final res = await _dio.get("/person/popular", queryParameters: {
      "page": page,
    });
    final list = (res.data["results"] as List? ?? []);
    return list.map((e) => Person.fromJson(e)).toList();
  }

  /// Chi tiết 1 người nổi tiếng
  /// API: GET /person/{person_id}
  Future<PersonDetail> getPersonDetail(int personId) async {
    final res = await _dio.get("/person/$personId");
    return PersonDetail.fromJson(res.data);
  }

  /// Danh sách movie mà người này tham gia (movie credits)
  /// API: GET /person/{person_id}/movie_credits
  Future<List<Movie>> getPersonMovieCredits(int personId) async {
    final res = await _dio.get("/person/$personId/movie_credits");
    final castList = (res.data["cast"] as List? ?? []);
    // parse tương tự Movie
    return castList.map((e) => Movie.fromJson(e)).toList();
  }
}
