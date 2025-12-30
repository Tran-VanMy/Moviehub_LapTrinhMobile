// Path: lib/features/movies/data/models/review.dart
class Review {
  final String id;
  final String author;
  final String content;
  final String createdAt;
  final double? rating;

  Review({
    required this.id,
    required this.author,
    required this.content,
    required this.createdAt,
    this.rating,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    final authorDetails = (json["author_details"] as Map?) ?? {};
    final ratingRaw = authorDetails["rating"];
    return Review(
      id: json["id"] ?? "",
      author: json["author"] ?? "",
      content: json["content"] ?? "",
      createdAt: json["created_at"] ?? "",
      rating: ratingRaw == null ? null : (ratingRaw as num).toDouble(),
    );
  }
}
