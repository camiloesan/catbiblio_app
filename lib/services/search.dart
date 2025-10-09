import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart' as xml;
import 'package:collection/collection.dart';
import 'package:catbiblio_app/models/query_params.dart';
import 'package:catbiblio_app/models/book_preview.dart';
import 'package:catbiblio_app/models/search_result.dart';

sealed class SruException implements Exception {
  final String message;
  const SruException(this.message);

  @override
  String toString() => message;
}

class NetworkException extends SruException {
  const NetworkException(super.message);
}

class ParseException extends SruException {
  const ParseException(super.message);
}

class ApiException extends SruException {
  final int? statusCode;
  const ApiException(super.message, {this.statusCode});
}

class SruService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://148.226.6.25/cgi-bin/koha/svc',
      responseType: ResponseType.plain,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Accept': 'application/xml', 'x-api-key': '12345'},
    ),
  );

  /// MARC and SRU namespaces
  static const String _marcNamespace = "http://www.loc.gov/MARC21/slim";
  static const String _sruNamespace = "http://www.loc.gov/zing/srw/";

  /// MARC field tags
  static const String _titleTag = "245";
  static const String _authorTag = "100";
  static const String _biblioNumberTag = "999";
  static const String _publishingDetailsTag = "260";

  /// Searches for books based on the provided [QueryParams].
  ///
  /// Returns a [SearchResult] containing a list of [BookPreview] and the total [int] of records found,
  /// or throws a [SruException] if the request fails.
  ///
  /// Examples:
  /// - Title search: http://baseUrl/cgi-bin/koha/svc/bibliosItems?title=dune&branch=USBI-X
  ///   - searchBooks(QueryParams(library: 'USBI-X', searchBy: 'title', searchQuery: 'dune'))
  /// - Author search: http://baseUrl/cgi-bin/koha/svc/bibliosItems?author=frank+herbert
  ///   - searchBooks(QueryParams(library: 'USBI-X', searchBy: 'author', searchQuery: 'frank herbert'))
  /// - Subject search: http://baseUrl/cgi-bin/koha/svc/bibliosItems?subject=ciencia+ficcion&branch=USBI-V
  ///   - searchBooks(QueryParams(library: 'USBI-V', searchBy: 'subject', searchQuery: 'ciencia ficcion'))
  static Future<SearchResult> searchBooks(QueryParams params) async {
    final queryParameters = buildQueryParameters(params);

    try {
      final response = await _dio.get(
        '/app_search',
        queryParameters: queryParameters,
      );

      return _parseXmlResponse(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ParseException("Unexpected error: $e");
    }
  }

  /// Parses the XML response and extracts total records and book previews
  static SearchResult _parseXmlResponse(String xmlData) {
    try {
      final document = xml.XmlDocument.parse(xmlData);

      final totalRecords = _extractTotalRecords(document);
      final books = _extractBooks(document);

      return SearchResult(books: books, totalRecords: totalRecords);
    } catch (e) {
      throw ParseException("Error parsing SRU response: $e");
    }
  }

  /// Extracts the total number of records from the XML response
  static int _extractTotalRecords(xml.XmlDocument document) {
    final numberOfRecords = document
        .findAllElements("numberOfRecords", namespace: _sruNamespace)
        .firstOrNull
        ?.innerText;

    return int.tryParse(numberOfRecords ?? '0') ?? 0;
  }

  /// Extracts all books from the XML document
  static List<BookPreview> _extractBooks(xml.XmlDocument document) {
    final records = document.findAllElements(
      "recordData",
      namespace: _sruNamespace,
    );

    return records
        .map(_parseBookRecord)
        .whereType<BookPreview>() // Filter out failed parses
        .toList();
  }

  /// Parses a single book record from the XML
  static BookPreview? _parseBookRecord(xml.XmlElement recordData) {
    try {
      final record = recordData
          .findElements("record", namespace: _marcNamespace)
          .firstOrNull;

      if (record == null) {
        debugPrint("Warning: No MARC record found in recordData");
        return null;
      }

      final dataFieldHelper = _DataFieldHelper(record);

      final title = _extractTitle(dataFieldHelper);
      final author = _extractAuthor(dataFieldHelper);
      final biblioNumber = _extractBiblioNumber(dataFieldHelper);
      final publishingDetails = _extractPublishingDetails(dataFieldHelper);
      final locatedInLibraries = _952Coincidences(dataFieldHelper);

      //if (title.trim().isEmpty) return null;

      return BookPreview(
        title: title,
        author: author,
        coverUrl: '',
        biblioNumber: biblioNumber,
        publishingDetails: publishingDetails,
        locatedInLibraries: locatedInLibraries,
      );
    } catch (e) {
      debugPrint("Error parsing book record: ${e.toString()}");
      return null;
    }
  }

  /// Extracts the title from MARC field 245
  static String _extractTitle(_DataFieldHelper helper) {
    final titleParts = [
      helper.getSubfield(_titleTag, 'a'), // Title
      helper.getSubfield(_titleTag, 'b'), // Remainder of title
      helper.getSubfield(_titleTag, 'c'), // Statement of responsibility
    ].where((part) => part != null && part.isNotEmpty).toList();

    return titleParts.join(' ').trim();
  }

  /// Extracts the author from MARC field 100
  static String _extractAuthor(_DataFieldHelper helper) {
    return helper.getSubfield(_authorTag, 'a') ?? '';
  }

  /// Extracts the bibliographic number from MARC field 999 (local use)
  static String _extractBiblioNumber(_DataFieldHelper helper) {
    return helper.getSubfield(_biblioNumberTag, 'c')?.trim() ?? '';
  }

  static int _952Coincidences(_DataFieldHelper helper) {
    return helper._datafieldTagCoincidences('952');
  }

  /// Extracts publishing details from MARC field 260
  static String _extractPublishingDetails(_DataFieldHelper helper) {
    final publishingParts = [
      helper.getSubfield(_publishingDetailsTag, 'a'), // Place of publication
      helper.getSubfield(_publishingDetailsTag, 'b'), // Publisher
      helper.getSubfield(_publishingDetailsTag, 'c'), // Date of publication
    ].where((part) => part != null && part.isNotEmpty).toList();

    return publishingParts.join(' ');
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

      return queryParameters;
    } catch (e) {
      throw ParseException("Error building query parameters: $e");
    }
  }

  /// Handles Dio exceptions and providing meaningful error messages
  static SruException _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return const NetworkException(
          "Connection timeout - please check your internet connection",
        );
      case DioExceptionType.receiveTimeout:
        return const NetworkException(
          "Request timeout - the server took too long to respond",
        );
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final statusMessage = e.response?.statusMessage;
        return ApiException(
          "Server error: $statusCode - $statusMessage",
          statusCode: statusCode,
        );
      case DioExceptionType.connectionError:
        return const NetworkException(
          "Connection error - unable to reach the server",
        );
      case DioExceptionType.cancel:
        return const NetworkException("Request was cancelled");
      default:
        return NetworkException("Network error: ${e.message}");
    }
  }

  static Future<(List<BookPreview>, int)?> searchBooksOld(
    QueryParams params,
  ) async {
    final queryParameters = buildQueryParameters(params);

    try {
      final response = await _dio.get(
        '/cgi-bin/koha/svc/app_search',
        queryParameters: queryParameters,
      );

      final document = xml.XmlDocument.parse(response.data);
      const marcNamespace = "http://www.loc.gov/MARC21/slim";

      final numberOfRecords = document
          .findAllElements(
            "numberOfRecords",
            namespace: "http://www.loc.gov/zing/srw/",
          )
          .firstOrNull
          ?.innerText;

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
          locatedInLibraries: 0,
        );

        book.author = getSubfield(datafield100, "a") ?? "";
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
    } on DioException {
      return null;
    }
  }
}

