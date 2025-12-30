// Path: lib/core/constants.dart
class AppConstants {
  // ===== TMDB API =====
  static const String tmdbBaseUrl = "https://api.themoviedb.org/3";

  // IMPORTANT: DÁN READ ACCESS TOKEN (v4) ở đây
  static const String tmdbBearerToken =
      "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI2MjdjZGEzMzhiYTk1YzcyZGM0NDdlODAxMTJkOTNhNiIsIm5iZiI6MTc2NDg1MTgzOS40MDYwMDAxLCJzdWIiOiI2OTMxODA3ZjVjNjg2MWI4MzBmMjQ3ZmMiLCJzY29wZXMiOlsiYXBpX3JlYWQiXSwidmVyc2lvbiI6MX0.-9__ws7KfMm0Z2YIN8WMYcqmYcz_Feugn-ZNspbuAmY";

  // Image base
  static const String imageBaseUrl = "https://image.tmdb.org/t/p/w500";

  // Hive box name
  static const String watchlistBox = "watchlist_box";

  // NEW: Favorite movies box
  static const String favoriteBox = "favorite_box";

  // NEW: Settings box (theme + locale + palette)
  static const String settingsBox = "settings_box";
}
