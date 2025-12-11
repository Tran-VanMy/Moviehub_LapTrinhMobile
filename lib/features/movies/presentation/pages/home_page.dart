// Path: lib/features/movies/presentation/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/router.dart';
import '../providers/movie_providers.dart';
import '../widgets/section_header.dart';
import '../widgets/movie_card.dart';
import '../widgets/shimmer_list.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trending = ref.watch(trendingProvider);
    final nowPlaying = ref.watch(nowPlayingProvider);
    final topRated = ref.watch(topRatedProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(trendingProvider);
            ref.invalidate(nowPlayingProvider);
            ref.invalidate(topRatedProvider);
          },
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              // ===== Header =====
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.movie_filter_rounded, size: 28),
                    const SizedBox(width: 8),
                    const Text(
                      "MovieHub",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.search_rounded),
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRouter.search),
                    ),
                    IconButton(
                      icon: const Icon(Icons.bookmark_rounded),
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRouter.watchlist),
                    ),
                  ],
                ),
              ),

              // ===== Trending Today =====
              SectionHeader(
                title: "🔥 Trending Today",
                onSeeAll: () => Navigator.pushNamed(
                  context,
                  AppRouter.allMovies,
                  arguments: {
                    "title": "Trending Today",
                    "type": "trending",
                  },
                ),
              ),
              trending.movies.isEmpty
                  ? const ShimmerList()
                  : _TrendingCarousel(
                      movies: trending.movies,
                      onLoadMore: () =>
                          ref.read(trendingProvider.notifier).fetchNext(),
                    ),

              const SizedBox(height: 6),

              // ===== Now Playing =====
              SectionHeader(
                title: "🎬 Now Playing",
                onSeeAll: () => Navigator.pushNamed(
                  context,
                  AppRouter.allMovies,
                  arguments: {
                    "title": "Now Playing",
                    "type": "nowplaying",
                  },
                ),
              ),
              nowPlaying.movies.isEmpty
                  ? const ShimmerList()
                  : _VerticalMovieList(
                      movies: nowPlaying.movies,
                      onLoadMore: () =>
                          ref.read(nowPlayingProvider.notifier).fetchNext(),
                    ),

              const SizedBox(height: 6),

              // ===== Top Rated =====
              SectionHeader(
                title: "⭐ Top Rated",
                onSeeAll: () => Navigator.pushNamed(
                  context,
                  AppRouter.allMovies,
                  arguments: {
                    "title": "Top Rated",
                    "type": "toprated",
                  },
                ),
              ),
              topRated.movies.isEmpty
                  ? const ShimmerList()
                  : _VerticalMovieList(
                      movies: topRated.movies,
                      onLoadMore: () =>
                          ref.read(topRatedProvider.notifier).fetchNext(),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

/// List dọc cho Now Playing / Top Rated
class _VerticalMovieList extends StatelessWidget {
  const _VerticalMovieList({required this.movies, required this.onLoadMore});

  final List movies;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scroll) {
        if (scroll.metrics.pixels >=
            scroll.metrics.maxScrollExtent - 200) {
          onLoadMore();
        }
        return false;
      },
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (_, i) =>
            MovieCard(movie: movies[i], isHorizontal: true),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemCount: movies.length,
      ),
    );
  }
}

/// Carousel cho Trending Today với hai nút < >
class _TrendingCarousel extends StatefulWidget {
  const _TrendingCarousel({
    required this.movies,
    required this.onLoadMore,
  });

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
    // viewportFraction < 1 để các item hơi lộ ra hai bên cho đẹp
    _pageController = PageController(viewportFraction: 0.58);
  }

  @override
  void didUpdateWidget(covariant _TrendingCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Nếu số lượng phim tăng thêm (fetchNext), giữ vị trí hiện tại
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

    // Nếu đã gần cuối list thì gọi loadMore để lấy thêm trang
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
          // PageView hiển thị các MovieCard
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

          // Nút < bên trái
          Positioned(
            left: 4,
            child: _ArrowButton(
              icon: Icons.chevron_left_rounded,
              enabled: canGoLeft,
              onTap: () => _goToPage(_currentPage - 1),
            ),
          ),

          // Nút > bên phải
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

/// Nút mũi tên tròn dùng chung
class _ArrowButton extends StatelessWidget {
  const _ArrowButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled
          ? Colors.black.withOpacity(0.5)
          : Colors.black.withOpacity(0.2),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: enabled ? onTap : null,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            size: 24,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
