import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'dart:convert';
import 'package:catbiblio_app/models/library.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final String _baseUrl = dotenv.env['KOHA_SVC_URL'] ?? '';
final String _apiKey = dotenv.env['HTTP_X_API_KEY'] ?? '';

class LibrariesService {
  static Dio _createDio() {
    return Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        responseType: ResponseType.plain,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json;encoding=UTF-8',
          'x-api-key': _apiKey,
        },
      ),
    );
  }

  /// Fetches the list of libraries from a Koha-based service
  ///
  /// Returns a `List<Library>` containing all available libraries.
  ///
  /// Returns an empty list if no libraries are found or in case of an error
  static Future<List<Library>> getLibraries() async {
    final dio = _createDio();

    dio.interceptors.add(
      RetryInterceptor(
        dio: dio,
        logPrint: (obj) => debugPrint('$obj (from RetryInterceptor)'),
        retries: 3,
        retryDelays: const [
          Duration(seconds: 1),
          Duration(seconds: 2),
          Duration(seconds: 3),
        ],
        retryEvaluator: (error, _) {
          return error.type == DioExceptionType.receiveTimeout;
        },
      ),
    );

    try {
      final response = await dio.get('/libraries');

      final List<dynamic> librariesJson = json.decode(response.data);

      return librariesJson
          .map((json) => Library.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      // Log the error for debugging
      debugPrint('DioException in getLibraries: ${e.message}');
      //debugPrint('Response data: ${e.response?.data}');
      debugPrint('Status code: ${e.response?.statusCode}');

      // Handle specific error types
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          debugPrint('Connection timeout: Check your internet connection');
          break;
        case DioExceptionType.receiveTimeout:
          debugPrint('Receive timeout error: Check network connection');
          break;
        case DioExceptionType.badResponse:
          debugPrint('Server error: ${e.response?.statusCode}');
          break;
        case DioExceptionType.cancel:
          debugPrint('Request cancelled');
          break;
        case DioExceptionType.unknown:
          debugPrint('Unknown error: ${e.message}');
          break;
        default:
          debugPrint('Dio error: $e');
      }

      return [];
    } catch (e) {
      // Handle JSON parsing or other errors
      debugPrint('Unexpected error in getLibraries: $e');
      return [];
    } finally {
      dio.close();
    }
  }
}
