// Path: lib/features/movies/presentation/pages/movie_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../../../core/constants.dart';
import '../../../../core/i18n/app_i18n.dart';
import '../../data/models/movie.dart';
import '../../data/models/video.dart';
import '../../data/models/review.dart';
import '../../data/models/watch_provider.dart';
import '../providers/movie_providers.dart';
import '../providers/watchlist_providers.dart';
import '../providers/favorite_providers.dart';
import '../widgets/cast_list.dart';
import '../widgets/movie_card.dart';

class MovieDetailPage extends ConsumerWidget {
  const MovieDetailPage({super.key, required this.movieId});
  final int movieId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i18n = AppI18n.of(context);

    final detailAsync = ref.watch(movieDetailProvider(movieId));
    final castAsync = ref.watch(movieCreditsProvider(movieId));
    final videosAsync = ref.watch(movieVideosProvider(movieId));
    final similarAsync = ref.watch(similarMoviesProvider(movieId));
    final recoAsync = ref.watch(recommendationsProvider(movieId));

    final reviewsAsync = ref.watch(movieReviewsProvider(movieId));
    final providersAsync = ref.watch(watchProvidersProvider(movieId));

    final watchlist = ref.watch(watchlistProvider);
    final favorites = ref.watch(favoriteProvider);

    return Scaffold(
      body: detailAsync.when(
        data: (detail) {
          final isSaved = watchlist.any((m) => m.id == detail.id);
          final isFav = favorites.any((m) => m.id == detail.id);

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
                  // Favorite
                  IconButton(
                    tooltip: isFav ? "Unfavorite" : "Favorite",
                    icon: Icon(
                      isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: isFav ? Colors.pinkAccent : null,
                    ),
                    onPressed: () {
                      ref.read(favoriteProvider.notifier).toggle(
                            MovieLiteMapper.fromDetail(detail),
                          );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(isFav ? "Removed from favorites" : "Added to favorites")),
                      );
                    },
                  ),
                  // Watchlist
                  IconButton(
                    tooltip: isSaved ? "Remove from watchlist" : "Save to watchlist",
                    icon: Icon(
                      isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                    ),
                    onPressed: () {
                      ref.read(watchlistProvider.notifier).toggle(
                            MovieLiteMapper.fromDetail(detail),
                          );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(isSaved ? "Removed from watchlist" : "Saved to watchlist")),
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
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(detail.voteAverage.toStringAsFixed(1)),
                          const SizedBox(width: 10),
                          const Icon(Icons.schedule_rounded, size: 18),
                          const SizedBox(width: 4),
                          Text("${detail.runtime} min"),
                        ],
                      ),
                      const SizedBox(height: 8),

                      Wrap(
                        spacing: 8,
                        children: detail.genres
                            .map(
                              (g) => Chip(
                                avatar: const Icon(Icons.local_movies_rounded, size: 16),
                                label: Text(g),
                              ),
                            )
                            .toList(),
                      ),

                      const SizedBox(height: 12),
                      Text(detail.overview, style: const TextStyle(fontSize: 15, height: 1.4)),
                      const SizedBox(height: 18),

                      // ===== Trailer =====
                      videosAsync.when(
                        data: (videos) {
                          Video? ytTrailer;
                          for (final v in videos) {
                            final isYoutube = v.site.toLowerCase() == "youtube";
                            final isTrailer = v.type.toLowerCase().contains("trailer");
                            if (isYoutube && isTrailer) {
                              ytTrailer = v;
                              break;
                            }
                          }
                          if (ytTrailer == null) return const SizedBox.shrink();

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
                              const Text("Trailer",
                                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: YoutubePlayer(controller: controller),
                                ),
                              ),
                              const SizedBox(height: 18),
                            ],
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (_, __) => const SizedBox.shrink(),
                      ),

                      // ===== Watch Providers =====
                      providersAsync.when(
                        data: (result) => _WatchProvidersSection(
                          title: i18n.t("where_to_watch"),
                          result: result,
                        ),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),

                      const SizedBox(height: 18),

                      // ===== Cast =====
                      castAsync.when(
                        data: (cast) => CastList(cast: cast.take(50).toList()),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),

                      const SizedBox(height: 18),

                      // ===== Reviews (TMDB) =====
                      reviewsAsync.when(
                        data: (reviews) => _ReviewsSection(
                          title: i18n.t("reviews"),
                          reviews: reviews,
                        ),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),

                      const SizedBox(height: 18),

                      // ===== Similar Movies =====
                      similarAsync.when(
                        data: (movies) {
                          if (movies.isEmpty) return const SizedBox.shrink();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Similar Movies",
                                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                              const SizedBox(height: 8),
                              _MovieHorizontalListWithArrows(movies: movies),
                            ],
                          );
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),

                      const SizedBox(height: 18),

                      // ===== Recommendations =====
                      recoAsync.when(
                        data: (movies) {
                          if (movies.isEmpty) return const SizedBox.shrink();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("You may also like",
                                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                              const SizedBox(height: 8),
                              _MovieHorizontalListWithArrows(movies: movies),
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
      ),
    );
  }
}

