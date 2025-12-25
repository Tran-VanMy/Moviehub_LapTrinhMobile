// Path: lib/features/movies/data/models/person_detail.dart

/// Chi tiết 1 người nổi tiếng (Person Detail)
/// API: GET /person/{person_id}
class PersonDetail {
  final int id;
  final String name;
  final String biography;
  final String profilePath;
  final String placeOfBirth;
  final String birthday;
  final String knownForDepartment;

  PersonDetail({
    required this.id,
    required this.name,
    required this.biography,
    required this.profilePath,
    required this.placeOfBirth,
    required this.birthday,
    required this.knownForDepartment,
  });

  factory PersonDetail.fromJson(Map<String, dynamic> json) => PersonDetail(
        id: json["id"] ?? 0,
        name: json["name"] ?? "",
        biography: json["biography"] ?? "",
        profilePath: json["profile_path"] ?? "",
        placeOfBirth: json["place_of_birth"] ?? "",
        birthday: json["birthday"] ?? "",
        knownForDepartment: json["known_for_department"] ?? "",
      );
}
