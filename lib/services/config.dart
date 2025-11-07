import 'package:catbiblio_app/models/config.dart';
import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final String _baseUrl = dotenv.env['KOHA_SVC_URL'] ?? '';
final String _apiKey = dotenv.env['HTTP_X_API_KEY'] ?? '';

class ConfigService {
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

  static Future<Config> getAppConfig() async {
    final dio = _createDio();

    try {
      final response = await dio.get('/app_config');

      Config config = Config.fromJson(json.decode(response.data));
      return config;
    } on DioException catch (e) {
      // Log the error for debugging
      debugPrint('DioException in getConfig: ${e.message}');
      debugPrint('Response data: ${e.response?.data}');
      debugPrint('Status code: ${e.response?.statusCode}');

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

      return Config(
        bookSelections: [],
        librariesServices: [],
        selectionsSectionState: false,
      );
    } catch (e) {
      debugPrint('Unexpected error in getConfig: $e');
      return Config(
        bookSelections: [],
        librariesServices: [],
        selectionsSectionState: false,
      );
    } finally {
      dio.close();
    }
  }
}
