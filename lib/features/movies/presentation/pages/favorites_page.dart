// Path: lib/features/movies/presentation/pages/favorites_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/i18n/app_i18n.dart';
import '../../../../core/router.dart';
import '../providers/favorite_providers.dart';
import '../widgets/movie_card.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i18n = AppI18n.of(context);
    final list = ref.watch(favoriteProvider);

    return Scaffold(
      appBar: AppBar(title: Text(i18n.t("favorites"))),
      body: list.isEmpty
          ? Center(child: Text(i18n.t("no_favorites")))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (_, i) => GestureDetector(
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRouter.detail,
                  arguments: list[i].id,
                ),
                child: MovieCard(movie: list[i], isHorizontal: true),
              ),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemCount: list.length,
            ),
    );
  }
}
