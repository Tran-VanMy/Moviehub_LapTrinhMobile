// Path: lib/features/movies/presentation/pages/all_movies_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/movie_repository.dart';
import '../providers/movie_providers.dart';
import '../widgets/movie_card.dart';

class AllMoviesPage extends ConsumerStatefulWidget {
  const AllMoviesPage({super.key, required this.title, required this.type});

  /// Tiêu đề hiển thị: ví dụ "Trending Today"
  final String title;

  /// Loại list: "trending", "nowplaying", "toprated"
  final String type;

  @override
  ConsumerState<AllMoviesPage> createState() => _AllMoviesPageState();
}

class _AllMoviesPageState extends ConsumerState<AllMoviesPage> {
  final _scrollController = ScrollController();

  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 1;
  final _movies = <dynamic>[];

  MovieRepository get _repo => ref.read(repoProvider);

  @override
  void initState() {
    super.initState();
    _fetch();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading &&
          _hasMore) {
        _fetch();
      }
    });
  }

  Future<void> _fetch({bool refresh = false}) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      if (refresh) {
        _page = 1;
        _movies.clear();
        _hasMore = true;
      }

      List<dynamic> newMovies;
      if (widget.type == "trending") {
        newMovies = await _repo.trending(_page);
      } else if (widget.type == "nowplaying") {
        newMovies = await _repo.nowPlaying(_page);
      } else {
        newMovies = await _repo.topRated(_page);
      }

      setState(() {
        _movies.addAll(newMovies);
        _page++;
        _hasMore = newMovies.isNotEmpty;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi tải dữ liệu: $e")),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: RefreshIndicator(
        onRefresh: () => _fetch(refresh: true),
        child: ListView.separated(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemBuilder: (_, i) {
            if (i == _movies.length) {
              return _hasMore
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : const SizedBox.shrink();
            }
            return MovieCard(movie: _movies[i], isHorizontal: true);
          },
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemCount: _movies.length + 1,
        ),
      ),
    );
  }
}
