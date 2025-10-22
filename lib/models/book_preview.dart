class BookPreview {
  String title;
  String author;
  String coverUrl;
  String biblioNumber;
  String publishingDetails;
  int totalRecords = 0;
  int locatedInLibraries = 0;

  BookPreview({
    required this.title,
    this.author = '',
    required this.coverUrl,
    required this.biblioNumber,
    this.publishingDetails = '',
    required this.locatedInLibraries,
    required this.totalRecords,
  });

  factory BookPreview.fromJson(Map<String, dynamic> json) {
    return BookPreview(
      title: json['full_title'] as String,
      author: json['author'] as String? ?? '',
      coverUrl: '',
      biblioNumber: json['biblionumber'] as String,
      publishingDetails: (() {
        final place = json['place']?.toString().trim() ?? '';
        final publisher = json['publishercode']?.toString().trim() ?? '';
        final copyright = json['copyrightdate']?.toString().trim() ?? '';
        final parts = [
          place,
          publisher,
          copyright,
        ].where((s) => s.isNotEmpty).toList();
        return parts.isNotEmpty ? parts.join(' ') : '';
      })(),
      totalRecords: json['total_results'] as int? ?? 0,
      locatedInLibraries: json['libraries_count'] as int? ?? 0,
    );
  }

  @override
  String toString() {
    return 'BookPreview(title: $title, author: $author, coverUrl: $coverUrl, biblioNumber: $biblioNumber, publishingDetails: $publishingDetails, locatedInLibraries: $locatedInLibraries, totalRecords: $totalRecords)';
  }
}
