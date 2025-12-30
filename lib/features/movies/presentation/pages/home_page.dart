// Path: lib/features/movies/presentation/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/i18n/app_i18n.dart';
import '../../../../core/router.dart';
import '../../../../core/settings/settings_provider.dart';
import '../providers/movie_providers.dart';
import '../widgets/section_header.dart';
import '../widgets/movie_card.dart';
import '../widgets/shimmer_list.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i18n = AppI18n.of(context);

    final trending = ref.watch(trendingProvider);
    final nowPlaying = ref.watch(nowPlayingProvider);
    final topRated = ref.watch(topRatedProvider);
    final popular = ref.watch(popularProvider);
    final upcoming = ref.watch(upcomingProvider);

    final palette = ref.watch(settingsProvider).palette;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(trendingProvider);
            ref.invalidate(nowPlayingProvider);
            ref.invalidate(topRatedProvider);
            ref.invalidate(popularProvider);
            ref.invalidate(upcomingProvider);
          },
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              // ===== Header + actions =====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: palette.gradient,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.movie_filter_rounded,
                        size: 26,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          i18n.t("app_name"),
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                        ),
                        Text(
                          "TMDB • Flutter • Riverpod",
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: i18n.t("search"),
                      icon: const Icon(Icons.search_rounded),
                      onPressed: () => Navigator.pushNamed(context, AppRouter.search),
                    ),
                    IconButton(
                      tooltip: i18n.t("discover"),
                      icon: const Icon(Icons.explore_rounded),
                      onPressed: () => Navigator.pushNamed(context, AppRouter.discover),
                    ),
                    IconButton(
                      tooltip: i18n.t("settings"),
                      icon: const Icon(Icons.settings_rounded),
                      onPressed: () => Navigator.pushNamed(context, AppRouter.settings),
                    ),
                  ],
                ),
              ),

              // ===== Gradient banner =====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  elevation: 0.9,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: palette.gradient,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 30),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Discover • Reviews • Watch Providers • Favorites",
                            style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.4),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: theme.colorScheme.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: () => Navigator.pushNamed(context, AppRouter.discover),
                          icon: const Icon(Icons.explore_rounded, size: 18),
                          label: Text(i18n.t("discover"), style: const TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Quick buttons: Watchlist & Favorites & People
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pushNamed(context, AppRouter.watchlist),
                        icon: const Icon(Icons.bookmark_rounded),
                        label: Text(i18n.t("watchlist")),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pushNamed(context, AppRouter.favorites),
                        icon: const Icon(Icons.favorite_rounded),
                        label: Text(i18n.t("favorites")),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, AppRouter.people),
                  icon: const Icon(Icons.people_alt_rounded),
                  label: Text(i18n.t("popular_people")),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // ===== Trending Today =====
              SectionHeader(
                title: "🔥 ${i18n.t("trending_today")}",
                trailingIcon: Icons.local_fire_department_rounded,
                onSeeAll: () => Navigator.pushNamed(
                  context,
                  AppRouter.allMovies,
                  arguments: {"title": i18n.t("trending_today"), "type": "trending"},
                ),
              ),
              trending.movies.isEmpty
                  ? const ShimmerList()
                  : _TrendingCarousel(
                      movies: trending.movies,
                      onLoadMore: () => ref.read(trendingProvider.notifier).fetchNext(),
                    ),

              const SizedBox(height: 8),

              // ===== Now Playing =====
              SectionHeader(
                title: "🎬 ${i18n.t("now_playing")}",
                trailingIcon: Icons.play_circle_fill_rounded,
                onSeeAll: () => Navigator.pushNamed(
                  context,
                  AppRouter.allMovies,
                  arguments: {"title": i18n.t("now_playing"), "type": "nowplaying"},
                ),
              ),
              nowPlaying.movies.isEmpty
                  ? const ShimmerList()
                  : _VerticalMovieList(
                      movies: nowPlaying.movies,
                      onLoadMore: () => ref.read(nowPlayingProvider.notifier).fetchNext(),
                    ),

              const SizedBox(height: 8),

              // ===== Top Rated =====
              SectionHeader(
                title: "⭐ ${i18n.t("top_rated")}",
                trailingIcon: Icons.emoji_events_rounded,
                onSeeAll: () => Navigator.pushNamed(
                  context,
                  AppRouter.allMovies,
                  arguments: {"title": i18n.t("top_rated"), "type": "toprated"},
                ),
              ),
              topRated.movies.isEmpty
                  ? const ShimmerList()
                  : _VerticalMovieList(
                      movies: topRated.movies,
                      onLoadMore: () => ref.read(topRatedProvider.notifier).fetchNext(),
                    ),

              const SizedBox(height: 8),

              // ===== Popular =====
              SectionHeader(
                title: "✨ ${i18n.t("popular")}",
                trailingIcon: Icons.trending_up_rounded,
                onSeeAll: () => Navigator.pushNamed(
                  context,
                  AppRouter.allMovies,
                  arguments: {"title": i18n.t("popular"), "type": "popular"},
                ),
              ),
              popular.movies.isEmpty
                  ? const ShimmerList()
                  : _VerticalMovieList(
                      movies: popular.movies,
                      onLoadMore: () => ref.read(popularProvider.notifier).fetchNext(),
                    ),

              const SizedBox(height: 8),

              // ===== Upcoming =====
              SectionHeader(
                title: "🗓️ ${i18n.t("upcoming")}",
                trailingIcon: Icons.calendar_month_rounded,
                onSeeAll: () => Navigator.pushNamed(
                  context,
                  AppRouter.allMovies,
                  arguments: {"title": i18n.t("upcoming"), "type": "upcoming"},
                ),
              ),
              upcoming.movies.isEmpty
                  ? const ShimmerList()
                  : _VerticalMovieList(
                      movies: upcoming.movies,
                      onLoadMore: () => ref.read(upcomingProvider.notifier).fetchNext(),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VerticalMovieList extends StatelessWidget {
  const _VerticalMovieList({required this.movies, required this.onLoadMore});

  final List movies;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scroll) {
        if (scroll.metrics.pixels >= scroll.metrics.maxScrollExtent - 200) {
          onLoadMore();
        }
        return false;
      },
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (_, i) => MovieCard(movie: movies[i], isHorizontal: true),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemCount: movies.length,
      ),
    );
  }
}

