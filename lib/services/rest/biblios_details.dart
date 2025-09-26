import 'package:catbiblio_app/models/biblios_details.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class BibliosDetailsService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://148.226.6.25',
      responseType: ResponseType.plain,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Accept': 'application/marc-in-json'},
    ),
  );

  static Future<BibliosDetails> getBibliosDetails(String biblioNumber) async {
    try {
      final response = await _dio.get('/api/v1/public/biblios/$biblioNumber');

      final Map<String, dynamic> bibliosJson = json.decode(response.data);
      final List<dynamic> titleFields = bibliosJson['fields'];

      return BibliosDetails(
        title: getSubfieldData(titleFields, '245', 'a') ?? 'Unknown Title',
        author: getSubfieldData(titleFields, '100', 'a') ?? 'Unknown Author',
      );
    } on DioException catch (e) {
      // Log the error for debugging
      debugPrint('DioException in getBibliosDetails: ${e.message}');
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

      return BibliosDetails(title: 'Error', author: 'Error');
    } catch (e) {
      // Handle JSON parsing or other errors
      debugPrint('Unexpected error in getBibliosDetails: $e');
      return BibliosDetails(title: '', author: '');
    }
  }

  // Helper function to find a value by its tag in the 'fields' list
  static String? getSubfieldData(
    List<dynamic> fields,
    String tag,
    String subfieldCode,
  ) {
    // 1. Find the map that contains the main tag (e.g., {"245": {...}})
  final fieldContainer = fields.firstWhere(
    (element) => (element as Map).containsKey(tag),
    orElse: () => null,
  );

  // If no field with that tag exists, stop here.
  if (fieldContainer == null) {
    return null;
  }

  // 2. Get the value associated with the tag. This should be a map.
  final tagData = fieldContainer[tag];

  // 3. Check if the tag's data is a Map and contains the "subfields" key.
  if (tagData is Map && tagData.containsKey('subfields')) {
    // 4. Get the list of subfields.
    final List<dynamic> subfieldsList = tagData['subfields'];

    // 5. Search the list to find the first map containing our subfieldCode.
    final subfieldMap = subfieldsList.firstWhere(
      (subfield) => (subfield as Map).containsKey(subfieldCode),
      orElse: () => null,
    );

    // 6. If we found a matching subfield, return its value.
    if (subfieldMap != null) {
      return subfieldMap[subfieldCode] as String?;
    }
  }

  // Return null if anything was not found along the way.
  return null;
  }
}
