class BookPreview {
  String title;
  String author;
  String coverUrl;
  String biblioNumber;
  String publishingDetails;
  int locatedInLibraries = 0;

  BookPreview({
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.biblioNumber,
    required this.publishingDetails,
    required this.locatedInLibraries,
  });

  @override
  String toString() {
    return 'BookPreview(title: $title, author: $author, coverUrl: $coverUrl, biblioNumber: $biblioNumber, publishingDetails: $publishingDetails, locatedInLibraries: $locatedInLibraries)';
  }
}
