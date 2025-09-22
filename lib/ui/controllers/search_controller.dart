part of '../views/search_view.dart';

abstract class SearchController extends State<SearchView> {
  late TextEditingController _libraryController;
  late TextEditingController _filterController;
  late TextEditingController _searchController;
  late ScrollController _scrollController;
  QueryParams queryParams = QueryParams(
    library: '',
    searchBy: 'title',
    searchQuery: '',
    filterController: TextEditingController(),
    libraryController: TextEditingController(),
  );
  late List<BookPreview> books = [];
  int currentPage = 1;
  int totalPages = 0;
  int setUpperLimit = 10;
  int setLowerLimit = 1;
  int totalRecords = 0;

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
    _scrollController = ScrollController();
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
        books = result.$1;
        totalRecords = result.$2;
        totalPages = (totalRecords / 10).ceil();
      });
    });
  }

  void onSubmitAction(String searchQuery) {
    if (searchQuery.isNotEmpty) {
      setState(() {
        queryParams.searchQuery = searchQuery;
        books.clear();
        totalRecords = 0;
        currentPage = 1;
        setUpperLimit = 10;
        setLowerLimit = 1;
        updatePageResults();
      });
    }
  }

  void updatePageResults() {
    queryParams.startRecord = (currentPage - 1) * 10 + 1;
    SruService.searchBooks(queryParams).then((result) {
      setState(() {
        books = result.$1;
        totalRecords = result.$2;
        totalPages = (totalRecords / 10).ceil();
      });
    });
  }

  void paginationBehavior(int selectedIndex) {
    /// This allows for pagination to continue forward.
    if (currentPage + 1 == setUpperLimit && selectedIndex == setUpperLimit) {
      setState(() {
        setUpperLimit += 8;
        setLowerLimit += 8;
        currentPage++;
        updatePageResults();
      });
      return;
    }

    /// This allows for pagination to continue backwards.
    if (currentPage - 1 == setLowerLimit &&
        selectedIndex == setLowerLimit &&
        currentPage > 9) {
      setState(() {
        setUpperLimit -= 8;
        setLowerLimit -= 8;
        currentPage--;
        updatePageResults();
      });
      return;
    }

    /// This prevents reloading the same page.
    if (selectedIndex == currentPage) return;

    /// This allows for pagination to continue forward one page.
    if (selectedIndex == setUpperLimit) {
      setState(() {
        currentPage++;
        updatePageResults();
      });
      return;
    }

    /// This allows for pagination to continue backwards one page.
    if (selectedIndex == setLowerLimit && currentPage > 9) {
      setState(() {
        currentPage--;
        updatePageResults();
      });
      return;
    }

    /// This allows for pagination to jump to a specific page.
    setState(() {
      currentPage = selectedIndex;
      updatePageResults();
    });
  }
}
