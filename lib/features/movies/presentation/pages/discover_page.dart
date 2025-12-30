// Path: lib/features/movies/presentation/pages/discover_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/genre.dart';
import '../providers/movie_providers.dart';
import '../widgets/movie_card.dart';

/// Màn hình Discover với filter nâng cao + UI đẹp (chips, slider, dropdown)
class DiscoverPage extends ConsumerWidget {
  const DiscoverPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(discoverFilterProvider);
    final genresAsync = ref.watch(genresProvider);
    final discoverAsync = ref.watch(discoverResultsProvider);

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Discover Movies"),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.explore_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          // ====== KHỐI FILTER (CARD) ======
          Padding(
            padding: const EdgeInsets.all(12),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              elevation: 1,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Genres ---
                    Row(
                      children: [
                        Icon(Icons.category_rounded,
                            color: theme.colorScheme.primary),
                        const SizedBox(width: 6),
                        const Text(
                          "Genres",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          tooltip: "Reset filter",
                          onPressed: () => ref
                              .read(discoverFilterProvider.notifier)
                              .reset(),
                          icon: const Icon(Icons.refresh_rounded, size: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // List genres dưới dạng chips + nút < >
                    genresAsync.when(
                      data: (genres) => _GenreChips(
                        genres: genres,
                        selectedIds: filter.selectedGenreIds,
                      ),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Text(
                        "Error load genres: $e",
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // --- Year + Rating (row) ---
                    Row(
                      children: [
                        Expanded(
                          child: _YearField(
                            year: filter.year,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _VoteSlider(
                            minVote: filter.minVote,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // --- Sort dropdown ---
                    _SortDropdown(current: filter.sortBy),
                  ],
                ),
              ),
            ),
          ),

          // ====== KẾT QUẢ DISCOVER ======
          Expanded(
            child: discoverAsync.when(
              data: (movies) {
                if (movies.isEmpty) {
                  return const Center(
                    child: Text("Không tìm thấy phim phù hợp."),
                  );
                }
                return ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemBuilder: (_, i) =>
                      MovieCard(movie: movies[i], isHorizontal: true),
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemCount: movies.length,
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text("Error: $e")),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget hiển thị danh sách thể loại dạng chip đẹp + nút < >
class _GenreChips extends ConsumerStatefulWidget {
  const _GenreChips({
    required this.genres,
    required this.selectedIds,
  });

  final List<Genre> genres;
  final List<int> selectedIds;

  @override
  ConsumerState<_GenreChips> createState() => _GenreChipsState();
}

class _GenreChipsState extends ConsumerState<_GenreChips> {
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
    final notifier = ref.read(discoverFilterProvider.notifier);

    return SizedBox(
      height: 40,
      child: Row(
        children: [
          IconButton(
            tooltip: "Lùi lại",
            icon: const Icon(Icons.chevron_left_rounded),
            onPressed: () => _scrollBy(-220),
            splashRadius: 18,
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              child: Row(
                children: widget.genres.map((g) {
                  final isSelected = widget.selectedIds.contains(g.id);
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(g.name),
                      avatar: Icon(
                        isSelected
                            ? Icons.check_rounded
                            : Icons.local_movies_rounded,
                        size: 16,
                      ),
                      onSelected: (_) => notifier.toggleGenre(g.id),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          IconButton(
            tooltip: "Tiến tới",
            icon: const Icon(Icons.chevron_right_rounded),
            onPressed: () => _scrollBy(220),
            splashRadius: 18,
          ),
        ],
      ),
    );
  }
}

/// Widget nhập năm phát hành
class _YearField extends ConsumerWidget {
  const _YearField({this.year});

  final int? year;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(
      text: year?.toString() ?? "",
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Year",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            isDense: true,
            prefixIcon: const Icon(Icons.calendar_month_rounded, size: 18),
            hintText: "Any",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onSubmitted: (value) {
            final parsed = int.tryParse(value);
            ref.read(discoverFilterProvider.notifier).setYear(parsed);
          },
        ),
      ],
    );
  }
}

/// Widget slider chọn min vote
class _VoteSlider extends ConsumerWidget {
  const _VoteSlider({this.minVote});

  final double? minVote;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = minVote ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Min Rating",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
            const SizedBox(width: 4),
            Text(value.toStringAsFixed(1)),
          ],
        ),
        Slider(
          value: value,
          min: 0,
          max: 10,
          divisions: 20,
          label: value.toStringAsFixed(1),
          onChanged: (v) {
            ref.read(discoverFilterProvider.notifier).setMinVote(v);
          },
        ),
      ],
    );
  }
}

/// Dropdown chọn tiêu chí sắp xếp
class _SortDropdown extends ConsumerWidget {
  const _SortDropdown({required this.current});

  final String current;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = <Map<String, String>>[
      {"value": "popularity.desc", "label": "Popularity ↓"},
      {"value": "popularity.asc", "label": "Popularity ↑"},
      {"value": "vote_average.desc", "label": "Rating ↓"},
      {"value": "vote_average.asc", "label": "Rating ↑"},
      {"value": "primary_release_date.desc", "label": "Release date ↓"},
      {"value": "primary_release_date.asc", "label": "Release date ↑"},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Sort by",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          initialValue: current,
          decoration: InputDecoration(
            isDense: true,
            prefixIcon: const Icon(Icons.sort_rounded, size: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e["value"],
                  child: Text(e["label"]!),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value == null) return;
            ref.read(discoverFilterProvider.notifier).setSortBy(value);
          },
        ),
      ],
    );
  }
}
