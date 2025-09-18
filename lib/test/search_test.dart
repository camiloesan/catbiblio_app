import 'package:test/test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:catbiblio_app/models/book_preview.dart';
import 'package:catbiblio_app/models/query_params.dart';
import 'package:catbiblio_app/services/svc/search.dart';

void main() {
  group('SruService', () {
    // title search tests
    test('test searchBooks: title and branch', () async {
      final queryParams = QueryParams(
        library: 'USBI-X',
        searchBy: 'title',
        searchQuery: 'sistemas operativos',
        filterController: TextEditingController(),
        libraryController: TextEditingController(),
      );

      final response = await SruService.searchBooks(queryParams);
      //debugPrint("Response: $response");

      expect(response, isA<List<BookPreview>>());
    });

    test('test searchBooks: title and no branch', () async {
      final queryParams = QueryParams(
        library: 'all',
        searchBy: 'title',
        searchQuery: 'sistemas operativos',
        filterController: TextEditingController(),
        libraryController: TextEditingController(),
      );

      final response = await SruService.searchBooks(queryParams);
      //debugPrint(" Response: $response");

      expect(response, isA<List<BookPreview>>());
    });

    // author search tests
    test('test searchBooks: author and branch', () async {
      final queryParams = QueryParams(
        library: 'USBI-X',
        searchBy: 'author',
        searchQuery: 'frank herbert',
        filterController: TextEditingController(),
        libraryController: TextEditingController(),
      );

      final response = await SruService.searchBooks(queryParams);
      //debugPrint("Response: $response");

      expect(response, isA<List<BookPreview>>());
    });

    test('test searchBooks: author and no branch', () async {
      final queryParams = QueryParams(
        library: 'all',
        searchBy: 'author',
        searchQuery: 'frank herbert',
        filterController: TextEditingController(),
        libraryController: TextEditingController(),
      );

      final response = await SruService.searchBooks(queryParams);
      //debugPrint("Response: $response");

      expect(response, isA<List<BookPreview>>());
    });

    test('test searchBooks: subject and no branch', () async {
      final queryParams = QueryParams(
        library: 'all',
        searchBy: 'subject',
        searchQuery: 'ciencia ficcion',
        filterController: TextEditingController(),
        libraryController: TextEditingController(),
      );

      final response = await SruService.searchBooks(queryParams);
      //debugPrint("Response: $response");

      expect(response, isA<List<BookPreview>>());
    });

    test('test searchBooks: subject and branch', () async {
      final queryParams = QueryParams(
        library: 'USBI-X',
        searchBy: 'subject',
        searchQuery: 'ciencia ficcion',
        filterController: TextEditingController(),
        libraryController: TextEditingController(),
      );

      final response = await SruService.searchBooks(queryParams);
      //debugPrint("Response: $response");

      expect(response, isA<List<BookPreview>>());
    });

    test('test searchBooks: empty query', () async {
      final queryParams = QueryParams(
        library: 'all',
        searchBy: 'title',
        searchQuery: '',
        filterController: TextEditingController(),
        libraryController: TextEditingController(),
      );

      final response = await SruService.searchBooks(queryParams);
      //debugPrint("Response: $response");

      expect(response, isA<List<BookPreview>>());
      expect(response.isEmpty, true);
    });

    // ISBN search tests
    test('test searchBooks: ISBN search', () async {
      final queryParams = QueryParams(
        library: 'all',
        searchBy: 'isbn',
        searchQuery: '9780123456789',
        filterController: TextEditingController(),
        libraryController: TextEditingController(),
      );
      final response = await SruService.searchBooks(queryParams);
      expect(response, isA<List<BookPreview>>());
    });

    test('test searchBooks: ISBN with branch', () async {
      final queryParams = QueryParams(
        library: 'USBI-V',
        searchBy: 'isbn',
        searchQuery: '9780123456789',
        filterController: TextEditingController(),
        libraryController: TextEditingController(),
      );
      final response = await SruService.searchBooks(queryParams);
      expect(response, isA<List<BookPreview>>());
    });

    // ISSN search tests
    test('test searchBooks: ISSN search', () async {
      final queryParams = QueryParams(
        library: 'all',
        searchBy: 'issn',
        searchQuery: '1234-5678',
        filterController: TextEditingController(),
        libraryController: TextEditingController(),
      );
      final response = await SruService.searchBooks(queryParams);
      expect(response, isA<List<BookPreview>>());
    });

    test('test searchBooks: ISSN with branch', () async {
      final queryParams = QueryParams(
        library: 'USBI-V',
        searchBy: 'issn',
        searchQuery: '1234-5678',
        filterController: TextEditingController(),
        libraryController: TextEditingController(),
      );
      final response = await SruService.searchBooks(queryParams);
      expect(response, isA<List<BookPreview>>());
    });

    // Different branch tests
    test('test searchBooks: title with USBI-V branch', () async {
      final queryParams = QueryParams(
        library: 'USBI-V',
        searchBy: 'title',
        searchQuery: 'programacion',
        filterController: TextEditingController(),
        libraryController: TextEditingController(),
      );
      final response = await SruService.searchBooks(queryParams);
      expect(response, isA<List<BookPreview>>());
    });

    // Special characters and encoding tests
    test('test searchBooks: title with special characters', () async {
      final queryParams = QueryParams(
        library: 'all',
        searchBy: 'title',
        searchQuery: 'programación básica',
        filterController: TextEditingController(),
        libraryController: TextEditingController(),
      );
      final response = await SruService.searchBooks(queryParams);
      expect(response, isA<List<BookPreview>>());
    });

    test('test searchBooks: author with special characters', () async {
      final queryParams = QueryParams(
        library: 'all',
        searchBy: 'author',
        searchQuery: 'josé martínez',
        filterController: TextEditingController(),
        libraryController: TextEditingController(),
      );
      final response = await SruService.searchBooks(queryParams);
      expect(response, isA<List<BookPreview>>());
    });

    // Multiple word searches
    test('test searchBooks: multi-word title search', () async {
      final queryParams = QueryParams(
        library: 'all',
        searchBy: 'title',
        searchQuery: 'introduction to computer science',
        filterController: TextEditingController(),
        libraryController: TextEditingController(),
      );
      final response = await SruService.searchBooks(queryParams);
      expect(response, isA<List<BookPreview>>());
    });

    test('test searchBooks: multi-word author search', () async {
      final queryParams = QueryParams(
        library: 'all',
        searchBy: 'author',
        searchQuery: 'garcia marquez',
        filterController: TextEditingController(),
        libraryController: TextEditingController(),
      );
      final response = await SruService.searchBooks(queryParams);
      expect(response, isA<List<BookPreview>>());
    });

    // Edge case tests
    test('test searchBooks: single character search', () async {
      final queryParams = QueryParams(
        library: 'all',
        searchBy: 'title',
        searchQuery: 'a',
        filterController: TextEditingController(),
        libraryController: TextEditingController(),
      );
      final response = await SruService.searchBooks(queryParams);
      expect(response, isA<List<BookPreview>>());
    });

    test('test searchBooks: very long search query', () async {
      final queryParams = QueryParams(
        library: 'all',
        searchBy: 'title',
        searchQuery:
            'this is a very long search query that might test the limits of the search system and how it handles extensive input',
        filterController: TextEditingController(),
        libraryController: TextEditingController(),
      );
      final response = await SruService.searchBooks(queryParams);
      expect(response, isA<List<BookPreview>>());
    });

    // Whitespace handling tests
    test('test searchBooks: query with leading/trailing spaces', () async {
      final queryParams = QueryParams(
        library: 'all',
        searchBy: 'title',
        searchQuery: '  programming  ',
        filterController: TextEditingController(),
        libraryController: TextEditingController(),
      );
      final response = await SruService.searchBooks(queryParams);
      expect(response, isA<List<BookPreview>>());
    });

    test('test searchBooks: query with multiple spaces', () async {
      final queryParams = QueryParams(
        library: 'all',
        searchBy: 'title',
        searchQuery: 'computer    science',
        filterController: TextEditingController(),
        libraryController: TextEditingController(),
      );
      final response = await SruService.searchBooks(queryParams);
      expect(response, isA<List<BookPreview>>());
    });

    // Case sensitivity tests
    test('test searchBooks: uppercase query', () async {
      final queryParams = QueryParams(
        library: 'all',
        searchBy: 'title',
        searchQuery: 'PROGRAMMING',
        filterController: TextEditingController(),
        libraryController: TextEditingController(),
      );
      final response = await SruService.searchBooks(queryParams);
      expect(response, isA<List<BookPreview>>());
    });

    test('test searchBooks: mixed case query', () async {
      final queryParams = QueryParams(
        library: 'all',
        searchBy: 'author',
        searchQuery: 'Frank Herbert',
        filterController: TextEditingController(),
        libraryController: TextEditingController(),
      );
      final response = await SruService.searchBooks(queryParams);
      expect(response, isA<List<BookPreview>>());
    });

    // Numeric queries
    test('test searchBooks: numeric title search', () async {
      final queryParams = QueryParams(
        library: 'all',
        searchBy: 'title',
        searchQuery: '2024',
        filterController: TextEditingController(),
        libraryController: TextEditingController(),
      );
      final response = await SruService.searchBooks(queryParams);
      expect(response, isA<List<BookPreview>>());
    });

    // Response validation tests
    test('test searchBooks: validate response structure', () async {
      final queryParams = QueryParams(
        library: 'all',
        searchBy: 'title',
        searchQuery: 'test',
        filterController: TextEditingController(),
        libraryController: TextEditingController(),
      );
      final response = await SruService.searchBooks(queryParams);
      expect(response, isA<List<BookPreview>>());

      // If response is not empty, check structure
      if (response.isNotEmpty) {
        final firstBook = response.first;
        expect(firstBook.title, isA<String>());
        expect(firstBook.author, isA<String>());
        expect(firstBook.coverUrl, isA<String>());
        expect(firstBook.biblioNumber, isA<String>());
        expect(firstBook.publishingDetails, isA<String>());
      }
    });

    // Error handling tests (these might need to be mocked)
    test('test searchBooks: null search query handling', () async {
      final queryParams = QueryParams(
        library: 'all',
        searchBy: 'title',
        searchQuery: '',
        filterController: TextEditingController(),
        libraryController: TextEditingController(),
      );
      final response = await SruService.searchBooks(queryParams);
      expect(response, isA<List<BookPreview>>());
      expect(response.isEmpty, true);
    });

    // Different search combinations
    test('test searchBooks: subject with different branch', () async {
      final queryParams = QueryParams(
        library: 'USBI-V',
        searchBy: 'subject',
        searchQuery: 'matematicas',
        filterController: TextEditingController(),
        libraryController: TextEditingController(),
      );
      final response = await SruService.searchBooks(queryParams);
      expect(response, isA<List<BookPreview>>());
    });

    test('test searchBooks: author with accents', () async {
      final queryParams = QueryParams(
        library: 'all',
        searchBy: 'author',
        searchQuery: 'garcía márquez',
        filterController: TextEditingController(),
        libraryController: TextEditingController(),
      );
      final response = await SruService.searchBooks(queryParams);
      expect(response, isA<List<BookPreview>>());
    });

    // Performance/load tests (basic)
    test('test searchBooks: common search term', () async {
      final queryParams = QueryParams(
        library: 'all',
        searchBy: 'title',
        searchQuery: 'el',
        filterController: TextEditingController(),
        libraryController: TextEditingController(),
      );
      final response = await SruService.searchBooks(queryParams);
      expect(response, isA<List<BookPreview>>());
    });

    // Test with different valid search types
    test('test searchBooks: verify all search types work', () async {
      final searchTypes = ['title', 'author', 'subject', 'isbn', 'issn'];
      final searchQueries = [
        'test',
        'author test',
        'subject test',
        '1234567890',
        '1234-5678',
      ];

      for (int i = 0; i < searchTypes.length; i++) {
        final queryParams = QueryParams(
          library: 'all',
          searchBy: searchTypes[i],
          searchQuery: searchQueries[i],
          filterController: TextEditingController(),
          libraryController: TextEditingController(),
        );
        final response = await SruService.searchBooks(queryParams);
        expect(
          response,
          isA<List<BookPreview>>(),
          reason: 'Failed for search type: ${searchTypes[i]}',
        );
      }
    });
  });
}
