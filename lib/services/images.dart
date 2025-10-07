import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ImageService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: '',
      responseType: ResponseType.bytes,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  static Future<Image?> fetchImageUrl(String biblionumber) async {
    try {
      final response = await _dio.get('https://catbiblio.uv.mx/cgi-bin/koha/opac-image.pl?thumbnail=1&biblionumber=$biblionumber');
      if (response.headers.value( 'content-type') != null &&
          response.headers.value('content-type')!.toLowerCase().contains('image/png') &&
          response.statusCode == 200) {
        final bytes = response.data;
        return Image.memory(
          bytes,
          width: 100,
          fit: BoxFit.fitHeight,
        );
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}