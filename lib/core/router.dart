// Path: lib/core/router.dart
import 'package:flutter/material.dart';
import '../features/movies/presentation/pages/home_page.dart';
import '../features/movies/presentation/pages/movie_detail_page.dart';
import '../features/movies/presentation/pages/watchlist_page.dart';
import '../features/movies/presentation/pages/search_page.dart';

class AppRouter {
  static const home = "/";
  static const detail = "/detail";
  static const watchlist = "/watchlist";
  static const search = "/search";

  static Route onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case detail:
        final movieId = settings.arguments as int;
        return MaterialPageRoute(builder: (_) => MovieDetailPage(movieId: movieId));
      case watchlist:
        return MaterialPageRoute(builder: (_) => const WatchlistPage());
      case search:
        return MaterialPageRoute(builder: (_) => const SearchPage());
      default:
        return MaterialPageRoute(builder: (_) => const HomePage());
    }
  }
}
