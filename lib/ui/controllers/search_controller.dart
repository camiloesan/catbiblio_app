part of '../views/search_view.dart';

abstract class SearchController extends State<SearchView> {
  late TextEditingController _controllerBiblioteca;
  late TextEditingController _controllerTipoBusqueda;
  late TextEditingController _controllerBusqueda;
  late (String, String, String) searchQuery;

  @override
  void initState() {
    super.initState();
    _controllerTipoBusqueda = TextEditingController();
    _controllerBiblioteca = TextEditingController();
    _controllerBusqueda = TextEditingController();
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
    _controllerTipoBusqueda.text = searchQuery.$1;
    _controllerBiblioteca.text = searchQuery.$2;
    _controllerBusqueda.text = searchQuery.$3;
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