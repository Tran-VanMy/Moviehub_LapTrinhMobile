// Path: lib/core/constants.dart
class AppConstants {
  // ===== TMDB API =====
  static const String tmdbBaseUrl = "https://api.themoviedb.org/3";

  // IMPORTANT: DÁN READ ACCESS TOKEN (v4) ở đây
  // Lấy tại: https://developer.themoviedb.org/docs/authentication-application
  static const String tmdbBearerToken = "MY_ACCESS_TOKEN";

  // Image base
  static const String imageBaseUrl = "https://image.tmdb.org/t/p/w500";

  // Hive box name
  static const String watchlistBox = "watchlist_box";
}
