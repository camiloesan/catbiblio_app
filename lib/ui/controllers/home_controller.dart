part of '../views/home_view.dart';

abstract class HomeController extends State<HomeView> {
  late TextEditingController _searchController;
  late Future<List<Aviso>> futureNews;
  late TextEditingController _searchFilterController;
  late TextEditingController _libraryController;
  final QueryParams _queryParams = QueryParams(
    library: 'all',
    searchBy: 'title',
    searchQuery: '',
    filterController: TextEditingController(),
    libraryController: TextEditingController(),
  );
  int _newsIndex = 0;

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
      DropdownMenuEntry(value: 'all', label: AppLocalizations.of(context)!.allLibraries),
      DropdownMenuEntry(value: 'USBI-X', label: 'USBI Xalapa'),
      DropdownMenuEntry(value: 'USBI-V', label: 'USBI Veracruz'),
    ];
  }

  @override
  initState() {
    super.initState();
    _searchFilterController = TextEditingController();
    _libraryController = TextEditingController();
    _searchController = TextEditingController();
    futureNews = _getNews();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void clearText() {
    _searchController.clear();
  }

  void onSubmitAction(String searchQuery) {
    if (searchQuery.isNotEmpty) {
      _queryParams.filterController = _searchFilterController;
      _queryParams.libraryController = _libraryController;
      _queryParams.searchQuery = searchQuery;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SearchView(),
          settings: RouteSettings(arguments: _queryParams),
        ),
      );
    }
  }

  Future<List<Aviso>> _getNews() async {
    /// https://www.example.com/avisos.json
    final String response = await rootBundle.loadString('assets/avisos.json');
    final List<dynamic> data = json.decode(response);
    return data.map((item) => Aviso.fromJson(item)).toList();
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

  void newChanged(int index, CarouselPageChangedReason reason) {
    setState(() {
      _newsIndex = index;
    });
  }

  Widget buildCarousel(List<Aviso> news) {
    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: news.length,
          itemBuilder: (context, index, realIndex) {
            final aviso = news[index];
            return GestureDetector(
              onTap: () => openLink(aviso.enlace),
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  // Contenedor de la Imagen
                  SizedBox(
                    width: double.infinity,
                    child: Image.network(
                      aviso.imagen,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset('assets/images/aviso.png');
                      },
                    ),
                  ),
                ],
              ),
            );
          },
          options: CarouselOptions(
            autoPlay: true,
            enlargeCenterPage: true,
            viewportFraction: 1,
            aspectRatio: 16 / 6,
            onPageChanged: (index, reason) => newChanged(index, reason),
          ),
        ),
        const SizedBox(height: 12),
        // Indicadores dinámicos
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            news.length,
            (index) => Container(
              width: 9,
              height: 9,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _newsIndex == index
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade400,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
