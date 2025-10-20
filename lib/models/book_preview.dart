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
      publishingDetails:
          ((json['place']?.toString().trim() ?? '').isNotEmpty &&
              (json['publishercode']?.toString().trim() ?? '').isNotEmpty &&
              (json['copyrightdate']?.toString().trim() ?? '').isNotEmpty)
          ? [
              json['place']!.toString().trim(),
              json['publishercode']!.toString().trim(),
              json['copyrightdate']!.toString().trim(),
            ].join(' ')
          : '',
      locatedInLibraries: json['located_in_libraries'] as int? ?? 0,
      totalRecords: json['total_results'] as int? ?? 0,
    );
  }

  @override
  String toString() {
    return 'BookPreview(title: $title, author: $author, coverUrl: $coverUrl, biblioNumber: $biblioNumber, publishingDetails: $publishingDetails, locatedInLibraries: $locatedInLibraries)';
  }
}
