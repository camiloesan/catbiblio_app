import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final String _baseUrl =
    dotenv.env['KOHA_BASE_URL'] ?? 'https://catbiblio.uv.mx';

final String _openLibraryBaseUrl = 'https://covers.openlibrary.org';

/// Represents a fetched thumbnail together with its source.
class ThumbnailResult {
  final Image image;
  final String source;
  ThumbnailResult(this.image, this.source);
}

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

  // Source marker to indicate where the thumbnail was fetched from.
  static const String sourceLocal = 'local';
  static const String sourceOpenLibrary = 'openlibrary';

  static Future<ThumbnailResult?> fetchThumbnail(
    String biblionumber,
    String isbn,
  ) async {
    final local = await fetchThumbnailLocal(biblionumber);
    if (local != null) {
      return ThumbnailResult(local, sourceLocal);
    }

    if (isbn.isNotEmpty) {
      final openLibrary = await fetchThumbnailOpenLibrary(isbn);
      if (openLibrary != null) {
        return ThumbnailResult(openLibrary, sourceOpenLibrary);
      }
    }

    return null;
  }

  /// Fetches an image from the server using the provided [biblionumber].
  /// Returns an [Image] widget if the image is found and valid, otherwise returns null.
  static Future<Image?> fetchThumbnailLocal(String biblionumber) async {
    final dio = _createDio();

    try {
      final response = await dio.get(
        '$_baseUrl/cgi-bin/koha/opac-image.pl?thumbnail=1&biblionumber=$biblionumber',
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

  static Future<Image?> fetchThumbnailOpenLibrary(String isbn) async {
    final dio = _createDio();

    try {
      final response = await dio.get('$_openLibraryBaseUrl/b/isbn/$isbn-M.jpg');
      if (response.headers.value('content-type') != null &&
          response.headers
              .value('content-type')!
              .toLowerCase()
              .contains('image/jpeg') &&
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
