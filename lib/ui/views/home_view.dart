import 'package:carousel_slider/carousel_slider.dart';
import 'package:catbiblio_app/l10n/app_localizations.dart';
import 'package:catbiblio_app/models/config.dart';
import 'package:catbiblio_app/models/controllers_data.dart';
import 'package:catbiblio_app/models/global_provider.dart';
import 'package:catbiblio_app/models/library.dart';
import 'package:catbiblio_app/models/query_params.dart';
import 'package:catbiblio_app/services/book_selections.dart';
import 'package:catbiblio_app/services/config.dart';
import 'package:catbiblio_app/services/item_types.dart';
import 'package:catbiblio_app/services/libraries.dart';
import 'package:catbiblio_app/ui/views/book_view.dart';
import 'package:catbiblio_app/ui/views/search_view.dart';
import 'package:catbiblio_app/ui/views/libraries_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:url_launcher/url_launcher.dart';

part '../controllers/home_controller.dart';

const Color primaryColor = Color.fromARGB(255, 24, 82, 157);

class HomeView extends StatefulWidget {
  final Function(Locale locale) onLocaleChange;

  const HomeView({super.key, required this.onLocaleChange});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends HomeController {
  @override
  Widget build(BuildContext context) {
    final libraryEntriesPlusAll = [
      DropdownMenuEntry(
        value: 'all',
        label: AppLocalizations.of(context)!.allLibraries,
      ),
      ..._libraryEntries,
    ];
    final itemTypeEntriesPlusAll = [
      DropdownMenuEntry(
        value: 'all',
        label: AppLocalizations.of(context)!.allItemTypes,
      ),
      ..._itemTypeEntries,
    ];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Image(
          image: const AssetImage('assets/images/head.png'),
          height: 40,
        ),
      ),
      drawer: AppNavigationDrawer(
        onLocaleChange: widget.onLocaleChange,
        openLink: openLink,
        isLibrariesLoading: isLibrariesLoading,
        librariesFuture: _librariesFuture,
      ),
      drawerEnableOpenDragGesture: true,
      body: CustomScrollView(
        slivers: [
          // search section
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width < screenSizeLimit
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
                        bottom: 8.0,
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
                                return DropdownItemTypesWidget(
                                  itemTypeController: _itemTypeController,
                                  itemTypeEntries: itemTypeEntriesPlusAll,
                                  queryParams: _queryParams,
                                  maxWidth: constraints.maxWidth,
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          Skeletonizer(
                            enabled: isLibrariesLoading,
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return DropdownLibrariesWidget(
                                  libraryController: _libraryController,
                                  libraryEntries: libraryEntriesPlusAll,
                                  queryParams: _queryParams,
                                  maxWidth: constraints.maxWidth,
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              return DropdownFilters(
                                searchFilterController: _searchFilterController,
                                filterEntries: _filterEntries,
                                queryParams: _queryParams,
                                maxWidth: constraints.maxWidth,
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFieldSearchWidget(
                            searchController: _searchController,
                            onSubmitted: (value) => onSubmitAction(),
                            clearSearchController: () =>
                                clearSearchController(),
                          ),
                          // Divider(),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                    SizedBox(height: 4.0),
                  ],
                ),
              ),
            ),
          ),
          if (isConfigLoading == false &&
              isConfigError == false &&
              _bookSelections.isNotEmpty)
            // Book selections section
            SliverToBoxAdapter(
              child: Container(
                color: primaryColor,
                child: Column(
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth:
                            MediaQuery.of(context).size.width < screenSizeLimit
                            ? MediaQuery.of(context).size.width
                            : (MediaQuery.of(context).size.width / 3) * 2,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 16.0,
                          left: 16.0,
                          right: 16.0,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            AppLocalizations.of(context)!.bookSelections,
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    BooksCarouselSliderWidget(
                      screenSizeLimit: screenSizeLimit,
                      onPressedCallback: (index) {
                        setState(() {
                          currentBiblionumber =
                              _bookSelections[index].biblionumber;
                        });
                      },
                      booksCarouselSliderController:
                          _booksCarouselSliderController,
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
                              if (kIsWeb) {
                                context.go(
                                  '/book-details/${book.biblionumber}',
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
                            child: CarouselBookCard(
                              title: book.name,
                              imageUrl:
                                  'https://catbiblio.uv.mx/cgi-bin/koha/opac-image.pl?biblionumber=${book.biblionumber}',
                              fit: BoxFit.cover,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 16.0),
                  ],
                ),
              ),
            ),
          if (isConfigLoading)
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(color: primaryColor),
                ),
              ),
            ),
          if (isConfigError && !isConfigLoading)
            // Book selections error message
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text(
                        AppLocalizations.of(context)!.couldntLoadBookSelections,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Divider(),
                ],
              ),
            ),
          if (isConfigLoading == false && isConfigError == false)
            // Library services section
            SliverToBoxAdapter(
              child: Column(
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth:
                          MediaQuery.of(context).size.width < screenSizeLimit
                          ? MediaQuery.of(context).size.width
                          : (MediaQuery.of(context).size.width / 3) * 2,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              AppLocalizations.of(context)!.libraryServices,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.start,
                            ),
                          ),
                          LayoutBuilder(
                            builder: (context, constraints) =>
                                DropdownLibrariesServicesWidget(
                                  libraryServicesController:
                                      _libraryServicesController,
                                  enabledHomeLibrariesEntries:
                                      _enabledHomeLibrariesEntries,
                                  maxWidth: constraints.maxWidth,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ServicesCarouselSliderWidget(
                    servicesCarouselSliderController:
                        _servicesCarouselSliderController,
                    items: [
                      for (var service
                          in _librariesServices
                              .firstWhere(
                                (lib) =>
                                    lib.libraryCode == selectedLibraryServices,
                                orElse: () => LibraryServices(
                                  libraryCode: 'USBI-X',
                                  libraryName: 'USBI Xalapa',
                                  services: [],
                                ),
                              )
                              .services)
                        GestureDetector(
                          onTap: () {
                            _servicesCarouselSliderController.animateToPage(
                              _librariesServices
                                  .firstWhere(
                                    (lib) =>
                                        lib.libraryCode ==
                                        selectedLibraryServices,
                                    orElse: () => LibraryServices(
                                      libraryCode: 'USBI-X',
                                      libraryName: 'USBI Xalapa',
                                      services: [],
                                    ),
                                  )
                                  .services
                                  .indexOf(service),
                            );
                          },
                          child: CarouselServiceCard(
                            title: service.name,
                            imageUrl: service.imageUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 32.0),
                ],
              ),
            ),
          if (isConfigError && !isConfigLoading)
            // Library services error message
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    AppLocalizations.of(
                      context,
                    )!.couldntLoadHomeLibrariesServices,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class AppNavigationDrawer extends StatelessWidget {
  const AppNavigationDrawer({
    super.key,
    required this.onLocaleChange,
    required this.openLink,
    required this.isLibrariesLoading,
    required this.librariesFuture,
  });

  final ValueChanged<Locale> onLocaleChange;
  final Future<void> Function(String url) openLink;
  final bool isLibrariesLoading;
  final Future<List<Library>> librariesFuture;

  @override
  Widget build(BuildContext context) {
    return NavigationDrawer(
      children: [
        DrawerHeader(child: Image.asset('assets/images/head.png')),
        ListTile(
          leading: const Icon(Icons.map, color: primaryColor),
          title: Text(AppLocalizations.of(context)!.libraryDirectory),
          enabled: !isLibrariesLoading,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LibrariesView(libraries: librariesFuture),
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
        const Divider(),
        ListTile(
          leading: const Icon(Icons.language, color: primaryColor),
          title: Text(AppLocalizations.of(context)!.language),
          onTap: () {
            onLocaleChange(
              AppLocalizations.of(context)!.localeName == 'es'
                  ? const Locale('en')
                  : const Locale('es'),
            );
            Navigator.pop(context);
            Future.delayed(Duration.zero, () {
              if (context.mounted) {
                SnackBar snackBar = SnackBar(
                  content: Text(AppLocalizations.of(context)!.languageChanged),
                  duration: const Duration(seconds: 2),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
            });
          },
        ),
        ListTile(
          leading: const Icon(Icons.info, color: primaryColor),
          title: Text(AppLocalizations.of(context)!.about),
          onTap: () {
            showAboutDialog(
              context: context,
              applicationName: 'Catálogo Bibliotecario UV',
              applicationVersion: '1.0.0',
              applicationLegalese: '© 2025 Sistema Integral Bibliotecario UV',
            );
          },
        ),
      ],
    );
  }
}

class DropdownLibrariesServicesWidget extends StatelessWidget {
  const DropdownLibrariesServicesWidget({
    super.key,
    required TextEditingController libraryServicesController,
    required List<DropdownMenuEntry<String>> enabledHomeLibrariesEntries,
    required double maxWidth,
  }) : _libraryServicesController = libraryServicesController,
       _enabledHomeLibrariesEntries = enabledHomeLibrariesEntries,
       _maxWidth = maxWidth;

  final TextEditingController _libraryServicesController;
  final List<DropdownMenuEntry<String>> _enabledHomeLibrariesEntries;
  final double _maxWidth;

  @override
  Widget build(BuildContext context) {
    return DropdownMenu(
      width: _maxWidth,
      controller: _libraryServicesController,
      inputDecorationTheme: InputDecorationTheme(border: InputBorder.none),
      dropdownMenuEntries: _enabledHomeLibrariesEntries,
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

class TextFieldSearchWidget extends StatelessWidget {
  const TextFieldSearchWidget({
    super.key,
    required TextEditingController searchController,
    required Function(String) onSubmitted,
    required VoidCallback clearSearchController,
  }) : _searchController = searchController,
       _onSubmitted = onSubmitted,
       _clearSearchController = clearSearchController;

  final TextEditingController _searchController;
  final Function(String) _onSubmitted;
  final VoidCallback _clearSearchController;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _searchController,
      onSubmitted: (value) => _onSubmitted(value),
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.search, color: primaryColor),
        suffixIcon: IconButton(
          icon: Icon(Icons.clear),
          onPressed: () => _clearSearchController(),
        ),
        labelText: AppLocalizations.of(context)!.search,
        border: OutlineInputBorder(),
      ),
    );
  }
}

class DropdownLibrariesWidget extends StatelessWidget {
  const DropdownLibrariesWidget({
    super.key,
    required TextEditingController libraryController,
    required List<DropdownMenuEntry<String>> libraryEntries,
    required QueryParams queryParams,
    required double maxWidth,
  }) : _libraryController = libraryController,
       _libraryEntries = libraryEntries,
       _queryParams = queryParams,
       _maxWidth = maxWidth;
  final TextEditingController _libraryController;
  final List<DropdownMenuEntry<String>> _libraryEntries;
  final QueryParams _queryParams;
  final double _maxWidth;
  @override
  Widget build(BuildContext context) {
    return DropdownMenu(
      controller: _libraryController,
      label: Text(AppLocalizations.of(context)!.library),
      enableSearch: true,
      menuHeight: 300,
      leadingIcon: const Icon(Icons.location_city, color: primaryColor),
      initialSelection: _queryParams.library,
      width: _maxWidth,
      dropdownMenuEntries: _libraryEntries,
      onSelected: (value) {
        _queryParams.library = value!;
      },
    );
  }
}

class DropdownItemTypesWidget extends StatelessWidget {
  const DropdownItemTypesWidget({
    super.key,
    required TextEditingController itemTypeController,
    required List<DropdownMenuEntry<String>> itemTypeEntries,
    required QueryParams queryParams,
    required double maxWidth,
  }) : _itemTypeController = itemTypeController,
       _itemTypeEntries = itemTypeEntries,
       _queryParams = queryParams,
       _maxWidth = maxWidth;
  final TextEditingController _itemTypeController;
  final List<DropdownMenuEntry<String>> _itemTypeEntries;
  final QueryParams _queryParams;
  final double _maxWidth;
  @override
  Widget build(BuildContext context) {
    return DropdownMenu(
      controller: _itemTypeController,
      label: Text(AppLocalizations.of(context)!.itemType),
      enableSearch: true,
      menuHeight: 300,
      leadingIcon: const Icon(Icons.category, color: primaryColor),
      initialSelection: _queryParams.itemType,
      dropdownMenuEntries: _itemTypeEntries,
      width: _maxWidth,
      onSelected: (value) {
        _queryParams.itemType = value!;
      },
    );
  }
}

class CarouselBookCard extends StatelessWidget {
  const CarouselBookCard({
    super.key,
    required String title,
    required String imageUrl,
    required BoxFit fit,
  }) : _title = title,
       _imageUrl = imageUrl,
       _fit = fit;

  final String _title;
  final String _imageUrl;
  final BoxFit _fit;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color.fromARGB(255, 0, 153, 50),
      margin: EdgeInsets.only(bottom: 32.0, left: 4.0, right: 4.0, top: 16.0),
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
              child: CachedNetworkImage(
                imageUrl: _imageUrl,
                fit: _fit,
                width: double.infinity,
                placeholder: (context, url) =>
                    Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => const Center(
                  child: Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _title,
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
}

class BooksCarouselSliderWidget extends StatelessWidget {
  const BooksCarouselSliderWidget({
    super.key,
    required CarouselSliderController booksCarouselSliderController,
    required List<Widget> items,
    required int screenSizeLimit,
    required this.onPressedCallback,
  }) : _booksCarouselSliderController = booksCarouselSliderController,
       _items = items,
       _screenSizeLimit = screenSizeLimit;

  final CarouselSliderController _booksCarouselSliderController;
  final List<Widget> _items;
  final int _screenSizeLimit;
  final Function(int) onPressedCallback;

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      items: _items,
      carouselController: _booksCarouselSliderController,
      options: CarouselOptions(
        onPageChanged: (index, reason) {
          onPressedCallback(index);
        },
        scrollPhysics: kIsWeb
            ? NeverScrollableScrollPhysics()
            : AlwaysScrollableScrollPhysics(),
        disableCenter: true,
        height: 400.0,
        enlargeCenterPage: true,
        autoPlay: true,
        enableInfiniteScroll: true,
        autoPlayInterval: const Duration(seconds: 6),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        autoPlayCurve: Curves.fastOutSlowIn,
        enlargeFactor: 0.3,
        aspectRatio: 2 / 4,
        viewportFraction: MediaQuery.of(context).size.width < _screenSizeLimit
            ? 0.60
            : 0.20,
      ),
    );
  }
}

class CarouselServiceCard extends StatelessWidget {
  const CarouselServiceCard({
    super.key,
    required String title,
    required String imageUrl,
    required BoxFit fit,
  }) : _title = title,
       _imageUrl = imageUrl,
       _fit = fit;

  final String _title;
  final String _imageUrl;
  final BoxFit _fit;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: primaryColor,
      margin: EdgeInsets.only(left: 4.0, right: 4.0, bottom: 32.0, top: 8.0),
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
              child: CachedNetworkImage(
                imageUrl: _imageUrl,
                fit: _fit,
                width: double.infinity,
                placeholder: (context, url) =>
                    Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => const Center(
                  child: Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _title,
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
}

class ServicesCarouselSliderWidget extends StatelessWidget {
  const ServicesCarouselSliderWidget({
    super.key,
    required CarouselSliderController servicesCarouselSliderController,
    required List<Widget> items,
  }) : _servicesCarouselSliderController = servicesCarouselSliderController,
       _items = items;

  final CarouselSliderController _servicesCarouselSliderController;
  final List<Widget> _items;

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      items: _items,
      carouselController: _servicesCarouselSliderController,
      options: CarouselOptions(
        height: 500.0,
        enlargeCenterPage: true,
        scrollPhysics: kIsWeb
            ? NeverScrollableScrollPhysics()
            : AlwaysScrollableScrollPhysics(),
        autoPlay: true,
        enableInfiniteScroll: true,
        autoPlayInterval: const Duration(seconds: 6),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        autoPlayCurve: Curves.fastOutSlowIn,
        aspectRatio: 16 / 9,
        viewportFraction: 0.8,
      ),
    );
  }
}
