import 'package:carousel_slider/carousel_slider.dart';
import 'package:catbiblio_app/l10n/app_localizations.dart';
import 'package:catbiblio_app/models/config.dart';
import 'package:catbiblio_app/models/controllers_data.dart';
import 'package:catbiblio_app/models/global_provider.dart';
import 'package:catbiblio_app/models/library.dart';
import 'package:catbiblio_app/models/query_params.dart';
import 'package:catbiblio_app/services/config.dart';
import 'package:catbiblio_app/services/item_types.dart';
import 'package:catbiblio_app/services/libraries.dart';
import 'package:catbiblio_app/ui/views/book_view.dart';
import 'package:catbiblio_app/ui/views/search_view.dart';
import 'package:catbiblio_app/ui/views/libraries_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

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
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                  maxWidth: MediaQuery.of(context).size.width < 600
                      ? MediaQuery.of(context).size.width
                      : (MediaQuery.of(context).size.width / 3) * 2,
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 8.0,
                        left: 16.0,
                        right: 16.0,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.searchSectionTitle,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Skeletonizer(
                            enabled: isItemTypesLoading,
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return dropdownItemTypes(
                                  context,
                                  constraints.maxWidth,
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          Skeletonizer(
                            enabled: isLibrariesLoading,
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return dropdownLibraries(
                                  context,
                                  constraints.maxWidth,
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              return DropdownFilters(
                                searchFilterController:
                                    _searchFilterController,
                                filterEntries: _filterEntries,
                                queryParams: _queryParams,
                                maxWidth: constraints.maxWidth,
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          textFieldSearch(context),
                          // Divider(),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                    SizedBox(height: 4.0),
                    if (!isSelectionsEnabled)
                      SizedBox.shrink()
                    else
                      Container(
                        color: primaryUVColor,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                AppLocalizations.of(context)!.bookSelections,
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            _buildBooksCarouselSlider(context),
                            BookNameFooterWidget(
                              currentBookName: currentBookName,
                            ),
                          ],
                        ),
                      ),
      
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16.0, top: 16.0),
                        child: Text(
                          AppLocalizations.of(context)!.libraryServices,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: LayoutBuilder(
                        builder: (context, constraints) =>
                            DropdownLibrariesServicesWidget(
                              libraryServicesController:
                                  _libraryServicesController,
                              libraryEntries: _libraryEntries,
                              enabledHomeLibrariesEntries:
                                  _enabledHomeLibrariesEntries,
                              maxWidth: constraints.maxWidth,
                            ),
                      ),
                    ),
                    _buildServicesCarouselSlider(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  CarouselSlider _buildBooksCarouselSlider(BuildContext context) {
    return CarouselSlider(
      items: [
        for (var book in _bookSelections)
          GestureDetector(
            onTap: () {
              if (currentBiblionumber != book.biblionumber) {
                _booksCarouselSliderController.animateToPage(
                  _bookSelections.indexOf(book),
                );
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      BookView(biblioNumber: book.biblionumber),
                ),
              );
            },
            child: _buildCarouselBooks(
              context,
              color: primaryColor,
              title: "",
              imageUrl:
                  'http://catbiblio.uv.mx/cgi-bin/koha/opac-image.pl?thumbnail=1&biblionumber=${book.biblionumber}',
              fit: BoxFit.fitHeight,
            ),
          ),
      ],
      carouselController: _booksCarouselSliderController,
      options: CarouselOptions(
        onPageChanged: (index, reason) {
          setState(() {
            currentBiblionumber = _bookSelections[index].biblionumber;
            currentBookName = _bookSelections[index].bookName;
          });
        },
        disableCenter: true,
        height: 300.0,
        enlargeCenterPage: true,
        autoPlay: true,
        enableInfiniteScroll: true,
        autoPlayInterval: const Duration(seconds: 6),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        autoPlayCurve: Curves.fastOutSlowIn,
        enlargeFactor: 0.4,
        aspectRatio: 9 / 16,
        viewportFraction: MediaQuery.of(context).size.width < 600 ? 0.5 : 0.25,
      ),
    );
  }

  CarouselSlider _buildServicesCarouselSlider(BuildContext context) {
    return CarouselSlider(
      items: [
        for (var service
            in _librariesServices
                .firstWhere(
                  (lib) => lib.libraryCode == selectedLibraryServices,
                  orElse: () =>
                      LibraryServices(libraryCode: 'USBI-X', services: []),
                )
                .services)
          _buildCarouselServicesCards(
            context,
            color: primaryColor,
            title: service.name,
            imageUrl: service.imageUrl,
            fit: BoxFit.cover,
          ),
      ],
      options: CarouselOptions(
        height: 350.0,
        enlargeCenterPage: true,
        autoPlay: true,
        enableInfiniteScroll: false,
        autoPlayInterval: const Duration(seconds: 6),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        autoPlayCurve: Curves.fastOutSlowIn,
        aspectRatio: 16 / 9,
        viewportFraction: MediaQuery.of(context).size.width < 600 ? 0.8 : 0.6,
      ),
    );
  }

  DropdownMenu<String> dropdownItemTypes(
    BuildContext context,
    double maxWidth,
  ) {
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
      width: maxWidth,
      onSelected: (value) {
        setState(() {
          _queryParams.itemType = value!;
        });
      },
    );
  }

  DropdownMenu<String> dropdownLibraries(
    BuildContext context,
    double maxWidth,
  ) {
    return DropdownMenu(
      controller: _libraryController,
      label: Text(AppLocalizations.of(context)!.library),
      enableSearch: true,
      menuHeight: 300,
      leadingIcon: const Icon(Icons.location_city, color: primaryColor),
      initialSelection: _queryParams.library,
      width: maxWidth,
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
    );
  }

  TextField textFieldSearch(BuildContext context) {
    return TextField(
      controller: _searchController,
      onChanged: (text) {
        if (text.isEmpty || text.trim().isEmpty) {
          setState(() {
            isSearchable = false;
          });
        } else {
          setState(() {
            isSearchable = true;
          });
        }
      },
      onSubmitted: (value) => onSubmitAction(),
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.search, color: primaryColor),
        suffixIcon: isSearchable
            ? IconButton(
                icon: Icon(Icons.clear),
                onPressed: () => clearSearchController(),
              )
            : null,
        labelText: AppLocalizations.of(context)!.search,
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildCarouselServicesCards(
    BuildContext context, {
    required Color color,
    required String title,
    required String imageUrl,
    required BoxFit fit,
  }) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 16.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12.0),
                topRight: Radius.circular(12.0),
              ),
              child: Image.network(
                imageUrl,
                fit: fit,
                loadingBuilder:
                    (
                      BuildContext context,
                      Widget child,
                      ImageChunkEvent? loadingProgress,
                    ) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            ),
          ),
          // Padding adds space around the text.
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarouselBooks(
    BuildContext context, {
    required Color color,
    required String title,
    required String imageUrl,
    required BoxFit fit,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            spreadRadius: 0,
            blurRadius: 24.0,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
        child: Image.network(
          imageUrl,
          fit: fit,
          loadingBuilder:
              (
                BuildContext context,
                Widget child,
                ImageChunkEvent? loadingProgress,
              ) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
          errorBuilder: (context, error, stackTrace) => const Center(
            child: Icon(Icons.error_outline, color: Colors.white, size: 40),
          ),
        ),
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

class BookNameFooterWidget extends StatelessWidget {
  const BookNameFooterWidget({super.key, required this.currentBookName});

  final String currentBookName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        currentBookName,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class DropdownLibrariesServicesWidget extends StatelessWidget {
  const DropdownLibrariesServicesWidget({
    super.key,
    required TextEditingController libraryServicesController,
    required List<DropdownMenuEntry<String>> libraryEntries,
    required List<DropdownMenuEntry<String>> enabledHomeLibrariesEntries,
    required double maxWidth,
  }) : _libraryServicesController = libraryServicesController,
       _libraryEntries = libraryEntries,
       _enabledHomeLibrariesEntries = enabledHomeLibrariesEntries,
       _maxWidth = maxWidth;

  final TextEditingController _libraryServicesController;
  final List<DropdownMenuEntry<String>> _libraryEntries;
  final List<DropdownMenuEntry<String>> _enabledHomeLibrariesEntries;
  final double _maxWidth;

  @override
  Widget build(BuildContext context) {
    return DropdownMenu(
      width: _maxWidth,
      controller: _libraryServicesController,
      inputDecorationTheme: InputDecorationTheme(border: InputBorder.none),
      dropdownMenuEntries: _libraryEntries
          .where(
            (entry) => _enabledHomeLibrariesEntries.any(
              (enabled) => enabled.value == entry.value,
            ),
          )
          .toList(),
      initialSelection: _enabledHomeLibrariesEntries.isNotEmpty
          ? _enabledHomeLibrariesEntries[0].value
          : null,
      enableSearch: false,
      enableFilter: false,
      requestFocusOnTap: false,
    );
  }
}

class DropdownFilters extends StatelessWidget {
  const DropdownFilters({
    super.key,
    required TextEditingController searchFilterController,
    required List<DropdownMenuEntry<String>> filterEntries,
    required QueryParams queryParams,
    required double maxWidth,
  }) : _searchFilterController = searchFilterController,
       _filterEntries = filterEntries,
       _queryParams = queryParams,
       _maxWidth = maxWidth;

  final TextEditingController _searchFilterController;
  final List<DropdownMenuEntry<String>> _filterEntries;
  final QueryParams _queryParams;
  final double _maxWidth;

  @override
  Widget build(BuildContext context) {
    return DropdownMenu(
      controller: _searchFilterController,
      label: Text(AppLocalizations.of(context)!.searchBy),
      leadingIcon: const Icon(Icons.filter_list, color: primaryColor),
      dropdownMenuEntries: _filterEntries,
      initialSelection: _queryParams.searchBy,
      onSelected: (value) => _queryParams.searchBy = value!,
      width: _maxWidth,
      enableFilter: false,
      requestFocusOnTap: false,
    );
  }
}
