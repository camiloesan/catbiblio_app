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
      DropdownMenuEntry(value: 'all', label: AppLocalizations.of(context)!.allLibraries),
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
    fetchXml(queryParams.searchBy, queryParams.library, queryParams.searchQuery);
  }

  Future<void> fetchXml(String filter, String library, String query) async {
    final url = Uri.parse("http://148.226.6.25:9999/biblios?version=1.1&operation=searchRetrieve&query=$filter=$query and koha.homebranch=$library&maximumRecords=10&recordSchema=marcxml");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final document = xml.XmlDocument.parse(response.body);
      const marcNamespace = "http://www.loc.gov/MARC21/slim";
      final records = document.findAllElements(
        "recordData",
        namespace: "http://www.loc.gov/zing/srw/",
      );

      for (var recordData in records) {
        BookPreview book = BookPreview(
          title: '',
          author: '',
          coverUrl: '',
          biblioNumber: '',
          publishingDetails: '',
        );

        final record = recordData
            .findElements("record", namespace: marcNamespace)
            .firstOrNull;

        if (record == null) continue; // Skip if record not found

        final datafield245 = record
            .findElements("datafield", namespace: marcNamespace)
            .firstWhereOrNull((df) => df.getAttribute("tag") == "245");

        if (datafield245 == null) continue; // Skip if datafield245 not found
        
        final datafield100 = record
            .findElements("datafield", namespace: marcNamespace)
            .firstWhereOrNull((df) => df.getAttribute("tag") == "100");
        if (datafield100 != null) {
          var a100 = datafield100
              .findElements("subfield", namespace: marcNamespace)
              .firstWhereOrNull((sf) => sf.getAttribute("code") == "a");
          if (a100 != null) {
            book.author = utf8.decode(a100.innerText.trim().codeUnits);
          }
        }

        final datafield999 = record
            .findElements("datafield", namespace: marcNamespace)
            .firstWhereOrNull((df) => df.getAttribute("tag") == "999");
        if (datafield999 != null) {
          var a999 = datafield999
              .findElements("subfield", namespace: marcNamespace)
              .firstWhereOrNull((sf) => sf.getAttribute("code") == "a");
          if (a999 != null) {
            book.biblioNumber = utf8.decode(a999.innerText.trim().codeUnits);
          }
        }

        final subfieldA = datafield245
            .findElements("subfield", namespace: marcNamespace)
            .firstWhereOrNull((sf) => sf.getAttribute("code") == "a");

        final subfieldB = datafield245
            .findElements("subfield", namespace: marcNamespace)
            .firstWhereOrNull((sf) => sf.getAttribute("code") == "b");

        final subfieldC = datafield245
            .findElements("subfield", namespace: marcNamespace)
            .firstWhereOrNull((sf) => sf.getAttribute("code") == "c");
        final title =
            "${subfieldA?.innerText ?? ''} ${subfieldB?.innerText ?? ''} ${subfieldC?.innerText ?? ''}";
        book.title = utf8.decode(title.trim().codeUnits);

        final datafield260 = record
            .findElements("datafield", namespace: marcNamespace)
            .firstWhereOrNull((df) => df.getAttribute("tag") == "260");
        if (datafield260 != null) {
          var a260 = datafield260
              .findElements("subfield", namespace: marcNamespace)
              .firstWhereOrNull((sf) => sf.getAttribute("code") == "a");
          var b260 = datafield260
              .findElements("subfield", namespace: marcNamespace)
              .firstWhereOrNull((sf) => sf.getAttribute("code") == "b");
          var c260 = datafield260
              .findElements("subfield", namespace: marcNamespace)
              .firstWhereOrNull((sf) => sf.getAttribute("code") == "c");
          var publishingDetails =
              "${a260?.innerText ?? ''} ${b260?.innerText ?? ''} ${c260?.innerText ?? ''}";
          book.publishingDetails = utf8.decode(publishingDetails.trim().codeUnits);
        }

        books.add(book);
      }
      setState(() {}); // Update UI after adding the titles
    } else {
      throw Exception("Failed to load XML");
    }
  }

  void onSubmitAction(String cadenaDeBusqueda) {
    if (cadenaDeBusqueda.isNotEmpty) {
      setState(() {
        books.clear(); // Clear previous titles
      });
      fetchXml(queryParams.searchBy, queryParams.library, cadenaDeBusqueda);
    }
  }
}
