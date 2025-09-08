part of '../views/search_view.dart';

typedef ColorEntry = DropdownMenuEntry<ColorLabel>;

// DropdownMenuEntry labels and values for the first dropdown menu.
enum ColorLabel {
  blue('Blue', Colors.blue),
  pink('Pink', Colors.pink),
  green('Green', Colors.green),
  yellow('Orange', Colors.orange),
  grey('Grey', Colors.grey);

  const ColorLabel(this.label, this.color);
  final String label;
  final Color color;

  static final List<ColorEntry> entries = UnmodifiableListView<ColorEntry>(
    values.map<ColorEntry>(
      (ColorLabel color) => ColorEntry(
        value: color,
        label: color.label,
        enabled: color.label != 'Grey',
        style: MenuItemButton.styleFrom(foregroundColor: color.color),
      ),
    ),
  );
}

abstract class SearchController extends State<SearchView> {
  late TextEditingController _controllerBusqueda;
  late String searchQuery;

  @override
  void initState() {
    super.initState();
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
    if (args is String) {
      searchQuery = args;
    } else {
      searchQuery = '';
    }
    _controllerBusqueda.text = searchQuery;
  }

  void onSubmitAction(String cadenaDeBusqueda) {
    if (cadenaDeBusqueda.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SearchView(),
          settings: RouteSettings(arguments: cadenaDeBusqueda),
        ),
      );
    }
  }
}