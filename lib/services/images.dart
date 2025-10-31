import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ImageService {
  static Dio _createDio() {
    return Dio(
      BaseOptions(
        baseUrl: '',
        responseType: ResponseType.bytes,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
  }

  /// Fetches an image from the server using the provided [biblionumber].
  /// Returns an [Image] widget if the image is found and valid, otherwise returns null.
  static Future<Image?> fetchThumbnailImageUrl(String biblionumber) async {
    final dio = _createDio();

    try {
      final response = await dio.get(
        'https://catbiblio.uv.mx/cgi-bin/koha/opac-image.pl?thumbnail=1&biblionumber=$biblionumber',
      );
      if (response.headers.value('content-type') != null &&
          response.headers
              .value('content-type')!
              .toLowerCase()
              .contains('image/png') &&
          response.statusCode == 200) {
        final bytes = response.data;
        return Image.memory(bytes, fit: BoxFit.fitHeight);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    } finally {
      dio.close();
    }
  }
}
