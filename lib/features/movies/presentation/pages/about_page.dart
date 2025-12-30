// Path: lib/features/movies/presentation/pages/about_page.dart
import 'package:flutter/material.dart';
import '../../../../core/i18n/app_i18n.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final i18n = AppI18n.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(i18n.t("about"))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.movie_filter_rounded, size: 46, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(i18n.t("app_name"),
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 4),
                        Text(
                          "MovieHub - Flutter + Riverpod + TMDB",
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(i18n.t("how_to_use"),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  const Text("• Home: xem Trending / Now Playing / Top Rated / Popular / Upcoming"),
                  const Text("• Search: tìm phim theo tên"),
                  const Text("• Discover: lọc theo thể loại, năm, điểm, sắp xếp"),
                  const Text("• Movie Detail: trailer, cast, similar, recommendations, reviews, watch providers"),
                  const Text("• Watchlist: lưu phim để xem lại"),
                  const Text("• Favorites: đánh dấu yêu thích"),
                  const Text("• Settings: đổi theme, bảng màu gradient, ngôn ngữ"),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                i18n.t("tmdb_notice"),
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700, height: 1.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
