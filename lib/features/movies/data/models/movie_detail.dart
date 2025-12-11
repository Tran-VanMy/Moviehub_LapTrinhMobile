// Path: lib/features/movies/data/models/movie_detail.dart
class MovieDetail {
  final int id;
  final String title;
  final String overview;
  final String backdropPath;
  final int runtime;
  final List<String> genres;
  final double voteAverage;

  MovieDetail({
    required this.id,
    required this.title,
    required this.overview,
    required this.backdropPath,
    required this.runtime,
    required this.genres,
    required this.voteAverage,
  });

  factory MovieDetail.fromJson(Map<String, dynamic> json) {
    final genresJson = (json["genres"] as List? ?? []);
    return MovieDetail(
      id: json["id"] ?? 0,
      title: json["title"] ?? "",
      overview: json["overview"] ?? "",
      backdropPath: json["backdrop_path"] ?? "",
      runtime: json["runtime"] ?? 0,
      genres: genresJson.map((g) => g["name"].toString()).toList(),
      voteAverage: (json["vote_average"] ?? 0).toDouble(),
    );
  }
}
