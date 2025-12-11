// Path: lib/features/movies/presentation/pages/movie_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../../../core/constants.dart';
import '../../data/models/movie.dart';
import '../../data/models/video.dart';
import '../providers/movie_providers.dart';
import '../providers/watchlist_providers.dart';
import '../widgets/cast_list.dart';
import '../widgets/movie_card.dart';

class MovieDetailPage extends ConsumerWidget {
  const MovieDetailPage({super.key, required this.movieId});
  final int movieId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(movieDetailProvider(movieId));
    final castAsync = ref.watch(movieCreditsProvider(movieId));
    final videosAsync = ref.watch(movieVideosProvider(movieId));
    final similarAsync = ref.watch(similarMoviesProvider(movieId));
    final watchlist = ref.watch(watchlistProvider);

    return Scaffold(
      body: detailAsync.when(
        data: (detail) {
          final isSaved = watchlist.any((m) => m.id == detail.id);

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: detail.backdropPath.isEmpty
                      ? Container(color: Colors.black12)
                      : Image.network(
                          "${AppConstants.imageBaseUrl}${detail.backdropPath}",
                          fit: BoxFit.cover,
                        ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      isSaved
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_outline_rounded,
                    ),
                    onPressed: () {
                      ref.read(watchlistProvider.notifier).toggle(
                            MovieLiteMapper.fromDetail(detail),
                          );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isSaved
                                ? "Removed from watchlist"
                                : "Saved to watchlist",
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        detail.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(detail.voteAverage.toStringAsFixed(1)),
                          const SizedBox(width: 10),
                          Text("${detail.runtime} min"),
                        ],
                      ),
                      const SizedBox(height: 8),

                      Wrap(
                        spacing: 8,
                        children: detail.genres
                            .map(
                              (g) => Chip(
                                label: Text(g),
                                backgroundColor: Colors.white,
                              ),
                            )
                            .toList(),
                      ),

                      const SizedBox(height: 12),
                      Text(
                        detail.overview,
                        style: const TextStyle(fontSize: 15),
                      ),
                      const SizedBox(height: 18),

                      // ===== Trailer với youtube_player_iframe =====
                      videosAsync.when(
                        data: (videos) {
                          Video? ytTrailer;
                          for (final v in videos) {
                            final isYoutube =
                                v.site.toLowerCase() == "youtube";
                            final isTrailer =
                                v.type.toLowerCase().contains("trailer");
                            if (isYoutube && isTrailer) {
                              ytTrailer = v;
                              break;
                            }
                          }
                          if (ytTrailer == null) {
                            return const SizedBox.shrink();
                          }

                          final controller = YoutubePlayerController.fromVideoId(
                            videoId: ytTrailer.key,
                            autoPlay: false,
                            params: const YoutubePlayerParams(
                              showFullscreenButton: true,
                              showControls: true,
                              strictRelatedVideos: true,
                            ),
                          );

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Trailer",
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: YoutubePlayer(
                                    controller: controller,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                            ],
                          );
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (_, __) => const SizedBox.shrink(),
                      ),

                      // ===== Cast =====
                      castAsync.when(
                        data: (cast) => CastList(
                          cast: cast.take(12).toList(),
                        ),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),

                      const SizedBox(height: 18),

                      // ===== Similar Movies =====
                      similarAsync.when(
                        data: (movies) {
                          if (movies.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Similar Movies",
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                // tăng chiều cao để không overflow
                                height: 280,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (_, i) =>
                                      MovieCard(movie: movies[i]),
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(width: 12),
                                  itemCount: movies.length,
                                ),
                              ),
                            ],
                          );
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
      ),
    );
  }
}

/// Helper mapper to save detail as Movie in watchlist
class MovieLiteMapper {
  static Movie fromDetail(detail) {
    return Movie(
      id: detail.id,
      title: detail.title,
      posterPath: detail.backdropPath,
      voteAverage: detail.voteAverage,
      releaseDate: "",
    );
  }
}
