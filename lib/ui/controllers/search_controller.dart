part of '../views/search_view.dart';

abstract class SearchController extends State<SearchView> {
  late TextEditingController _libraryController;
  late TextEditingController _filterController;
  late TextEditingController _searchController;
  late ScrollController _scrollController;
  late List<BookPreview> books = [];
  int currentPage = 1;
  int totalPages = 0;
  int setUpperLimit = 10;
  int setLowerLimit = 1;
  int totalRecords = 0;
  bool isInitialRequestLoading = false;
  bool isPageLoading = false;
  bool isError = false;

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

  @override
  void initState() {
    super.initState();
    _filterController = widget.controllersData.filterController;
    _libraryController = widget.controllersData.libraryController;
    _searchController = TextEditingController();
    _searchController.text = widget.queryParams.searchQuery;
    _scrollController = ScrollController();

    if (widget.queryParams.searchQuery.isNotEmpty) {
      isInitialRequestLoading = true;
      isError = false;
      SruService.searchBooks(widget.queryParams)
          .then((result) {
            if (!mounted) return;
            setState(() {
              books = result.books;
              totalRecords = result.totalRecords;
              totalPages = (totalRecords / 10).ceil();
              isInitialRequestLoading = false;
            });
          })
          .catchError((error) {
            if (!mounted) return;
            setState(() {
              isInitialRequestLoading = false;
              isError = true;
            });
          });
    }
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
  }

  void onSubmitAction(String searchQuery) {
    if (searchQuery.isNotEmpty) {
      setState(() {
        widget.queryParams.searchQuery = searchQuery;
        books.clear();
        totalRecords = 0;
        currentPage = 1;
        setUpperLimit = 10;
        setLowerLimit = 1;
        totalPages = 0;
        updatePageResults();
      });
    }
  }

  void updatePageResults() {
    widget.queryParams.startRecord = (currentPage - 1) * 10 + 1;

    setState(() {
      isPageLoading = true;
    });
    SruService.searchBooks(widget.queryParams)
        .then((result) {
          setState(() {
            books = result.books;
            totalRecords = result.totalRecords;
            totalPages = (totalRecords / 10).ceil();
            isInitialRequestLoading = false;
            isError = false;
            isPageLoading = false;
          });
        })
        .catchError((error) {
          setState(() {
            isInitialRequestLoading = false;
            isError = true;
            isPageLoading = false;
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
