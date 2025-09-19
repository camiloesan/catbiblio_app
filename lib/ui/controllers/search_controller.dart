part of '../views/search_view.dart';

abstract class SearchController extends State<SearchView> {
  late TextEditingController _libraryController;
  late TextEditingController _filterController;
  late TextEditingController _searchController;
  QueryParams queryParams = QueryParams(
    library: '',
    searchBy: 'title',
    searchQuery: '',
    filterController: TextEditingController(),
    libraryController: TextEditingController(),
  );
  late List<BookPreview> books = [];

  List<DropdownMenuEntry<String>> get _filterEntries {
    return [
      DropdownMenuEntry(
        value: 'title',
        label: AppLocalizations.of(context)!.titleEntry,
      ),
      DropdownMenuEntry(
        value: 'author',
        label: AppLocalizations.of(context)!.authorEntry,
      ),
      DropdownMenuEntry(
        value: 'subject',
        label: AppLocalizations.of(context)!.subjectEntry,
      ),
      DropdownMenuEntry(
        value: 'isbn',
        label: AppLocalizations.of(context)!.isbnEntry,
      ),
      DropdownMenuEntry(
        value: 'issn',
        label: AppLocalizations.of(context)!.issnEntry,
      ),
    ];
  }

  List<DropdownMenuEntry<String>> get _libraryEntries {
    return [
      DropdownMenuEntry(
        value: 'all',
        label: AppLocalizations.of(context)!.allLibraries,
      ),
      DropdownMenuEntry(value: 'USBI-X', label: 'USBI Xalapa'),
      DropdownMenuEntry(value: 'USBI-V', label: 'USBI Veracruz'),
    ];
  }

  @override
  void initState() {
    super.initState();
    _filterController = TextEditingController();
    _libraryController = TextEditingController();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void clearText() {
    _searchController.clear();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    args.runtimeType;
    if (args is QueryParams) {
      queryParams = args;
    }
    _filterController = queryParams.filterController;
    _libraryController = queryParams.libraryController;
    _searchController.text = queryParams.searchQuery;
    SruService.searchBooks(queryParams).then((result) {
      setState(() {
        books = result;
      });
    });
  }

  void onSubmitAction(String cadenaDeBusqueda) {
    if (cadenaDeBusqueda.isNotEmpty) {
      queryParams.searchQuery = cadenaDeBusqueda;
      SruService.searchBooks(queryParams).then((result) {
        setState(() {
          books.clear();
          books = result;
        });
      });
    }
  }
}
