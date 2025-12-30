// Path: lib/core/router.dart
import 'package:flutter/material.dart';

import '../features/movies/presentation/pages/home_page.dart';
import '../features/movies/presentation/pages/movie_detail_page.dart';
import '../features/movies/presentation/pages/watchlist_page.dart';
import '../features/movies/presentation/pages/search_page.dart';
import '../features/movies/presentation/pages/login_page.dart';
import '../features/movies/presentation/pages/all_movies_page.dart';
import '../features/movies/presentation/pages/discover_page.dart';
import '../features/movies/presentation/pages/people_page.dart';
import '../features/movies/presentation/pages/person_detail_page.dart';

// NEW
import '../features/movies/presentation/pages/favorites_page.dart';
import '../features/movies/presentation/pages/settings_page.dart';
import '../features/movies/presentation/pages/about_page.dart';

class AppRouter {
  static const login = "/login";
  static const home = "/";
  static const detail = "/detail";
  static const watchlist = "/watchlist";
  static const favorites = "/favorites";
  static const search = "/search";
  static const allMovies = "/allMovies";
  static const discover = "/discover";
  static const people = "/people";
  static const personDetail = "/personDetail";
  static const settings = "/settings";
  static const about = "/about";

  static Route onGenerateRoute(RouteSettings settingsRoute) {
    switch (settingsRoute.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case detail:
        final movieId = settingsRoute.arguments as int;
        return MaterialPageRoute(
          builder: (_) => MovieDetailPage(movieId: movieId),
        );
      case watchlist:
        return MaterialPageRoute(builder: (_) => const WatchlistPage());
      case favorites:
        return MaterialPageRoute(builder: (_) => const FavoritesPage());
      case search:
        return MaterialPageRoute(builder: (_) => const SearchPage());
      case allMovies:
        final args = settingsRoute.arguments as Map<String, String>;
        return MaterialPageRoute(
          builder: (_) => AllMoviesPage(
            title: args["title"]!,
            type: args["type"]!,
          ),
        );
      case discover:
        return MaterialPageRoute(builder: (_) => const DiscoverPage());
      case people:
        return MaterialPageRoute(builder: (_) => const PeoplePage());
      case personDetail:
        final personId = settingsRoute.arguments as int;
        return MaterialPageRoute(
          builder: (_) => PersonDetailPage(personId: personId),
        );
      case AppRouter.settings:
        return MaterialPageRoute(builder: (_) => const SettingsPage());
      case AppRouter.about:
        return MaterialPageRoute(builder: (_) => const AboutPage());
      default:
        return MaterialPageRoute(builder: (_) => const LoginPage());
    }
  }
}
