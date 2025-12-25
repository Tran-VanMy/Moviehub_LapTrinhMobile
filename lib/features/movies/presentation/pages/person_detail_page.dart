// Path: lib/features/movies/presentation/pages/person_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants.dart';
import '../providers/movie_providers.dart';
import '../widgets/movie_card.dart';

/// Màn chi tiết 1 người nổi tiếng + filmography (các phim đã tham gia)
class PersonDetailPage extends ConsumerWidget {
  const PersonDetailPage({super.key, required this.personId});

  final int personId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(personDetailProvider(personId));
    final creditsAsync = ref.watch(personCreditsProvider(personId));

    return Scaffold(
      body: detailAsync.when(
        data: (detail) {
          final avatar = detail.profilePath.isEmpty
              ? null
              : "${AppConstants.imageBaseUrl}${detail.profilePath}";

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                expandedHeight: 260,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    detail.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(color: Colors.black87),
                      if (avatar != null)
                        Image.network(
                          avatar,
                          fit: BoxFit.cover,
                        ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.7),
                              Colors.black.withOpacity(0.3),
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ===== Thông tin tổng quan trong Card đẹp =====
                      Card(
                        elevation: 1.5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.black12,
                                backgroundImage:
                                    avatar == null ? null : NetworkImage(avatar),
                                child: avatar == null
                                    ? const Icon(Icons.person_rounded, size: 40)
                                    : null,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      detail.name,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.work_rounded, size: 18),
                                        const SizedBox(width: 6),
                                        Flexible(
                                          child: Text(
                                            detail.knownForDepartment,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    if (detail.birthday.isNotEmpty)
                                      Row(
                                        children: [
                                          const Icon(Icons.cake_rounded,
                                              size: 18),
                                        const SizedBox(width: 6),
                                          Text(detail.birthday),
                                        ],
                                      ),
                                    if (detail.placeOfBirth.isNotEmpty)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 4.0),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Icon(Icons.place_rounded,
                                                size: 18),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                detail.placeOfBirth,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // ===== Biography =====
                      Row(
                        children: const [
                          Icon(Icons.menu_book_rounded, size: 20),
                          SizedBox(width: 6),
                          Text(
                            "Biography",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        detail.biography.isEmpty
                            ? "No biography available."
                            : detail.biography,
                        style: const TextStyle(fontSize: 14, height: 1.4),
                      ),

                      const SizedBox(height: 20),

                      // ===== Filmography =====
                      Row(
                        children: const [
                          Icon(Icons.local_movies_rounded, size: 20),
                          SizedBox(width: 6),
                          Text(
                            "Filmography",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      creditsAsync.when(
                        data: (movies) {
                          if (movies.isEmpty) {
                            return const Text(
                              "No movie credits.",
                              style: TextStyle(fontSize: 13),
                            );
                          }

                          return _FilmographyListWithArrows(movies: movies);
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Text("Error: $e"),
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

/// List Filmography ngang có mũi tên < >
class _FilmographyListWithArrows extends StatefulWidget {
  const _FilmographyListWithArrows({required this.movies});

  final List movies;

  @override
  State<_FilmographyListWithArrows> createState() =>
      _FilmographyListWithArrowsState();
}

class _FilmographyListWithArrowsState
    extends State<_FilmographyListWithArrows> {
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
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemCount: widget.movies.length,
          ),

          // Nút trái
          Positioned(
            left: 0,
            child: _ArrowButton(
              icon: Icons.chevron_left_rounded,
              onTap: () => _scrollBy(-220),
            ),
          ),

          // Nút phải
          Positioned(
            right: 0,
            child: _ArrowButton(
              icon: Icons.chevron_right_rounded,
              onTap: () => _scrollBy(220),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({
    required this.icon,
    required this.onTap,
  });

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
