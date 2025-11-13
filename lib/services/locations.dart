import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:catbiblio_app/models/book_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final String _baseUrl = dotenv.env['KOHA_SVC_URL'] ?? '';
final String _apiKey = dotenv.env['HTTP_X_API_KEY'] ?? '';

class LocationsService {
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

  static Future<BookLocation> getBookLocation(String lcc, String collection, String libraryCode) async {
    final dio = _createDio();

    try {
      final response = await dio.get(
        '/locations',
        queryParameters: {
          'lcc': lcc,
          'coleccion': collection,
          'library_code': libraryCode,
        },
      );

      BookLocation bookLocation = BookLocation.fromJson(json.decode(response.data));
      return bookLocation;
    } on DioException catch (e) {
      // Log the error for debugging
      debugPrint('DioException in getBookLocation: ${e.message}');
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

      return BookLocation(level: '', room: '');
    } catch (e) {
      debugPrint('Unexpected error in getBookLocation: $e');
      return BookLocation(level: '', room: '');
    } finally {
      dio.close();
    }
  }
}