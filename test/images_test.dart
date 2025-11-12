import 'package:flutter/material.dart';

import 'package:catbiblio_app/services/images.dart';
import 'package:test/test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  setUpAll(() async {
    await dotenv.load();
  });

  group('ImageService requests', () {
    test('fetchThumbnailLocal returns a valid image', () async {
      // Biblio with known existing local thumbnail
      final image = await ImageService.fetchThumbnailLocal('363560');

      expect(image, isA<Image>());
    });

    test('fetchThumbnailLocal returns a null image', () async {
      // Biblio with known not existing local thumbnail
      final image = await ImageService.fetchThumbnailLocal('11948');

      expect(image, isNull);
    });

    test('fetchThumbnailOpenLibrary returns a valid image', () async {
      // Biblio without local thumbnail but with ISBN with known existing Open Library thumbnail
      final image = await ImageService.fetchThumbnailOpenLibrary('9688802050');

      expect(image, isA<Image>());
    });

    test('fetchThumbnailOpenLibrary returns a null image', () async {
      // Biblio with local thumbnail and with ISBN with known not existing Open Library thumbnail
      final image = await ImageService.fetchThumbnailOpenLibrary(
        '7509982405184',
      );

      expect(image, isNull);
    });

    test('fetchThumbnail returns local image when available', () async {
      // Biblio with known existing local thumbnail
      final result = await ImageService.fetchThumbnail(
        '363560',
        '9786077133162',
      );

      expect(result, isNotNull);
      expect(result!.source, ImageService.sourceLocal);
      expect(result.image, isA<Image>());
    });

    test(
      'fetchThumbnail returns Open Library image when local not available',
      () async {
        // Biblio without local thumbnail but with ISBN with known existing Open Library thumbnail
        final result = await ImageService.fetchThumbnail('10648', '9688802050');

        expect(result, isNotNull);
        expect(result!.source, ImageService.sourceOpenLibrary);
        expect(result.image, isA<Image>());
      },
    );

    test('fetchThumbnail returns null when no images are available', () async {
      // Biblio without local thumbnail and with ISBN with known not existing Open Library thumbnail
      final result = await ImageService.fetchThumbnail('10565', '9684222955');

      expect(result, isNull);
    });
  });
}
