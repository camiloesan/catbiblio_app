class BibliosDetails {
  String title;
  String author;
  String isbn;
  String language;
  String originalLanguage;
  String subject;
  String collaborators;
  String summary;
  String cdd;
  String loc;
  String editor;
  String edition;
  String description;
  String otherClassification;
  String lawClassification;

  BibliosDetails({
    required this.title,
    required this.author,
    this.isbn = '',
    this.language = '',
    this.originalLanguage = '',
    this.subject = '',
    this.collaborators = '',
    this.summary = '',
    this.cdd = '',
    this.loc = '',
    this.editor = '',
    this.edition = '',
    this.description = '',
    this.otherClassification = '',
    this.lawClassification = '',
  });

  @override
  String toString() {
    return 'BibliosDetails(title: $title, author: $author, isbn: $isbn, language: $language, originalLanguage: $originalLanguage, subject: $subject, collaborators: $collaborators, summary: $summary, cdd: $cdd, loc: $loc, editor: $editor, edition: $edition, description: $description, otherClassification: $otherClassification, lawClassification: $lawClassification)';
  }
}
