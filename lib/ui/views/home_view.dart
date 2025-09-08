import 'dart:collection';

import 'package:flutter/material.dart';

part '../controllers/home_controller.dart';

const Color primaryColor = Color(0xFF003466);

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
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
            trailing: Transform.scale(scale: 0.8, child: const Icon(Icons.open_in_new)),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.computer, color: primaryColor),
            title: const Text('Recursos electrónicos'),
            trailing: Transform.scale(scale: 0.8, child: const Icon(Icons.open_in_new)),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.help, color: primaryColor),
            title: const Text('Preguntas frecuentes'),
            trailing: Transform.scale(scale: 0.8, child: const Icon(Icons.open_in_new)),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip, color: primaryColor),
            title: const Text('Aviso de privacidad'),
            trailing: Transform.scale(scale: 0.8, child: const Icon(Icons.open_in_new)),
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
            const SizedBox(height: 16),
            DropdownMenu(
              label: const Text('Biblioteca'),
              leadingIcon: const Icon(Icons.location_city, color: primaryColor),
              dropdownMenuEntries: ColorLabel.entries,
              width: double.infinity,
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: primaryColor),
                suffixIcon: Icon(Icons.clear),
                labelText: 'Buscar',
                // hintText: 'Buscando por título en la USBI Xalapa',
                helperText: 'Buscando por título en la USBI Xalapa',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
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
          ],
        ),
      ),
    );
  }
}
