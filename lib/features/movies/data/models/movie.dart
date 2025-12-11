// Path: lib/features/movies/data/models/movie.dart
class Movie {
  final int id;
  final String title;
  final String posterPath;
  final double voteAverage;
  final String releaseDate;

  Movie({
    required this.id,
    required this.title,
    required this.posterPath,
    required this.voteAverage,
    required this.releaseDate,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json["id"] ?? 0,
      title: json["title"] ?? "",
      posterPath: json["poster_path"] ?? "",
      voteAverage: (json["vote_average"] ?? 0).toDouble(),
      releaseDate: json["release_date"] ?? "",
    );
  }

  // Convert to Map for Hive storage
  Map<String, dynamic> toMap() => {
        "id": id,
        "title": title,
        "posterPath": posterPath,
        "voteAverage": voteAverage,
        "releaseDate": releaseDate,
      };

  factory Movie.fromMap(Map map) => Movie(
        id: map["id"],
        title: map["title"],
        posterPath: map["posterPath"],
        voteAverage: (map["voteAverage"]).toDouble(),
        releaseDate: map["releaseDate"],
      );
}
