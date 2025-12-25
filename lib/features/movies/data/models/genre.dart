// Path: lib/features/movies/data/models/genre.dart

/// Model thể loại phim (Genre) của TMDB.
class Genre {
  final int id;
  final String name;

  Genre({
    required this.id,
    required this.name,
  });

  factory Genre.fromJson(Map<String, dynamic> json) => Genre(
        id: json["id"] ?? 0,
        name: json["name"] ?? "",
      );
}
