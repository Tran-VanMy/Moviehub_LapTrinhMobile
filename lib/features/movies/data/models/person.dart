// Path: lib/features/movies/data/models/person.dart
import '../../../../core/constants.dart';

/// Model người nổi tiếng (Popular Person) từ TMDB /person/popular.
class Person {
  final int id;
  final String name;
  final String profilePath;
  final String knownForDepartment;
  final double popularity;

  Person({
    required this.id,
    required this.name,
    required this.profilePath,
    required this.knownForDepartment,
    required this.popularity,
  });

  factory Person.fromJson(Map<String, dynamic> json) => Person(
        id: json["id"] ?? 0,
        name: json["name"] ?? "",
        profilePath: json["profile_path"] ?? "",
        knownForDepartment: json["known_for_department"] ?? "",
        popularity: (json["popularity"] ?? 0).toDouble(),
      );

  /// Helper để lấy full avatar URL (dùng ở UI nếu cần)
  String? get avatarUrl {
    if (profilePath.isEmpty) return null;
    return "${AppConstants.imageBaseUrl}$profilePath";
  }
}
