part of '../views/home_view.dart';

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

abstract class HomeController extends State<HomeView> {
  late TextEditingController _controllerBusqueda;
  late Future<List<Aviso>> futureAvisos;
  int _avisosIndex = 0;

  @override
  initState() {
    super.initState();
    _controllerBusqueda = TextEditingController();
    futureAvisos = _obtenerAvisos();
  }

  @override
  void dispose() {
    _controllerBusqueda.dispose();
    super.dispose();
  }

  void clearText() {
    _controllerBusqueda.clear();
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

  Future<List<Aviso>> _obtenerAvisos() async {
    /// https://www.example.com/avisos.json
    final String response = await rootBundle.loadString('assets/avisos.json');
    final List<dynamic> data = json.decode(response);
    return data.map((item) => Aviso.fromJson(item)).toList();
  }

  Future<void> abrirEnlace(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo abrir el enlace: $url')),
        );
      }
    }
  }

  void avisoCambiado(int index, CarouselPageChangedReason reason) {
    setState(() {
      _avisosIndex = index;
    });
  }

  Widget construirCarousel(List<Aviso> avisos) {
    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: avisos.length,
          itemBuilder: (context, index, realIndex) {
            final aviso = avisos[index];
            return GestureDetector(
              onTap: () => abrirEnlace(aviso.enlace),
              child: Stack(
                alignment: Alignment.bottomLeft,
                children: [
                  // Contenedor de la Imagen
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(aviso.imagen),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          options: CarouselOptions(
            //height: 130,
            autoPlay: true,
            enlargeCenterPage: true,
            viewportFraction: 1,
            aspectRatio: 16 / 9,
            onPageChanged: (index, reason) => avisoCambiado(index, reason),
          ),
        ),
        const SizedBox(height: 12),
        // Indicadores dinámicos
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            avisos.length,
            (index) => Container(
              width: 9,
              height: 9,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _avisosIndex == index
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