class _TrendingCarousel extends StatefulWidget {
  const _TrendingCarousel({required this.movies, required this.onLoadMore});

  final List movies;
  final VoidCallback onLoadMore;

  @override
  State<_TrendingCarousel> createState() => _TrendingCarouselState();
}

class _TrendingCarouselState extends State<_TrendingCarousel> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.58);
  }

  @override
  void didUpdateWidget(covariant _TrendingCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_currentPage >= widget.movies.length) {
      _currentPage = widget.movies.length - 1;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int index) {
    if (index < 0 || index >= widget.movies.length) return;

    setState(() => _currentPage = index);

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );

    if (index >= widget.movies.length - 3) {
      widget.onLoadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final canGoLeft = _currentPage > 0;
    final canGoRight = _currentPage < widget.movies.length - 1;

    return SizedBox(
      height: 290,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.movies.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
              if (index >= widget.movies.length - 3) {
                widget.onLoadMore();
              }
            },
            itemBuilder: (context, index) {
              final movie = widget.movies[index];
              return Padding(
                padding: const EdgeInsets.only(left: 12, right: 12),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: MovieCard(movie: movie),
                ),
              );
            },
          ),
          Positioned(
            left: 4,
            child: _ArrowButton(
              icon: Icons.chevron_left_rounded,
              enabled: canGoLeft,
              onTap: () => _goToPage(_currentPage - 1),
            ),
          ),
          Positioned(
            right: 4,
            child: _ArrowButton(
              icon: Icons.chevron_right_rounded,
              enabled: canGoRight,
              onTap: () => _goToPage(_currentPage + 1),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({required this.icon, required this.enabled, required this.onTap});

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.2),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: enabled ? onTap : null,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 24, color: Colors.white),
        ),
      ),
    );
  }
}
