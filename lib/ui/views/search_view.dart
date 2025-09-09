import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'package:collection/collection.dart';

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
    final (String, String, String) searchQuery =
        ModalRoute.of(context)!.settings.arguments as (String, String, String);

    return Scaffold(
      appBar: AppBar(title: Text('Búsqueda')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownMenu(
                controller: _controllerTipoBusqueda,
                label: const Text('Buscar por'),
                leadingIcon: const Icon(Icons.filter_list, color: primaryColor),
                dropdownMenuEntries: const [
                  DropdownMenuEntry(value: 'title', label: 'Título'),
                  DropdownMenuEntry(value: 'author', label: 'Autor'),
                ],
                width: double.infinity,
              ),
              const SizedBox(height: 8),
              DropdownMenu(
                controller: _controllerBiblioteca,
                label: const Text('Biblioteca'),
                leadingIcon: const Icon(
                  Icons.location_city,
                  color: primaryColor,
                ),
                dropdownMenuEntries: const [
                  DropdownMenuEntry(
                    value: 'homebranch',
                    label: 'Todas las bibliotecas',
                  ),
                  DropdownMenuEntry(value: 'USBI-X', label: 'USBI Xalapa'),
                ],
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
              const SizedBox(height: 8),
              ..._titulos.map(
                (title) {
                  return Column(
                    children: [
                      ListTile(
                        onTap: () {},
                        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          'Por: Autor Desconocido \nDisponibilidad: 1 biblioteca \nOtro título: Título relacionado',
                          style: TextStyle(fontWeight: FontWeight.normal),
                        ),
                        contentPadding: EdgeInsets.all(0),
                        minVerticalPadding: 0,
                      ),
                      Divider(color: Colors.grey),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
