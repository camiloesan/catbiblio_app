import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:catbiblio_app/models/biblio_item.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final String _baseUrl = dotenv.env['KOHA_SVC_URL'] ?? '';
final String _apiKey = dotenv.env['HTTP_X_API_KEY'] ?? '';

class BibliosItemsService {
  static Dio _createDio() {
    Dio dio = Dio();

    dio.options = BaseOptions(
      baseUrl: _baseUrl,
      responseType: ResponseType.plain,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Accept': 'application/json;encoding=UTF-8',
        'x-api-key': _apiKey,
      },
    );

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

    return dio;
  }

  /// Fetches the list of items for a given title by its biblionumber from a Koha-based service
  ///
  /// Returns a `List<BiblioItem>` containing the items for the specified [biblioNumber].
  ///
  /// Returns an empty list if no items are found or in case of an error
  static Future<List<BiblioItem>> getBiblioItems(int biblioNumber) async {
    final dio = _createDio();

    if (biblioNumber <= 0) {
      debugPrint('Invalid biblionumber: $biblioNumber');
      return [];
    }

    try {
      final response = await dio.get(
        '/biblios_items',
        queryParameters: {'biblionumber': biblioNumber},
      );

      final List<dynamic> itemsJson = json.decode(response.data);

      return itemsJson
          .map((json) => BiblioItem.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      // Log the error for debugging
      //debugPrint('DioException in getBiblioItems: ${e.message}');
      //debugPrint('Response data: ${e.response?.data}');
      debugPrint('Status code: ${e.response?.statusCode}');

      if (e.response?.statusCode == 404) {
        // debugPrint(
        //   'BibliosDetails not found (404) for biblionumber $biblioNumber',
        // );
        return [];
      }

      // Handle specific error types
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          debugPrint('Connection timeout: Check your internet connection');
          break;
        case DioExceptionType.receiveTimeout:
          debugPrint('Receive timeout: Check network connection');
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
      debugPrint('Unexpected error in getBiblioItems: $e');
      return [];
    } finally {
      dio.close();
    }
  }
}
