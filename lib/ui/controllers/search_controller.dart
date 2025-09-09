part of '../views/search_view.dart';

abstract class SearchController extends State<SearchView> {
  late TextEditingController _controllerBiblioteca;
  late TextEditingController _controllerTipoBusqueda;
  late TextEditingController _controllerBusqueda;
  late (String, String, String) searchQuery;
  late List<String> _titulos = [];

  @override
  void initState() {
    super.initState();
    _controllerTipoBusqueda = TextEditingController();
    _controllerBiblioteca = TextEditingController();
    _controllerBusqueda = TextEditingController();
    // can get the arguments before so its faster
  }

  @override
  void dispose() {
    _controllerBusqueda.dispose();
    super.dispose();
  }

  void clearText() {
    _controllerBusqueda.clear();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is (String, String, String)) {
      searchQuery = args;
    } else {
      searchQuery = ('', '', '');
    }
    fetchXml();
    _controllerTipoBusqueda.text = searchQuery.$1;
    _controllerBiblioteca.text = searchQuery.$2;
    _controllerBusqueda.text = searchQuery.$3;
  }

  Future<void> fetchXml() async {
    final url = Uri.parse('placeholder');
    final response = await http.get(url);

    print(url);

    if (response.statusCode == 200) {
    final document = xml.XmlDocument.parse(response.body);

    const marcNamespace = "http://www.loc.gov/MARC21/slim";

    final records = document.findAllElements(
      "recordData",
      namespace: "http://www.loc.gov/zing/srw/",
    );

    for (var recordData in records) {
      final record = recordData.findElements("record", namespace: marcNamespace).firstOrNull;
      
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

      final title = "${subfieldA?.innerText ?? ''} ${subfieldB?.innerText ?? ''} ${subfieldC?.innerText ?? ''}";
      _titulos.add(utf8.decode(title.trim().codeUnits));

    }
      setState(() {}); // Update UI after adding each title
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
