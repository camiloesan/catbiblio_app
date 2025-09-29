part of '../views/book_view.dart';

abstract class BookController extends State<BookView> {
  late Future<BibliosDetails> _bibliosDetailsFuture;
  BibliosDetails bibliosDetails = BibliosDetails(title: '', author: '');
  Map<String, String> get languageMap => {
  'eng': AppLocalizations.of(context)!.english,
  'spa': AppLocalizations.of(context)!.spanish,
  'fre': AppLocalizations.of(context)!.french,
  'ger': AppLocalizations.of(context)!.german,
  'jpn': AppLocalizations.of(context)!.japanese,
  'ita': AppLocalizations.of(context)!.italian,
  'por': AppLocalizations.of(context)!.portuguese,
  'rus': AppLocalizations.of(context)!.russian,
  'chi': AppLocalizations.of(context)!.chinese,
};

  @override
  void initState() {
    super.initState();
    _bibliosDetailsFuture = BibliosDetailsService.getBibliosDetails(widget.biblioNumber);
  }
}
