class QueryParams {
  String library;
  String searchBy;
  String searchQuery;
  int startRecord;

  QueryParams({
    this.library = 'all',
    this.searchBy = 'title',
    this.searchQuery = '',
    this.startRecord = 1,
  });

  @override
  String toString() {
    return 'QueryParams(library: $library, searchBy: $searchBy, searchQuery: $searchQuery, startRecord: $startRecord)';
  }

  void reset() {
    library = 'all';
    searchBy = 'title';
    searchQuery = '';
    startRecord = 1;
  }
}
