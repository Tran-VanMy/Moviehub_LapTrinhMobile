// Path: lib/features/movies/data/models/watch_provider.dart
import '../../../../core/constants.dart';

class WatchProviderItem {
  final int providerId;
  final String providerName;
  final String logoPath;
  final int displayPriority;

  WatchProviderItem({
    required this.providerId,
    required this.providerName,
    required this.logoPath,
    required this.displayPriority,
  });

  factory WatchProviderItem.fromJson(Map<String, dynamic> json) {
    return WatchProviderItem(
      providerId: json["provider_id"] ?? 0,
      providerName: json["provider_name"] ?? "",
      logoPath: json["logo_path"] ?? "",
      displayPriority: json["display_priority"] ?? 0,
    );
  }

  String? get logoUrl {
    if (logoPath.isEmpty) return null;
    return "${AppConstants.imageBaseUrl}$logoPath";
  }
}

class WatchProvidersResult {
  final String? link;
  final List<WatchProviderItem> flatrate;
  final List<WatchProviderItem> rent;
  final List<WatchProviderItem> buy;

  WatchProvidersResult({
    required this.link,
    required this.flatrate,
    required this.rent,
    required this.buy,
  });

  static List<WatchProviderItem> _parseList(dynamic raw) {
    final list = (raw as List?) ?? [];
    return list.map((e) => WatchProviderItem.fromJson(e)).toList()
      ..sort((a, b) => a.displayPriority.compareTo(b.displayPriority));
  }

  factory WatchProvidersResult.fromRegionJson(Map<String, dynamic> json) {
    return WatchProvidersResult(
      link: json["link"],
      flatrate: _parseList(json["flatrate"]),
      rent: _parseList(json["rent"]),
      buy: _parseList(json["buy"]),
    );
  }
}
