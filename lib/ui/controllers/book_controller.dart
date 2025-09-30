part of '../views/book_view.dart';

abstract class BookController extends State<BookView> {
  late BibliosDetails bibliosDetails = BibliosDetails(title: '', author: '');
  late List<BiblioItem> biblioItems = [];
  bool isLoadingDetails = true;
  bool isErrorLoadingDetails = false;
  bool isLoadingBiblioItems = true;
  bool isErrorLoadingBiblioItems = false;

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
    BibliosDetailsService.getBibliosDetails(widget.biblioNumber)
        .then((details) {
          if (!mounted) return;
          setState(() {
            bibliosDetails = details;
            isLoadingDetails = false;
          });
        })
        .catchError((error) {
          if (!mounted) return;
          setState(() {
            isErrorLoadingDetails = true;
            isLoadingDetails = false;
          });
        });
    BibliosItemsService.getBiblioItems(int.parse(widget.biblioNumber))
        .then((items) {
          if (!mounted) return;
          setState(() {
            biblioItems = items;
            isLoadingBiblioItems = false;
          });
        })
        .catchError((error) {
          if (!mounted) return;
          setState(() {
            isErrorLoadingBiblioItems = true;
            isLoadingBiblioItems = false;
          });
        });

  }
}
