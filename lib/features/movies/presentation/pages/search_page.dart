// Path: lib/features/movies/presentation/pages/search_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moviehub/features/movies/presentation/providers/movie_providers.dart';
import '../widgets/movie_card.dart';

final searchQueryProvider = StateProvider<String>((ref) => "");
final searchResultsProvider = FutureProvider.autoDispose<List>((ref) async {
  final q = ref.watch(searchQueryProvider);
  if (q.trim().isEmpty) return [];
  return ref.read(repoProvider).search(q, 1);
});

class SearchPage extends ConsumerWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider);
    final resultsAsync = ref.watch(searchResultsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Search Movies")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (v) => ref.read(searchQueryProvider.notifier).state = v,
              decoration: InputDecoration(
                hintText: "Type movie name...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: resultsAsync.when(
              data: (movies) => movies.isEmpty && query.isNotEmpty
                  ? const Center(child: Text("No results."))
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemBuilder: (_, i) => MovieCard(movie: movies[i], isHorizontal: true),
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemCount: movies.length,
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text("Error: $e")),
            ),
          ),
        ],
      ),
    );
  }
}
