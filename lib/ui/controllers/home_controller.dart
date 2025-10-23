part of '../views/home_view.dart';

abstract class HomeController extends State<HomeView> {
  late TextEditingController _searchController;
  late TextEditingController _searchFilterController;
  late TextEditingController _libraryController;
  late TextEditingController _libraryServicesController;
  late TextEditingController _itemTypeController;
  late Future<List<Library>> _librariesFuture;
  late CarouselSliderController _booksCarouselSliderController;
  late List<DropdownMenuEntry<String>> _libraryEntries = [];
  late List<DropdownMenuEntry<String>> _itemTypeEntries = [];
  late List<DropdownMenuEntry<String>> _enabledHomeLibrariesEntries = [];
  late List<LibraryServices> _librariesServices = [];
  late List<BookSelection> _bookSelections = [];
  final QueryParams _queryParams = QueryParams();
  String selectedLibraryServices = 'USBI-X';
  bool isSelectionsEnabled = false;
  bool isSearchable = false;
  bool isItemTypesLoading = true;
  bool isLibrariesLoading = true;
  bool isConfigLoading = true;
  String currentBookName = '';
  String currentBiblionumber = '';

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
  initState() {
    super.initState();
    _searchFilterController = TextEditingController();
    _libraryController = TextEditingController();
    _searchController = TextEditingController();
    _itemTypeController = TextEditingController();
    _booksCarouselSliderController = CarouselSliderController();
    _libraryServicesController = TextEditingController();

    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final libraries = await LibrariesService.getLibraries();
      isLibrariesLoading = false;
      _librariesFuture = Future.value(libraries);

      if (mounted) {
        Provider.of<GlobalProvider>(
          context,
          listen: false,
        ).setGlobalLibraryEntries(
          libraries.map((library) {
            return DropdownMenuEntry(
              value: library.libraryId,
              label: library.name,
            );
          }).toList(),
        );

        setState(() {
          _libraryEntries = Provider.of<GlobalProvider>(
            context,
            listen: false,
          ).globalLibraryEntries;
        });
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
    }

    try {
      final itemTypes = await ItemTypesService.getItemTypes();
      isItemTypesLoading = false;

      if (mounted) {
        Provider.of<GlobalProvider>(
          context,
          listen: false,
        ).setGlobalItemTypeEntries(
          itemTypes.map((itemType) {
            return DropdownMenuEntry(
              value: itemType.itemTypeId,
              label: itemType.description,
            );
          }).toList(),
        );
      }

      setState(() {
        _itemTypeEntries = Provider.of<GlobalProvider>(
          context, listen: false
        ).globalItemTypeEntries;
      });
    } catch (e) {
      debugPrint('Error fetching item types: $e');
    }

    try {
      final config = await ConfigService.getConfig();
      isConfigLoading = false;

      if (mounted) {
        Provider.of<GlobalProvider>(
          context,
          listen: false,
        ).setGlobalEnabledLibrariesEntries(config.bookFinderLibraries.toSet());
      }

      setState(() {
        _librariesServices = config.librariesServices;
        _bookSelections = config.bookSelections;
        currentBookName = _bookSelections[0].bookName;
        currentBiblionumber = _bookSelections[0].biblionumber;
        isSelectionsEnabled = config.selectionsSectionState;
        _enabledHomeLibrariesEntries = config.enabledLibrariesHome.map((library) {
          return DropdownMenuEntry(
            value: library.libraryCode,
            label: library.libraryCode,
          );
        }).toList();
      });
    } catch (e) {
      debugPrint('Error fetching config: $e');
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
    if (_searchController.text.isEmpty ||
        _searchController.text.trim().isEmpty ||
        _searchController.text.trim().length < 2) {
      return;
    }

    ControllersData controllersData = ControllersData(
      filterController: _searchFilterController,
      libraryController: _libraryController,
      libraryEntries: _libraryEntries,
      itemTypeController: _itemTypeController,
      itemTypeEntries: _itemTypeEntries,
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
