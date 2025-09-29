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
        title:
            '${getSubfieldData(titleFields, '245', 'a') ?? ''} ${getSubfieldData(titleFields, '245', 'b') ?? ''} ${getSubfieldData(titleFields, '245', 'c') ?? ''}'
                .trim(),
        author: getSubfieldData(titleFields, '100', 'a') ?? '',
        isbn: getSubfieldData(titleFields, '020', 'a') ?? '',
        language: getSubfieldData(titleFields, '041', 'a') ?? '',
        originalLanguage: getSubfieldData(titleFields, '041', 'h') ?? '',
        subject: getSubfieldData(titleFields, '650', 'a') ?? '',
        collaborators: getSubfieldData(titleFields, '700', 'a') ?? '',
        summary: getSubfieldData(titleFields, '520', 'a') ?? '',
        cdd:
            '${getSubfieldData(titleFields, '082', 'a') ?? ''} ${getSubfieldData(titleFields, '082', 'b') ?? ''} ${getSubfieldData(titleFields, '082', '2') ?? ''}'
                .trim(),
        loc:
            '${getSubfieldData(titleFields, '050', 'a') ?? ''} ${getSubfieldData(titleFields, '050', 'b') ?? ''}'
                .trim(),
        editor:
            '${getSubfieldData(titleFields, '260', 'a') ?? ''} ${getSubfieldData(titleFields, '260', 'b') ?? ''} ${getSubfieldData(titleFields, '260', 'c') ?? ''} ${getSubfieldData(titleFields, '264', 'a') ?? ''} ${getSubfieldData(titleFields, '264', 'b') ?? ''} ${getSubfieldData(titleFields, '264', 'c') ?? ''}'
                .trim(),
        edition: getSubfieldData(titleFields, '250', 'a') ?? '',
        description:
            '${getSubfieldData(titleFields, '300', 'a') ?? ''} ${getSubfieldData(titleFields, '300', 'b') ?? ''} ${getSubfieldData(titleFields, '300', 'c') ?? ''}'
                .trim(),
        otherClassification: getSubfieldData(titleFields, '084', 'a') ?? '',
        lawClassification: '${getSubfieldData(titleFields, '099', 'a') ?? ''} ${getSubfieldData(titleFields, '099', 'b') ?? ''} ${getSubfieldData(titleFields, '099', 'c') ?? ''}'
            .trim(),
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

  /// Helper function to find all values for a given tag and subfield,
  /// concatenating them with a pipe '|' if multiple are found.
  static String? getSubfieldData(
    List<dynamic> fields,
    String tag,
    String subfieldCode,
  ) {
    // 1. Find ALL maps that contain the main tag (e.g., {"020": {...}}).
    // We use 'where' instead of 'firstWhere' to get all occurrences.
    final fieldContainers = fields.where(
      (element) => (element as Map).containsKey(tag),
    );

    // If no fields with that tag exist, stop here.
    if (fieldContainers.isEmpty) {
      return null;
    }

    // A list to hold the data from each found subfield.
    final List<String> results = [];

    // 2. Loop through each of the found field containers.
    for (final fieldContainer in fieldContainers) {
      // 3. Get the value associated with the tag (e.g., the map with "ind1", "subfields").
      final tagData = fieldContainer[tag];

      // 4. Check if the tag's data is a Map and contains the "subfields" key.
      if (tagData is Map && tagData.containsKey('subfields')) {
        // 5. Get the list of subfields.
        final List<dynamic> subfieldsList = tagData['subfields'];

        // 6. Search the list to find the first map containing our subfieldCode.
        // (It's rare for the same subfield code to repeat within a single field).
        final subfieldMap = subfieldsList.firstWhere(
          (subfield) => (subfield as Map).containsKey(subfieldCode),
          orElse: () => null,
        );

        // 7. If we found a matching subfield, add its value to our results list.
        if (subfieldMap != null) {
          final value = subfieldMap[subfieldCode];
          if (value is String) {
            results.add(value);
          }
        }
      }
    }

    // 8. After checking all fields, process the collected results.
    if (results.isEmpty) {
      // If we looped through everything but found no matching subfields.
      return null;
    } else {
      // Join all found values with a " | " and return the final string.
      return results.join(' | ');
    }
  }
}
