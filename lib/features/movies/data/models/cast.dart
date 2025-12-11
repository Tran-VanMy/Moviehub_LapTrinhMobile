// Path: lib/features/movies/data/models/cast.dart
class Cast {
  final int id;
  final String name;
  final String character;
  final String profilePath;

  Cast({
    required this.id,
    required this.name,
    required this.character,
    required this.profilePath,
  });

  factory Cast.fromJson(Map<String, dynamic> json) => Cast(
        id: json["id"] ?? 0,
        name: json["name"] ?? "",
        character: json["character"] ?? "",
        profilePath: json["profile_path"] ?? "",
      );
}
