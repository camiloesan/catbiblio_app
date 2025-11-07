import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final String _baseUrl = dotenv.env['KOHA_SVC_URL'] ?? '';
final String _apiKey = dotenv.env['HTTP_X_API_KEY'] ?? '';

class LibraryService {
  final String name;
  final String imageUrl;

  LibraryService({
    required this.name,
    required this.imageUrl,
  });
}

class LibraryServicesObj {
  final String libraryCode;
  final String libraryName;
  final List<LibraryService> services;

  LibraryServicesObj({
    required this.libraryCode,
    required this.libraryName,
    required this.services,
  });
  

  factory LibraryServicesObj.fromJson(Map<String, dynamic> json) {
    return LibraryServicesObj(
      libraryCode: json['library_code'] as String,
      libraryName: json['library_name'] as String,
      services: (json['services'] as List<dynamic>)
          .map((item) => LibraryService(
                name: item['name'] as String,
                imageUrl: item['image_url'] as String,
              ))
          .toList(),
    );
  }
}

class LibraryServices {
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

  static Future<Map<String, List<LibraryService>>> getLibraryCodeServicesMap() async {
    final dio = _createDio();

    try {
      final response = await dio.get('/library_services');
      List<dynamic> decodedJson = json.decode(response.data);

      return decodedJson.map((item) => LibraryServicesObj.fromJson(item)).toList()
          .asMap()
          .map((_, selection) => MapEntry(selection.libraryCode, selection.services));
    } on DioException catch (e) {
      // Log the error for debugging
      debugPrint('DioException in getLibraryCodeServicesMap: ${e.message}');
      debugPrint('Response data: ${e.response?.data}');
      debugPrint('Status code: ${e.response?.statusCode}');
      return {};
    } catch (e) {
      debugPrint('Unexpected error in getLibraryCodeServicesMap: $e');
      return {};
    } finally {
      dio.close();
    }
  }
}