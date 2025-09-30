import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:catbiblio_app/models/biblio_item.dart';
import 'package:flutter/material.dart';

class BibliosItemsService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://148.226.6.25/cgi-bin/koha/svc', // Move to .env
      responseType: ResponseType.plain,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Accept': 'application/json;encoding=UTF-8',
        'x-api-key': '12345', // Move to .env
      },
    ),
  );

  /// Fetches de list of items for a given title by its biblionumber from a Koha-based service
  ///
  /// Returns a [BiblioItem] list containing the items for the specified [biblioNumber].
  ///
  /// Returns an empty list if no items are found or in case of an error
  static Future<List<BiblioItem>> getBiblioItems(int biblioNumber) async {
    if (biblioNumber <= 0) {
      debugPrint('Invalid biblionumber: $biblioNumber');
      return [];
    }

    try {
      final response = await _dio.get(
        '/biblios_items',
        queryParameters: {'biblio_number': biblioNumber},
      );

      debugPrint('Request URL: ${response.realUri}');

      final List<dynamic> itemsJson = json.decode(response.data);

      return itemsJson
          .map((json) => BiblioItem.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      // Log the error for debugging
      debugPrint('DioException in getBiblioItems: ${e.message}');
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
      debugPrint('Unexpected error in getBiblioItems: $e');
      return [];
    }
  }
}
