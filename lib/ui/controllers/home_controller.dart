part of '../views/home_view.dart';

/// controller for home view
abstract class HomeController extends State<HomeView> {
  late TextEditingController _searchController;
  late TextEditingController _searchFilterController;
  late TextEditingController _libraryController;
  late TextEditingController _libraryServicesController;
  late TextEditingController _itemTypeController;
  late Future<List<Library>> _librariesFuture;
  late CarouselSliderController _booksCarouselSliderController;
  late CarouselSliderController _servicesCarouselSliderController;
  late List<DropdownMenuEntry<String>> _libraryEntries = [];
  late List<DropdownMenuEntry<String>> _itemTypeEntries = [];
  late List<DropdownMenuEntry<String>> _enabledHomeLibrariesEntries = [];
  late Map<String, List<LibraryService>> _librariesServices = {};
  late List<BookSelection> _bookSelections = [];
  final QueryParams _queryParams = QueryParams();
  String selectedLibraryServices = 'USBI-X';
  bool isItemTypesLoading = true;
  bool isLibrariesLoading = true;
  bool isLibraryServicesLoading = true;
  bool isBookSelectionsLoading = true;
  bool isLibraryServicesError = false;
  bool isBookSelectionsError = false;
  final int screenSizeLimit = 800;
  String currentBookName = '';
  String currentBiblionumber = '';

  /// list of filter dropdown entries with internationalized labels
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
    _servicesCarouselSliderController = CarouselSliderController();
    _librariesFuture = Future.value([]);

    fetchData();
  }

  /// fetches necessary data for home view
  /// 
  /// Some data is awaited to ensure proper loading sequence
  Future<void> fetchData() async {
    fetchBookSelections();

    await fetchLibraries();

    fetchItemTypes();

    await fetchLibraryServices();

    buildLibraryServicesDropdown();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFilterController.dispose();
    _libraryController.dispose();
    _libraryServicesController.dispose();
    _itemTypeController.dispose();
    _libraryServicesController.dispose();
    super.dispose();
  }

  void clearText() {
    _searchController.clear();
  }

  void changeLocale(Locale locale) {
    widget.onLocaleChange(locale);
    setState(() {
      _itemTypeController.clear();
      _libraryController.clear();
    });
  }

  /// handles search action submission
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
      filterEntries: _filterEntries,
    );
    _queryParams.startRecord = 1;
    _queryParams.searchQuery = _searchController.text;

    navigateToSearchView(controllersData);
  }

  /// builds query parameters and navigates to search view
  void navigateToSearchView(ControllersData controllersData) {
    if (kIsWeb) {
      String queryParameters =
          '?query=${Uri.encodeComponent(_queryParams.searchQuery)}'
          '&libraryid=${Uri.encodeComponent(_queryParams.library)}'
          '&filter=${Uri.encodeComponent(_queryParams.searchBy)}'
          '&itemtype=${Uri.encodeComponent(_queryParams.itemType)}';

      context.go('/search$queryParameters', extra: controllersData);
      return;
    }

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

  /// opens external link in browser
  Future<void> openExternalLink(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo abrir el enlace: $url')),
        );
      }
    }
  }

  /// fetches available libraries
  Future<void> fetchLibraries() async {
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
  }

  /// fetches item types
  Future<void> fetchItemTypes() async {
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
          context,
          listen: false,
        ).globalItemTypeEntries;
      });
    } catch (e) {
      debugPrint('Error fetching item types: $e');
    }
  }

  /// fetches library services
  Future<void> fetchLibraryServices() async {
    try {
      final libraryServices = await LibraryServices.getLibraryCodeServicesMap();
      isLibraryServicesLoading = false;

      setState(() {
        _librariesServices = libraryServices;
      });
    } catch (e) {
      debugPrint('Error fetching config: $e');
      setState(() {
        isLibraryServicesError = true;
      });
    }
  }

  /// fetches book selections for home view carousel
  void fetchBookSelections() async {
    try {
      _bookSelections = await BookSelectionsService.getBookSelections();
      isBookSelectionsLoading = false;
    } catch (e) {
      debugPrint('Error fetching book selections: $e');
      isBookSelectionsError = true;
    }
    currentBiblionumber = _bookSelections.isNotEmpty
        ? _bookSelections[0].biblionumber
        : '';
    currentBookName = _bookSelections.isNotEmpty ? _bookSelections[0].name : '';
  }

  /// builds the library services dropdown based on previously fetched libraries
  void buildLibraryServicesDropdown() {
    _enabledHomeLibrariesEntries = _libraryEntries
        .where((entry) => _librariesServices.containsKey(entry.value))
        .toList();
    _libraryServicesController.text =
        'Unidad de Servicios Bibliotecarios y de Información Xalapa';
  }

  void onSelectLibraryService(String value) {
    setState(() {
      selectedLibraryServices = value;
    });
  }
}
