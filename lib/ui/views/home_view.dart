import 'dart:collection';
import 'package:catbiblio_app/ui/views/search_view.dart';
import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../classes/aviso.dart';

part '../controllers/home_controller.dart';

const Color primaryColor = Color(0xFF003466);

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewController();
}

class _HomeViewController extends HomeController {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inicio'),
        backgroundColor: Colors.transparent,
        actionsPadding: EdgeInsets.only(right: 16.0),
      ),
      drawer: NavigationDrawer(
        children: [
          DrawerHeader(child: Image.asset('assets/images/head.png')),
          ListTile(
            leading: const Icon(Icons.home, color: primaryColor),
            title: const Text('Inicio'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.history, color: primaryColor),
            title: const Text('Historial de búsqueda'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.language, color: primaryColor),
            title: const Text('Idioma'),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.map, color: primaryColor),
            title: const Text('Directorio de bibliotecas'),
            trailing: Transform.scale(
              scale: 0.8,
              child: const Icon(Icons.open_in_new),
            ),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.computer, color: primaryColor),
            title: const Text('Recursos electrónicos'),
            trailing: Transform.scale(
              scale: 0.8,
              child: const Icon(Icons.open_in_new),
            ),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.help, color: primaryColor),
            title: const Text('Preguntas frecuentes'),
            trailing: Transform.scale(
              scale: 0.8,
              child: const Icon(Icons.open_in_new),
            ),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip, color: primaryColor),
            title: const Text('Aviso de privacidad'),
            trailing: Transform.scale(
              scale: 0.8,
              child: const Icon(Icons.open_in_new),
            ),
            onTap: () {},
          ),
        ],
      ),
      drawerEnableOpenDragGesture: true,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Expanded(
                child: SizedBox(
                  height: 56,
                  child: Image.asset('assets/images/head.png'),
                ),
              ),
            ),
            DropdownMenu(
              label: const Text('Buscar por'),
              leadingIcon: const Icon(Icons.filter_list, color: primaryColor),
              dropdownMenuEntries: ColorLabel.entries,
              width: double.infinity,
            ),
            const SizedBox(height: 8),
            DropdownMenu(
              label: const Text('Biblioteca'),
              leadingIcon: const Icon(Icons.location_city, color: primaryColor),
              dropdownMenuEntries: ColorLabel.entries,
              width: double.infinity,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controllerBusqueda,
              onSubmitted: (value) => onSubmitAction(value),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: primaryColor),
                suffixIcon: Icon(Icons.clear),
                labelText: 'Buscar',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Nuevas adquisiciones",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Avisos",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const SizedBox(height: 10),
            FutureBuilder<List<Aviso>>(
              future: futureAvisos, // Este 'Future' viene del HomeController
              builder: (context, snapshot) {
                // Mientras carga...
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 202, // Altura del carrusel + indicadores
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                // Si hay un error...
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error al cargar avisos: ${snapshot.error}'),
                  );
                }
                // Si hay datos...
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  // Llama al método del controlador para construir el carrusel
                  return construirCarousel(snapshot.data!);
                }
                // Si no hay datos...
                return const Center(child: Text('No hay avisos disponibles.'));
              },
            ),
          ],
        ),
      ),
    );
  }
}
