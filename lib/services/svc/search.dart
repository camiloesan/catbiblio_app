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
      headers: {'Accept': 'application/xml', 'x-api-key': '12345'},
    ),
  );

  // TODO: break into smaller single responsibility methods
  /// Searches for books based on the provided query parameters
  ///
  /// Examples:
  /// - Title search: http://baseUrl/cgi-bin/koha/svc/bibliosItems?title=dune&branch=USBI-X
  /// - Author search: http://baseUrl/cgi-bin/koha/svc/bibliosItems?author=frank+herbert
  /// - Subject search: http://baseUrl/cgi-bin/koha/svc/bibliosItems?subject=ciencia+ficcion&branch=USBI-V
  static Future<(List<BookPreview>, int)> searchBooks(QueryParams params) async {
    final queryParameters = buildQueryParameters(params);

    try {
      final response = await _dio.get(
        '/cgi-bin/koha/svc/bibliosItems',
        queryParameters: queryParameters,
      );

      final document = xml.XmlDocument.parse(response.data);
      const marcNamespace = "http://www.loc.gov/MARC21/slim";

      final numberOfRecords = document.findAllElements(
        "numberOfRecords",
        namespace: "http://www.loc.gov/zing/srw/",
      ).firstOrNull?.innerText;

      final totalRecords = int.tryParse(numberOfRecords ?? '0') ?? 0;

      final records = document.findAllElements(
        "recordData",
        namespace: "http://www.loc.gov/zing/srw/",
      );

      List<BookPreview> books = [];

      for (var recordData in records) {
        final record = recordData
            .findElements("record", namespace: marcNamespace)
            .firstOrNull;
        if (record == null) continue;

        final datafields = record.findElements(
          "datafield",
          namespace: marcNamespace,
        );

        xml.XmlElement? df(String tag) => datafields.firstWhereOrNull(
          (element) => element.getAttribute("tag") == tag,
        );

        String? getSubfield(xml.XmlElement? df, String code) {
          return df
              ?.findElements("subfield", namespace: marcNamespace)
              .firstWhereOrNull((sf) => sf.getAttribute("code") == code)
              ?.innerText;
        }

        final datafield245 = df("245");
        final datafield100 = df("100");
        final datafield999 = df("999");
        final datafield260 = df("260");

        BookPreview book = BookPreview(
          title: '',
          author: '',
          coverUrl: '',
          biblioNumber: '',
          publishingDetails: '',
        );

        book.author = getSubfield(datafield100, "a") ?? "N/A";
        book.biblioNumber = getSubfield(datafield999, "c") ?? "";
        book.title = [
          getSubfield(datafield245, "a"),
          getSubfield(datafield245, "b"),
          getSubfield(datafield245, "c"),
        ].where((e) => e?.isNotEmpty ?? false).join(" ");
        book.publishingDetails = [
          getSubfield(datafield260, "a"),
          getSubfield(datafield260, "b"),
          getSubfield(datafield260, "c"),
        ].where((e) => e?.isNotEmpty ?? false).join(" ");

        books.add(book);
      }
      
      return (books, totalRecords);
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
            'startRecord': params.startRecord > 1 ? params.startRecord : null,
          }..removeWhere(
            (key, value) =>
                value == null ||
                (value is String && value.isEmpty) ||
                (value is int && value <= 1),
          );
    } catch (e) {
      throw Exception("Error building query parameters: ${e.toString()}");
    }

    return queryParameters;
  }
}
