// Path: lib/features/movies/presentation/widgets/movie_card.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants.dart';
import '../../../../core/router.dart';
import '../../data/models/movie.dart';

class MovieCard extends StatelessWidget {
  const MovieCard({super.key, required this.movie, this.isHorizontal = false});

  final Movie movie;
  final bool isHorizontal;

  @override
  Widget build(BuildContext context) {
    final posterUrl = movie.posterPath.isEmpty
        ? null
        : "${AppConstants.imageBaseUrl}${movie.posterPath}";

    return InkWell(
      onTap: () => Navigator.pushNamed(context, AppRouter.detail, arguments: movie.id),
      child: isHorizontal ? _horizontal(posterUrl) : _vertical(posterUrl),
    );
  }

  Widget _vertical(String? posterUrl) {
    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _poster(posterUrl, height: 200),
          const SizedBox(height: 6),
          Text(
            movie.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
              const SizedBox(width: 2),
              Text(movie.voteAverage.toStringAsFixed(1)),
            ],
          )
        ],
      ),
    );
  }

  Widget _horizontal(String? posterUrl) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            _poster(posterUrl, height: 110, width: 80),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(movie.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Text("Release: ${movie.releaseDate.isEmpty ? "N/A" : movie.releaseDate}"),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(movie.voteAverage.toStringAsFixed(1)),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _poster(String? url, {double height = 200, double width = double.infinity}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: url == null
          ? Container(height: height, width: width, color: Colors.black12)
          : CachedNetworkImage(
              imageUrl: url,
              height: height,
              width: width,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: Colors.black12),
              errorWidget: (_, __, ___) => Container(color: Colors.black12),
            ),
    );
  }
}
