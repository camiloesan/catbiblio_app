import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'package:catbiblio_app/models/query_params.dart';
import 'package:catbiblio_app/models/book_preview.dart';

class SruService {
  final String _baseUrl = 'http://148.226.6.25';

  // ejemplo: http://{{baseUrl}}/cgi-bin/koha/svc/bibliosItems?title=dunde&branch=USBI-X
  // ejemplo: http://{{baseUrl}}/cgi-bin/koha/svc/bibliosItems?author=frank+herbert
  // ejemplo: http://{{baseUrl}}/cgi-bin/koha/svc/bibliosItems?subject=ciencia+ficcion&branch=USBI-V
  Future<List<BookPreview>> searchBooks(QueryParams params) async {
    final queryParameters = {
      'title': params.searchBy == 'title' ? params.searchQuery : null,
      'author': params.searchBy == 'author' ? params.searchQuery : null,
      'subject': params.searchBy == 'subject' ? params.searchQuery : null,
      'isbn': params.searchBy == 'isbn' ? params.searchQuery : null,
      'issn': params.searchBy == 'issn' ? params.searchQuery : null,
      'branch': params.library.isNotEmpty ? params.library : null,
    }..removeWhere((key, value) => value == null || value.isEmpty);

    final url = Uri.parse(
      '$_baseUrl/cgi-bin/koha/svc/bibliosItems',
    ).replace(queryParameters: queryParameters);
  }
}
