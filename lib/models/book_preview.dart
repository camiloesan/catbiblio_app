class BookPreview {
  String title;
  String author;
  String coverUrl;
  String biblioNumber;
  String publishingDetails;

  BookPreview({
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.biblioNumber,
    required this.publishingDetails,
  });

  @override
  String toString() {
    return 'BookPreview(title: $title, author: $author, coverUrl: $coverUrl, biblioNumber: $biblioNumber, publishingDetails: $publishingDetails)';
  }
}
