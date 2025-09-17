import 'dart:convert';

import 'package:catbiblio_app/l10n/app_localizations.dart';
import 'package:catbiblio_app/models/book_preview.dart';
import 'package:catbiblio_app/models/query_params.dart';
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
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.searchTitle)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownMenu(
                controller: _controllerTipoBusqueda,
                label: Text(AppLocalizations.of(context)!.search),
                leadingIcon: const Icon(Icons.filter_list, color: primaryColor),
                dropdownMenuEntries: entradasTipoBusqueda,
                onSelected: (value) => queryParams.searchBy = value!,
                enableFilter: false,
                requestFocusOnTap: false,
                width: double.infinity,
              ),
              const SizedBox(height: 8),
              DropdownMenu(
                controller: _controllerBiblioteca,
                label: Text(AppLocalizations.of(context)!.library),
                leadingIcon: const Icon(
                  Icons.location_city,
                  color: primaryColor,
                ),
                dropdownMenuEntries: const [
                  DropdownMenuEntry(value: '', label: 'Todas las bibliotecas'),
                  DropdownMenuEntry(value: 'USBI-X', label: 'USBI Xalapa'),
                  DropdownMenuEntry(value: 'USBI-V', label: 'USBI Veracruz'),
                ],
                onSelected: (value) => queryParams.library = value!,
                enableFilter: false,
                requestFocusOnTap: false,
                width: double.infinity,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _controllerBusqueda,
                onSubmitted: (value) => onSubmitAction(value),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: primaryColor),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      _controllerBusqueda.clear();
                    },
                  ),
                  labelText: AppLocalizations.of(context)!.search,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              Divider(color: Colors.grey),
              ...books.map(
                (book) {
                  return Column(
                    children: [
                      ListTile(
                        onTap: () {},
                        title: Text(book.title, style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          'Por: ${book.author} \nDisponibilidad: 1 biblioteca \nOtro título: Título relacionado',
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