/// Save detail as Movie for local storage
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

/// Reviews section
class _ReviewsSection extends StatelessWidget {
  const _ReviewsSection({required this.title, required this.reviews});
  final String title;
  final List<Review> reviews;

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        const SizedBox(height: 8),
        ...reviews.take(3).map((r) => _ReviewTile(review: r)),
      ],
    );
  }
}

class _ReviewTile extends StatefulWidget {
  const _ReviewTile({required this.review});
  final Review review;

  @override
  State<_ReviewTile> createState() => _ReviewTileState();
}

class _ReviewTileState extends State<_ReviewTile> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final r = widget.review;
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
                  child: Text(
                    (r.author.isEmpty ? "U" : r.author[0].toUpperCase()),
                    style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(r.author, style: const TextStyle(fontWeight: FontWeight.w800)),
                ),
                if (r.rating != null)
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 18, color: Colors.amber),
                      Text(r.rating!.toStringAsFixed(1)),
                    ],
                  )
              ],
            ),
            const SizedBox(height: 10),
            Text(
              r.content,
              maxLines: expanded ? 999 : 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(height: 1.35),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => setState(() => expanded = !expanded),
                child: Text(expanded ? "Less" : "Read more"),
              ),
            )
          ],
        ),
      ),
    );
  }
}

/// Watch providers section
class _WatchProvidersSection extends StatelessWidget {
  const _WatchProvidersSection({required this.title, required this.result});

  final String title;
  final WatchProvidersResult? result;

  @override
  Widget build(BuildContext context) {
    if (result == null) return const SizedBox.shrink();
    final theme = Theme.of(context);

    Widget buildRow(String label, List<WatchProviderItem> items) {
      if (items.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          SizedBox(
            height: 54,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, i) {
                final p = items[i];
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: theme.colorScheme.surface,
                    border: Border.all(color: theme.dividerColor.withOpacity(0.25)),
                  ),
                  child: Row(
                    children: [
                      if (p.logoUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(p.logoUrl!, width: 34, height: 34, fit: BoxFit.cover),
                        )
                      else
                        const Icon(Icons.tv_rounded, size: 22),
                      const SizedBox(width: 8),
                      Text(p.providerName, style: const TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemCount: items.length,
            ),
          ),
          const SizedBox(height: 10),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            const Spacer(),
            if (result!.link != null)
              TextButton.icon(
                onPressed: () async {
                  final uri = Uri.tryParse(result!.link!);
                  if (uri != null) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                label: const Text("TMDB"),
              ),
          ],
        ),
        const SizedBox(height: 6),
        buildRow("Stream", result!.flatrate),
        buildRow("Rent", result!.rent),
        buildRow("Buy", result!.buy),
      ],
    );
  }
}

/// Horizontal list with arrows
class _MovieHorizontalListWithArrows extends StatefulWidget {
  const _MovieHorizontalListWithArrows({required this.movies});
  final List<Movie> movies;

  @override
  State<_MovieHorizontalListWithArrows> createState() =>
      _MovieHorizontalListWithArrowsState();
}

class _MovieHorizontalListWithArrowsState
    extends State<_MovieHorizontalListWithArrows> {
  final ScrollController _scrollController = ScrollController();

  void _scrollBy(double offset) {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final target =
        (_scrollController.offset + offset).clamp(0.0, maxScroll.toDouble());
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ListView.separated(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemBuilder: (_, i) => MovieCard(movie: widget.movies[i]),
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemCount: widget.movies.length,
          ),
          Positioned(
            left: 0,
            child: _MovieArrowButton(
              icon: Icons.chevron_left_rounded,
              onTap: () => _scrollBy(-220),
            ),
          ),
          Positioned(
            right: 0,
            child: _MovieArrowButton(
              icon: Icons.chevron_right_rounded,
              onTap: () => _scrollBy(220),
            ),
          ),
        ],
      ),
    );
  }
}

class _MovieArrowButton extends StatelessWidget {
  const _MovieArrowButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.45),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 24, color: Colors.white),
        ),
      ),
    );
  }
}
