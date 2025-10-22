import 'package:catbiblio_app/models/book_preview.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BookPreview model fromJson factory', () {
    test('fromJson creates a valid BookPreview instance', () {
      final json = {
        'full_title': 'Test Book',
        'biblionumber': '12345',
        'author': 'John Doe',
        'place': 'New York',
        'publishercode': 'Test Publisher',
        'copyrightdate': 2020,
        'libraries_count': 2,
        'total_results': 6,
      };

      final bookPreview = BookPreview.fromJson(json);
      final expectedPublishingDetails = 'New York Test Publisher 2020';

      expect(bookPreview, isA<BookPreview>());
      expect(bookPreview.publishingDetails, expectedPublishingDetails);
    });

    test(
      'fromJson creates a valid BookPreview instance: only publishing place',
      () {
        final json = {
          'full_title': 'Test Book',
          'biblionumber': '12345',
          'author': 'John Doe',
          'place': 'New York',
          'publishercode': null,
          'copyrightdate': null,
          'libraries_count': 2,
          'total_results': 6,
        };

        final bookPreview = BookPreview.fromJson(json);

        expect(bookPreview, isA<BookPreview>());
      },
    );

    test(
      'fromJson creates a valid BookPreview instance: only publisher code',
      () {
        final json = {
          'full_title': 'Test Book',
          'biblionumber': '12345',
          'author': 'John Doe',
          'place': null,
          'publishercode': 'Publisher Test',
          'copyrightdate': null,
          'libraries_count': 2,
          'total_results': 6,
        };

        final bookPreview = BookPreview.fromJson(json);

        expect(bookPreview, isA<BookPreview>());
      },
    );

    test(
      'fromJson creates a valid BookPreview instance: only copyrightdate',
      () {
        final json = {
          'full_title': 'Test Book',
          'biblionumber': '12345',
          'author': 'John Doe',
          'place': null,
          'publishercode': null,
          'copyrightdate': 2020,
          'libraries_count': 2,
          'total_results': 6,
        };

        final bookPreview = BookPreview.fromJson(json);

        expect(bookPreview, isA<BookPreview>());
      },
    );

    test(
      'fromJson creates a valid BookPreview instance: only publishing place and copyrightdate',
      () {
        final json = {
          'full_title': 'Test Book',
          'biblionumber': '12345',
          'author': 'John Doe',
          'place': 'New York',
          'publishercode': null,
          'copyrightdate': 2020,
          'libraries_count': 2,
          'total_results': 6,
        };

        final bookPreview = BookPreview.fromJson(json);

        expect(bookPreview, isA<BookPreview>());
      },
    );
  });

  group('BookPreview model buildPublishingDetails', () {
    test('buildPublishingDetails: all fields', () {
      final json = {
        'full_title': 'Test Book',
        'biblionumber': '12345',
        'author': 'John Doe',
        'place': 'New York',
        'publishercode': 'Publisher Test',
        'copyrightdate': 2020,
        'libraries_count': 2,
        'total_results': 6,
      };

      final expectedPublishingDetails = 'New York Publisher Test 2020';
      final actualPublishingDetails = BookPreview.buildPublishingDetails(json);

      expect(actualPublishingDetails, expectedPublishingDetails);
    });

    test('buildPublishingDetails: empty publishing fields', () {
      final json = {
        'full_title': 'Test Book',
        'biblionumber': '12345',
        'author': 'John Doe',
        'place': null,
        'publishercode': null,
        'copyrightdate': null,
        'libraries_count': 2,
        'total_results': 6,
      };

      final expectedPublishingDetails = '';
      final actualPublishingDetails = BookPreview.buildPublishingDetails(json);

      expect(actualPublishingDetails, expectedPublishingDetails);
    });

    test('buildPublishingDetails: only place', () {
      final json = {
        'full_title': 'Test Book',
        'biblionumber': '12345',
        'author': 'John Doe',
        'place': 'New York',
        'publishercode': null,
        'copyrightdate': null,
        'libraries_count': 2,
        'total_results': 6,
      };

      final expectedPublishingDetails = 'New York';
      final actualPublishingDetails = BookPreview.buildPublishingDetails(json);

      expect(actualPublishingDetails, expectedPublishingDetails);
    });

    test('buildPublishingDetails: only publishercode', () {
      final json = {
        'full_title': 'Test Book',
        'biblionumber': '12345',
        'author': 'John Doe',
        'place': null,
        'publishercode': 'Publisher Test',
        'copyrightdate': null,
        'libraries_count': 2,
        'total_results': 6,
      };

      final expectedPublishingDetails = 'Publisher Test';
      final actualPublishingDetails = BookPreview.buildPublishingDetails(json);

      expect(actualPublishingDetails, expectedPublishingDetails);
    });

    test('buildPublishingDetails: only copyrightdate', () {
      final json = {
        'full_title': 'Test Book',
        'biblionumber': '12345',
        'author': 'John Doe',
        'place': null,
        'publishercode': null,
        'copyrightdate': 2020,
        'libraries_count': 2,
        'total_results': 6,
      };

      final expectedPublishingDetails = '2020';
      final actualPublishingDetails = BookPreview.buildPublishingDetails(json);

      expect(actualPublishingDetails, expectedPublishingDetails);
    });

    test('buildPublishingDetails: only 2 of 3 fields present', () {
      final json = {
        'full_title': 'Test Book',
        'biblionumber': '12345',
        'author': 'John Doe',
        'place': 'New York',
        'publishercode': null,
        'copyrightdate': 2020,
        'libraries_count': 2,
        'total_results': 6,
      };

      final expectedPublishingDetails = 'New York 2020';
      final actualPublishingDetails = BookPreview.buildPublishingDetails(json);

      expect(actualPublishingDetails, expectedPublishingDetails);
    });
  });

  group('BookPreview model toString method', () {
    test('toString returns a valid string representation', () {
      final bookPreview = BookPreview(
        title: 'Test Book',
        author: 'John Doe',
        coverUrl: 'http://example.com/cover.jpg',
        biblioNumber: '12345',
        publishingDetails: 'New York Test Publisher 2020',
        totalRecords: 2,
        locatedInLibraries: 6,
      );

      expect(
        bookPreview.toString(),
        'BookPreview(title: Test Book, author: John Doe, coverUrl: http://example.com/cover.jpg, biblioNumber: 12345, publishingDetails: New York Test Publisher 2020, locatedInLibraries: 6, totalRecords: 2)',
      );
    });
  });
}
