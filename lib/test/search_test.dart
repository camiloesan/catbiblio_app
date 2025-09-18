import 'package:flutter/widgets.dart';
import 'package:test/test.dart';
import 'package:catbiblio_app/models/book_preview.dart';
import 'package:catbiblio_app/models/query_params.dart';
import 'package:catbiblio_app/services/svc/search.dart';

void main() {
  group('SruService', () {
    final sruService = SruService();

    test('searchBooks returns a list of BookPreview', () async {
      final queryParams = QueryParams(
        library: 'USBI-X',
        searchBy: 'title',
        searchQuery: 'Dune',
        filterController: TextEditingController(),
        libraryController: TextEditingController(),
      );

      final response = await sruService.searchBooks(queryParams);
      final books = await sruService.searchBooks(queryParams);

      expect(response, equals(200));
    });
  });
}
