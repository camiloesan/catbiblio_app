class QueryParams {
  String library;
  String searchBy;
  String searchQuery;
  int startRecord;
  String itemType;

  QueryParams({
    this.library = 'all',
    this.searchBy = 'title',
    this.searchQuery = '',
    this.startRecord = 1,
    this.itemType = 'all',
  });

  @override
  String toString() {
    return 'QueryParams(library: $library, searchBy: $searchBy, searchQuery: $searchQuery, startRecord: $startRecord, itemType: $itemType)';
  }

  void reset() {
    library = 'all';
    searchBy = 'title';
    searchQuery = '';
    startRecord = 1;
    itemType = 'all';
  }
}
