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
      appBar: AppBar(
        title: const Text("MovieHub", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => Navigator.pushNamed(context, AppRouter.search),
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_rounded),
            onPressed: () => Navigator.pushNamed(context, AppRouter.watchlist),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(trendingProvider);
          ref.invalidate(nowPlayingProvider);
          ref.invalidate(topRatedProvider);
        },
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            // ===== Trending =====
            SectionHeader(
              title: "🔥 Trending Today",
              onSeeAll: () {},
            ),
            trending.movies.isEmpty
                ? const ShimmerList()
                : SizedBox(
                    height: 260,
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (scroll) {
                        if (scroll.metrics.pixels >= scroll.metrics.maxScrollExtent - 200) {
                          ref.read(trendingProvider.notifier).fetchNext();
                        }
                        return false;
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (_, i) => MovieCard(movie: trending.movies[i]),
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemCount: trending.movies.length,
                      ),
                    ),
                  ),

            const SizedBox(height: 6),

            // ===== Now Playing =====
            SectionHeader(title: "🎬 Now Playing", onSeeAll: () {}),
            nowPlaying.movies.isEmpty
                ? const ShimmerList()
                : _VerticalMovieList(
                    movies: nowPlaying.movies,
                    onLoadMore: () => ref.read(nowPlayingProvider.notifier).fetchNext(),
                  ),

            const SizedBox(height: 6),

            // ===== Top Rated =====
            SectionHeader(title: "⭐ Top Rated", onSeeAll: () {}),
            topRated.movies.isEmpty
                ? const ShimmerList()
                : _VerticalMovieList(
                    movies: topRated.movies,
                    onLoadMore: () => ref.read(topRatedProvider.notifier).fetchNext(),
                  ),
          ],
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
