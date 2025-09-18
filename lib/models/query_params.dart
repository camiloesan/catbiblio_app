import 'package:flutter/widgets.dart';

class QueryParams {
  String library;
  String searchBy;
  String searchQuery;
  TextEditingController filterController;
  TextEditingController libraryController;

  QueryParams({
    required this.library,
    required this.searchBy,
    required this.searchQuery,
    required this.filterController,
    required this.libraryController,
  });

  @override
  String toString() {
    return 'QueryParams(library: $library, searchBy: $searchBy, searchQuery: $searchQuery)';
  }
}
