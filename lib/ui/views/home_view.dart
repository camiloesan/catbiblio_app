import 'package:catbiblio_app/l10n/app_localizations.dart';
import 'package:catbiblio_app/models/controllers_data.dart';
import 'package:catbiblio_app/models/item_type.dart';
import 'package:catbiblio_app/models/library.dart';
import 'package:catbiblio_app/models/query_params.dart';
import 'package:catbiblio_app/services/item_types.dart';
import 'package:catbiblio_app/services/libraries.dart';
import 'package:catbiblio_app/ui/views/search_view.dart';
import 'package:catbiblio_app/ui/views/libraries_view.dart';
import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';

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
        title: Image(
          image: const AssetImage('assets/images/head.png'),
          height: 40,
        ),
      ),
      drawer: navigationDrawer(context),
      drawerEnableOpenDragGesture: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              dropdownItemTypes(context),
              const SizedBox(height: 12),
              DropdownFilters(
                searchFilterController: _searchFilterController,
                filterEntries: _filterEntries,
                queryParams: _queryParams,
              ),
              const SizedBox(height: 12),
              dropdownLibraries(context),
              const SizedBox(height: 12),
              textFieldSearch(context),
            ],
          ),
        ),
      ),
    );
  }

  DropdownMenu<String> dropdownItemTypes(BuildContext context) {
    return DropdownMenu(
              controller: _itemTypeController,
              label: Text(AppLocalizations.of(context)!.itemType),
              enableSearch: true,
              menuHeight: 300,
              leadingIcon: const Icon(Icons.category, color: primaryColor),
              initialSelection: _queryParams.itemType,
              dropdownMenuEntries: [
                DropdownMenuEntry(
                  value: 'all',
                  label: AppLocalizations.of(context)!.allLibraries,
                ),
                ..._itemTypeEntries,
              ],
              onSelected: (value) {
                setState(() {
                  _queryParams.itemType = value!;
                });
              },
              width: double.infinity,
            );
  }

  DropdownMenu<String> dropdownLibraries(BuildContext context) {
    return DropdownMenu(
      controller: _libraryController,
      label: Text(AppLocalizations.of(context)!.library),
      enableSearch: true,
      menuHeight: 300,
      leadingIcon: const Icon(Icons.location_city, color: primaryColor),
      initialSelection: _queryParams.library,
      dropdownMenuEntries: [
        DropdownMenuEntry(
          value: 'all',
          label: AppLocalizations.of(context)!.allLibraries,
        ),
        ..._libraryEntries,
      ],
      onSelected: (value) {
        setState(() {
          _queryParams.library = value!;
        });
      },
      width: double.infinity,
    );
  }

  TextField textFieldSearch(BuildContext context) {
    return TextField(
      controller: _searchController,
      onSubmitted: (value) => onSubmitAction(),
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.search, color: primaryColor),
        suffixIcon: IconButton(
          icon: Icon(Icons.clear),
          onPressed: () => clearSearchController(),
        ),
        labelText: AppLocalizations.of(context)!.search,
        border: OutlineInputBorder(),
      ),
    );
  }

  NavigationDrawer navigationDrawer(BuildContext context) {
    return NavigationDrawer(
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
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LibrariesView(libraries: _librariesFuture),
            ),
          ), // navigate to LibrariesView()
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
    );
  }
}

class DropdownFilters extends StatelessWidget {
  const DropdownFilters({
    super.key,
    required TextEditingController searchFilterController,
    required List<DropdownMenuEntry<String>> filterEntries,
    required QueryParams queryParams,
  }) : _searchFilterController = searchFilterController,
       _filterEntries = filterEntries,
       _queryParams = queryParams;

  final TextEditingController _searchFilterController;
  final List<DropdownMenuEntry<String>> _filterEntries;
  final QueryParams _queryParams;

  @override
  Widget build(BuildContext context) {
    return DropdownMenu(
      controller: _searchFilterController,
      label: Text(AppLocalizations.of(context)!.searchBy),
      leadingIcon: const Icon(Icons.filter_list, color: primaryColor),
      dropdownMenuEntries: _filterEntries,
      initialSelection: _queryParams.searchBy,
      onSelected: (value) => _queryParams.searchBy = value!,
      width: double.infinity,
      enableFilter: false,
      requestFocusOnTap: false,
    );
  }
}
