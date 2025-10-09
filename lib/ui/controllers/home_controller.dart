part of '../views/home_view.dart';

abstract class HomeController extends State<HomeView> {
  late TextEditingController _searchController;
  late TextEditingController _searchFilterController;
  late TextEditingController _libraryController;
  late TextEditingController _itemTypeController;
  late Future<List<Library>> _librariesFuture;
  late List<DropdownMenuEntry<String>> _libraryEntries = [];
  final QueryParams _queryParams = QueryParams();

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

  List<DropdownMenuEntry<String>> get _itemTypeEntries {
    return [
      DropdownMenuEntry(
        value: 'all',
        label: AppLocalizations.of(context)!.allLibraries,
      ),
    ];
  }

  @override
  initState() {
    super.initState();
    _searchFilterController = TextEditingController();
    _libraryController = TextEditingController();
    _searchController = TextEditingController();
    _itemTypeController = TextEditingController();
    if (_libraryEntries.length <= 1) {
      _librariesFuture = LibrariesService.getLibraries();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFilterController.dispose();
    _libraryController.dispose();
    _itemTypeController.dispose();
    super.dispose();
  }

  void clearText() {
    _searchController.clear();
  }

  void onSubmitAction() {
    if (_searchController.text.isEmpty) return;

    ControllersData controllersData = ControllersData(
      filterController: _searchFilterController,
      libraryController: _libraryController,
      libraryEntries: _libraryEntries,
      itemTypeController: _itemTypeController,
    );
    _queryParams.startRecord = 1;
    _queryParams.searchQuery = _searchController.text;

    navigateToSearchView(controllersData);
  }

  void navigateToSearchView(ControllersData controllersData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchView(
          controllersData: controllersData,
          queryParams: _queryParams,
        ),
      ),
    );
  }

  void clearSearchController() {
    _searchController.clear();
  }

  Future<void> openLink(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo abrir el enlace: $url')),
        );
      }
    }
  }
}
