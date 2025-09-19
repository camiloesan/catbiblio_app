import 'package:dio/dio.dart';
import 'package:xml/xml.dart' as xml;
import 'package:collection/collection.dart';
import 'package:catbiblio_app/models/query_params.dart';
import 'package:catbiblio_app/models/book_preview.dart';

class SruService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://148.226.6.25',
      responseType: ResponseType.plain,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Accept': 'application/xml'},
    ),
  );

  // TODO: break into smaller single responsibility methods
  /// Searches for books based on the provided query parameters
  ///
  /// Examples:
  /// - Title search: http://baseUrl/cgi-bin/koha/svc/bibliosItems?title=dune&branch=USBI-X
  /// - Author search: http://baseUrl/cgi-bin/koha/svc/bibliosItems?author=frank+herbert
  /// - Subject search: http://baseUrl/cgi-bin/koha/svc/bibliosItems?subject=ciencia+ficcion&branch=USBI-V
  static Future<List<BookPreview>> searchBooks(QueryParams params) async {
    final queryParameters = buildQueryParameters(params);

    try {
      final response = await _dio.get(
        '/cgi-bin/koha/svc/bibliosItems',
        queryParameters: queryParameters,
      );

      final document = xml.XmlDocument.parse(response.data);
      const marcNamespace = "http://www.loc.gov/MARC21/slim";
      final records = document.findAllElements(
        "recordData",
        namespace: "http://www.loc.gov/zing/srw/",
      );

      List<BookPreview> books = [];

      for (var recordData in records) {
        BookPreview book = BookPreview(
          title: '',
          author: '',
          coverUrl: '',
          biblioNumber: '',
          publishingDetails: '',
        );

        final record = recordData
            .findElements("record", namespace: marcNamespace)
            .firstOrNull;

        if (record == null) continue; // Skip if record not found

        final datafield245 = record
            .findElements("datafield", namespace: marcNamespace)
            .firstWhereOrNull((df) => df.getAttribute("tag") == "245");

        if (datafield245 == null) continue; // Skip if datafield245 not found

        final datafield100 = record
            .findElements("datafield", namespace: marcNamespace)
            .firstWhereOrNull((df) => df.getAttribute("tag") == "100");
        if (datafield100 != null) {
          var a100 = datafield100
              .findElements("subfield", namespace: marcNamespace)
              .firstWhereOrNull((sf) => sf.getAttribute("code") == "a");
          if (a100 != null) {
            book.author = a100.innerText;
          }
        }

        final datafield999 = record
            .findElements("datafield", namespace: marcNamespace)
            .firstWhereOrNull((df) => df.getAttribute("tag") == "999");
        if (datafield999 != null) {
          var a999 = datafield999
              .findElements("subfield", namespace: marcNamespace)
              .firstWhereOrNull((sf) => sf.getAttribute("code") == "c");
          if (a999 != null) {
            book.biblioNumber = a999.innerText;
          }
        }

        final subfieldA = datafield245
            .findElements("subfield", namespace: marcNamespace)
            .firstWhereOrNull((sf) => sf.getAttribute("code") == "a");

        final subfieldB = datafield245
            .findElements("subfield", namespace: marcNamespace)
            .firstWhereOrNull((sf) => sf.getAttribute("code") == "b");

        final subfieldC = datafield245
            .findElements("subfield", namespace: marcNamespace)
            .firstWhereOrNull((sf) => sf.getAttribute("code") == "c");
        final title =
            "${subfieldA?.innerText ?? ''} ${subfieldB?.innerText ?? ''} ${subfieldC?.innerText ?? ''}";
        book.title = title;

        final datafield260 = record
            .findElements("datafield", namespace: marcNamespace)
            .firstWhereOrNull((df) => df.getAttribute("tag") == "260");
        if (datafield260 != null) {
          var a260 = datafield260
              .findElements("subfield", namespace: marcNamespace)
              .firstWhereOrNull((sf) => sf.getAttribute("code") == "a");
          var b260 = datafield260
              .findElements("subfield", namespace: marcNamespace)
              .firstWhereOrNull((sf) => sf.getAttribute("code") == "b");
          var c260 = datafield260
              .findElements("subfield", namespace: marcNamespace)
              .firstWhereOrNull((sf) => sf.getAttribute("code") == "c");
          var publishingDetails =
              "${a260?.innerText ?? ''} ${b260?.innerText ?? ''} ${c260?.innerText ?? ''}";
          book.publishingDetails = publishingDetails;
        }

        books.add(book);
      }
      return books;
    } on DioException catch (e) {
      throw Exception("Failed to load XML: ${e.message}");
    }
  }

  static Map<String, dynamic> buildQueryParameters(QueryParams params) {
    late Map<String, dynamic> queryParameters;

    try {
      queryParameters =
          <String, dynamic>{
            'title': params.searchBy == 'title' ? params.searchQuery : null,
            'author': params.searchBy == 'author' ? params.searchQuery : null,
            'subject': params.searchBy == 'subject' ? params.searchQuery : null,
            'isbn': params.searchBy == 'isbn' ? params.searchQuery : null,
            'issn': params.searchBy == 'issn' ? params.searchQuery : null,
            'branch': params.library != 'all' ? params.library : null,
          }..removeWhere(
            (key, value) =>
                value == null ||
                value.isEmpty ||
                (value is String && value.isEmpty),
          );
    } catch (e) {
      throw Exception("Error building query parameters: ${e.toString()}");
    }

    return queryParameters;
  }
}
