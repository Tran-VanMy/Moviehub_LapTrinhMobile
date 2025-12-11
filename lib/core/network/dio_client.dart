// Path: lib/core/network/dio_client.dart
import 'package:dio/dio.dart';
import '../constants.dart';

class DioClient {
  DioClient._();

  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.tmdbBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        // TMDB accepts Bearer token authentication
        "Authorization": "Bearer ${AppConstants.tmdbBearerToken}",
        "accept": "application/json",
      },
    ),
  );
}
