import 'package:catbiblio_app/l10n/app_localizations.dart';
import 'package:catbiblio_app/models/query_params.dart';
import 'package:catbiblio_app/ui/views/search_view.dart';
import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:catbiblio_app/classes/aviso.dart';

part '../controllers/home_controller.dart';

const Color primaryColor = Color(0xFF003466);

class HomeView extends StatefulWidget {
  final Function(Locale locale) onLocaleChange;

  const HomeView({super.key, required this.onLocaleChange});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends HomeController {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.home),
        backgroundColor: Colors.transparent,
        actionsPadding: EdgeInsets.only(right: 16.0),
      ),
      drawer: NavigationDrawer(
        children: [
          DrawerHeader(child: Image.asset('assets/images/head.png')),
          ListTile(
            leading: const Icon(Icons.home, color: primaryColor),
            title: Text(AppLocalizations.of(context)!.home),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.history, color: primaryColor),
            title: Text(AppLocalizations.of(context)!.searchHistory),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.language, color: primaryColor),
            title: Text(AppLocalizations.of(context)!.language),
            onTap: () {
              widget.onLocaleChange(
                AppLocalizations.of(context)!.localeName == 'es'
                    ? const Locale('en')
                    : const Locale('es'),
              );
              Navigator.pop(context);
              SnackBar snackBar = SnackBar(
                content: Text(AppLocalizations.of(context)!.languageChanged),
                duration: const Duration(seconds: 2),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.map, color: primaryColor),
            title: Text(AppLocalizations.of(context)!.libraryDirectory),
            trailing: Transform.scale(
              scale: 0.8,
              child: const Icon(Icons.open_in_new),
            ),
            onTap: () => openLink('https://www.uv.mx/dgbuv/#mapa'),
          ),
          ListTile(
            leading: const Icon(Icons.computer, color: primaryColor),
            title: Text(AppLocalizations.of(context)!.electronicResources),
            trailing: Transform.scale(
              scale: 0.8,
              child: const Icon(Icons.open_in_new),
            ),
            onTap: () => openLink('https://www.uv.mx/dgbuv/#descubridor'),
          ),
          ListTile(
            leading: const Icon(Icons.help, color: primaryColor),
            title: Text(AppLocalizations.of(context)!.faq),
            trailing: Transform.scale(
              scale: 0.8,
              child: const Icon(Icons.open_in_new),
            ),
            onTap: () =>
                openLink('https://www.uv.mx/dgbuv/preguntas-frecuentes/'),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip, color: primaryColor),
            title: Text(AppLocalizations.of(context)!.privacyNotice),
            trailing: Transform.scale(
              scale: 0.8,
              child: const Icon(Icons.open_in_new),
            ),
            onTap: () => openLink(
              'https://catbiblio.uv.mx/avisos/aviso-privacidad-integral-sib.pdf',
            ),
          ),
        ],
      ),
      drawerEnableOpenDragGesture: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: SizedBox(
                  height: 56,
                  child: Image.asset('assets/images/head.png'),
                ),
              ),
              DropdownMenu(
                controller: _searchFilterController,
                label: Text(AppLocalizations.of(context)!.searchBy),
                leadingIcon: const Icon(Icons.filter_list, color: primaryColor),
                dropdownMenuEntries: _filterEntries,
                initialSelection: _queryParams.searchBy,
                onSelected: (value) => _queryParams.searchBy = value!,
                width: double.infinity,
                enableFilter: false,
                requestFocusOnTap: false,
              ),
              const SizedBox(height: 8),
              DropdownMenu(
                controller: _libraryController,
                label: Text(AppLocalizations.of(context)!.library),
                leadingIcon: const Icon(
                  Icons.location_city,
                  color: primaryColor,
                ),
                initialSelection: _queryParams.library,
                dropdownMenuEntries: _libraryEntries,
                onSelected: (value) => _queryParams.library = value!,
                enableFilter: false,
                requestFocusOnTap: false,
                width: double.infinity,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _searchController,
                onSubmitted: (value) => onSubmitAction(),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: primaryColor),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                    },
                  ),
                  labelText: AppLocalizations.of(context)!.search,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  AppLocalizations.of(context)!.ourSelections,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  AppLocalizations.of(context)!.news,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              const SizedBox(height: 12),
              FutureBuilder<List<Aviso>>(
                future: futureNews,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 202, // Altura del carrusel + indicadores
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error al cargar avisos: ${snapshot.error}'),
                    );
                  }
                  if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    return buildCarousel(snapshot.data!);
                  }
                  return const Center(
                    child: Text('No hay avisos disponibles.'),
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