/// Helper class to simplify datafield and subfield extraction
/// This encapsulates the repetitive XML navigation logic
class _DataFieldHelper {
  final xml.XmlElement record;
  final Map<String, xml.XmlElement?> _dataFieldCache = {};

  _DataFieldHelper(this.record);

  /// Gets a datafield by tag, with caching for performance
  xml.XmlElement? _getDataField(String tag) {
    if (!_dataFieldCache.containsKey(tag)) {
      _dataFieldCache[tag] = record
          .findElements("datafield", namespace: SruService._marcNamespace)
          .firstWhereOrNull((df) => df.getAttribute("tag") == tag);
    }
    return _dataFieldCache[tag];
  }

  /// Gets a subfield value by datafield tag and subfield code
  String? getSubfield(String datafieldTag, String subfieldCode) {
    final dataField = _getDataField(datafieldTag);
    if (dataField == null) return null;

    return dataField
        .findElements("subfield", namespace: SruService._marcNamespace)
        .firstWhereOrNull((sf) => sf.getAttribute("code") == subfieldCode)
        ?.innerText
        .trim();
  }

  int _datafieldTagCoincidences(String tag) {
    Set libraries = {};

    final datafields952 = record
        .findElements("datafield", namespace: SruService._marcNamespace)
        .where((element) => element.getAttribute("tag") == tag);

    for (var df in datafields952) {
      var libraryName = df
          .findElements("subfield", namespace: SruService._marcNamespace)
          .firstWhereOrNull((sf) => sf.getAttribute("code") == 'a')
          ?.innerText
          .trim();

      if (libraryName != null && libraryName.isNotEmpty) {
        libraries.add(libraryName);
      }
    }

    return libraries.length;
  }
}
