import 'package:catbiblio_app/models/book_preview.dart';

class SearchResult {
  final List<BookPreview> books;
  final int totalRecords;

  SearchResult({required this.books, required this.totalRecords});

  @override
  String toString() {
    return 'SearchResult(totalRecords: $totalRecords, books: $books)';
  }
}
