import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:catbiblio_app/models/library.dart';
import 'package:flutter/material.dart';

class LibrariesService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://148.226.6.25',
      responseType: ResponseType.plain,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Accept': 'application/json;encoding=UTF-8'},
    ),
  );

  /// Fetches the list of libraries from a Koha-based service
  /// Example: http://{{baseUrl}}/cgi-bin/koha/svc/libraries
  static Future<List<Library>> getLibraries() async {
    try {
      final response = await _dio.get('/cgi-bin/koha/svc/libraries');

      final List<dynamic> librariesJson = json.decode(response.data);

      return librariesJson
          .map((json) => Library.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      // Log the error for debugging
      debugPrint('DioException in getLibraries: ${e.message}');
      debugPrint('Response data: ${e.response?.data}');
      debugPrint('Status code: ${e.response?.statusCode}');

      // Handle specific error types
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
          debugPrint('Timeout error: Check network connection');
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
    }
  }
}
