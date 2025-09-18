import 'package:flutter/widgets.dart';
import 'package:test/test.dart';
import 'package:catbiblio_app/models/book_preview.dart';
import 'package:catbiblio_app/models/query_params.dart';
import 'package:catbiblio_app/services/svc/search.dart';

void main() {
  group('SruService', () {
    test('searchBooks returns a list of BookPreview', () async {
      final queryParams = QueryParams(
        library: 'USBI-X',
        searchBy: 'title',
        searchQuery: 'sistemas operativos',
        filterController: TextEditingController(),
        libraryController: TextEditingController(),
      );

      final response = await SruService.searchBooks(queryParams);

      expect(response, isA<List<BookPreview>>());
    });
  });
}
