import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';
import 'package:catbiblio_app/models/item_type.dart';

final String _baseUrl =
    dotenv.env['KOHA_SVC_URL'] ?? 'https://catbiblio.uv.mx/api/v1';
final String _apiKey = dotenv.env['HTTP_X_API_KEY'] ?? '';

class ItemTypesService {
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

  /// Fetches the list of item types from a Koha-based service
  ///
  /// Returns a List\<ItemType\> containing all available item types.
  ///
  /// Returns an empty list if no item types are found or in case of an error
  static Future<List<ItemType>> getItemTypes() async {
    final dio = _createDio();

    try {
      final response = await dio.get('/item_types');

      final List<dynamic> itemTypesJson = json.decode(response.data);

      return itemTypesJson
          .map((json) => ItemType.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      // Log the error for debugging
      debugPrint('DioException in getItemTypes: ${e.message}');
      debugPrint('Response data: ${e.response?.data}');
      debugPrint('Status code: ${e.response?.statusCode}');

      // Handle specific error types
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
          debugPrint('Timeout error: Check network connection');
          break;
        case DioExceptionType.badResponse:
          if (e.response?.statusCode == 404) {
            debugPrint('No item types found (404)');
          } else {
            debugPrint('Server error: ${e.response?.statusCode}');
          }
          break;
        default:
          debugPrint('Unexpected error: ${e.type}');
          break;
      }

      return [];
    } catch (e) {
      // Catch any other exceptions
      debugPrint('Unexpected exception in getItemTypes: $e');
      return [];
    } finally {
      dio.close();
    }
  }
}
