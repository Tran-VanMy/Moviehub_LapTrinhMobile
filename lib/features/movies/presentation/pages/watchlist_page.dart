// Path: lib/features/movies/presentation/pages/watchlist_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/router.dart';
import '../providers/watchlist_providers.dart';
import '../widgets/movie_card.dart';

class WatchlistPage extends ConsumerWidget {
  const WatchlistPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(watchlistProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Your Watchlist")),
      body: list.isEmpty
          ? const Center(child: Text("No movies saved yet."))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (_, i) => GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRouter.detail, arguments: list[i].id),
                child: MovieCard(movie: list[i], isHorizontal: true),
              ),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemCount: list.length,
            ),
    );
  }
}
