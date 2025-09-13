part of '../views/search_view.dart';

abstract class SearchController extends State<SearchView> {
  //  late TextEditingController _controllerBiblioteca;
  //  late TextEditingController _controllerTipoBusqueda;
  String? _selectedTipoBusqueda;
  String? _selectedBiblioteca;
  late TextEditingController _controllerBusqueda;
  late QueryParams searchQuery;
  late List<String> _titulos = [];

  List<DropdownMenuEntry<String>> get entradasTipoBusqueda {
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
    //_controllerTipoBusqueda = TextEditingController();
    //_controllerBiblioteca = TextEditingController();
    _controllerBusqueda = TextEditingController();
    // can get the arguments before so its faster
  }

  @override
  void dispose() {
    //_controllerBusqueda.dispose();
    super.dispose();
  }

  void clearText() {
    //_controllerBusqueda.clear();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    //args.runtimeType;

    if (args is QueryParams) {
      searchQuery = args;
      print("Received QueryParams: " + searchQuery.toString()); // Debug print
      fetchXml();
      // _controllerBiblioteca.text = searchQuery.biblioteca;
      // _controllerTipoBusqueda.text = searchQuery.tipoBusqueda;
      // _controllerBusqueda.text = searchQuery.cadenaDeBusqueda;
    } else {
      // searchQuery = QueryParams(bibliotecaController: TextEditingController(), tipoBusquedaController: TextEditingController(), cadenaDeBusqueda: '');
    }
    // no sirve
    // _controllerTipoBusqueda = searchQuery.tipoBusqueda;
    // _controllerBiblioteca = searchQuery.biblioteca;
    //_controllerBusqueda.text = searchQuery.cadenaDeBusqueda;
    //fetchXml();
  }

  Future<void> fetchXml() async {
    // construir con el valor del controlador
    final url = Uri.parse(
      //http://XXX.XXX.X.XX:XXXX/biblios?version=1.1&operation=searchRetrieve&query=title=derecho and koha.homebranch=USBI-X&maximumRecords=10&recordSchema=marcxml
      'http://XXX.XXX.X.XX:XXXX/biblios?version=1.1&operation=searchRetrieve&query=${searchQuery.tipoBusqueda}=${searchQuery.cadenaDeBusqueda} and koha.homebranch=${searchQuery.biblioteca}&maximumRecords=10&recordSchema=marcxml',
    );
    print(searchQuery.toString()); // Debug print
    final response = await http.get(url);

    print("Fetching data from: " + url.toString()); // Debug print

    if (response.statusCode == 200) {
      final document = xml.XmlDocument.parse(response.body);

      const marcNamespace = "http://www.loc.gov/MARC21/slim";

      final records = document.findAllElements(
        "recordData",
        namespace: "http://www.loc.gov/zing/srw/",
      );

      for (var recordData in records) {
        final record = recordData
            .findElements("record", namespace: marcNamespace)
            .firstOrNull;

        if (record == null) continue; // Skip if record not found

        final datafield245 = record
            .findElements("datafield", namespace: marcNamespace)
            .firstWhereOrNull((df) => df.getAttribute("tag") == "245");

        if (datafield245 == null) continue; // Skip if datafield245 not found

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
        _titulos.add(utf8.decode(title.trim().codeUnits));
      }
      setState(() {}); // Update UI after adding the titles
    } else {
      throw Exception("Failed to load XML");
    }
  }

  void onSubmitAction(String cadenaDeBusqueda) {
    // if (cadenaDeBusqueda.isNotEmpty) {
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //       builder: (context) => const SearchView(),
    //       settings: RouteSettings(arguments: cadenaDeBusqueda),
    //     ),
    //   );
    // }
  }
}
