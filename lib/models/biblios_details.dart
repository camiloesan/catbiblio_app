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
}
