import 'dart:collection';
import 'package:flutter/material.dart';

part '../controllers/search_controller.dart';

const Color primaryColor = Color(0xFF003466);

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends SearchController {
  @override
  Widget build(BuildContext context) {
    final (String, String, String) searchQuery = ModalRoute.of(context)!.settings.arguments as (String, String, String);

    return Scaffold(
      appBar: AppBar(
        title: Text('Búsqueda'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0),
        child: Column(
          children: [
            DropdownMenu(
              controller: _controllerTipoBusqueda,
              label: const Text('Buscar por'),
              leadingIcon: const Icon(Icons.filter_list, color: primaryColor),
              dropdownMenuEntries: ColorLabel.entries,
              width: double.infinity,
            ),
            const SizedBox(height: 8),
            DropdownMenu(
              controller: _controllerBiblioteca,
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
            const SizedBox(height: 8),
            Divider(color: Colors.grey),
          ],
        ),
      ),
    );
  }
}