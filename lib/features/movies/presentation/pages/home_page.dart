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

    final theme = Theme.of(context);

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
              // ===== Header mới: có tagline + các icon hành động =====
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.movie_filter_rounded,
                        size: 26,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "MovieHub",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          "Khám phá phim chất lượng từ TMDB",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: "Search",
                      icon: const Icon(Icons.search_rounded),
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRouter.search),
                    ),
                    IconButton(
                      tooltip: "Discover",
                      icon: const Icon(Icons.explore_rounded),
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRouter.discover),
                    ),
                    IconButton(
                      tooltip: "Watchlist",
                      icon: const Icon(Icons.bookmark_rounded),
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRouter.watchlist),
                    ),
                  ],
                ),
              ),

              // ===== Banner nhỏ giới thiệu =====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 0.7,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary.withOpacity(0.95),
                          theme.colorScheme.primary.withOpacity(0.75),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 30,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Tìm kiếm, lọc phim theo thể loại, năm, điểm đánh giá và nhiều hơn nữa với Discover.",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: theme.colorScheme.primary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () =>
                              Navigator.pushNamed(context, AppRouter.discover),
                          icon: const Icon(Icons.explore_rounded, size: 18),
                          label: const Text(
                            "Discover",
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ===== Trending Today =====
              SectionHeader(
                title: "🔥 Trending Today",
                trailingIcon: Icons.local_fire_department_rounded,
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

              const SizedBox(height: 8),


              // ===== People short cut =====
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: OutlinedButton.icon(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRouter.people),
                  icon: const Icon(Icons.people_alt_rounded),
                  label: const Text("Khám phá người nổi tiếng"),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 10),

              // ===== Now Playing =====
              SectionHeader(
                title: "🎬 Now Playing",
                trailingIcon: Icons.play_circle_fill_rounded,
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

              const SizedBox(height: 8),

              // ===== Top Rated =====
              SectionHeader(
                title: "⭐ Top Rated",
                trailingIcon: Icons.emoji_events_rounded,
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

              const SizedBox(height: 8),


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
        if (scroll.metrics.pixels >= scroll.metrics.maxScrollExtent - 200) {
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
