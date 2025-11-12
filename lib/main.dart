import 'package:catbiblio_app/l10n/app_localizations.dart';
import 'package:catbiblio_app/models/controllers_data.dart';
import 'package:catbiblio_app/models/finder_params.dart';
import 'package:catbiblio_app/models/global_provider.dart';
import 'package:catbiblio_app/models/query_params.dart';
import 'package:catbiblio_app/ui/views/book_view.dart';
import 'package:catbiblio_app/ui/views/finder_view.dart';
import 'package:catbiblio_app/ui/views/home_view.dart';
import 'package:catbiblio_app/ui/views/marc_view.dart';
import 'package:catbiblio_app/ui/views/search_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'url_strategy_nonweb.dart'
    if (dart.library.html) 'url_strategy_web.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureAppUrlStrategy();
  await dotenv.load();
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => GlobalProvider())],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  Locale? _locale;

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = GoRouter(
      initialLocation: '/',
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) {
            return HomeView(onLocaleChange: setLocale);
          },
        ),
        GoRoute(
          path: '/search',
          builder: (BuildContext context, GoRouterState state) {
            String itemtype = state.uri.queryParameters['itemtype'] ?? '';
            String libraryid = state.uri.queryParameters['libraryid'] ?? '';
            String filter = state.uri.queryParameters['filter'] ?? '';
            String query = state.uri.queryParameters['query'] ?? '';

            ControllersData controllersData = ControllersData(
              filterController: TextEditingController(),
              libraryController: TextEditingController(),
              libraryEntries: [],
              itemTypeController: TextEditingController(),
              itemTypeEntries: [],
              filterEntries: [],
            );

            return SearchView(
              controllersData: controllersData,
              queryParams: QueryParams(
                library: libraryid,
                searchBy: filter,
                searchQuery: query,
                itemType: itemtype,
              ),
            );
          },
        ),
        GoRoute(
          path: '/book-details/:biblionumber',
          builder: (BuildContext context, GoRouterState state) {
            final String biblioNumber =
                state.pathParameters['biblionumber'] ?? 'No ID Found';
            return BookView(biblioNumber: biblioNumber);
          },
        ),
        GoRoute(
          path: '/marc-view/:biblionumber',
          builder: (BuildContext context, GoRouterState state) {
            final String biblioNumber =
                state.pathParameters['biblionumber'] ?? 'No ID Found';
            return MarcView(biblioNumber: biblioNumber);
          },
        ),
        GoRoute(
          path: '/finder',
          builder: (BuildContext context, GoRouterState state) {
            String biblionumber =
                state.uri.queryParameters['biblionumber'] ?? '';
            String title = state.uri.queryParameters['title'] ?? '';
            String classification =
                state.uri.queryParameters['classification'] ?? '';
            String collection = state.uri.queryParameters['collection'] ?? '';
            String collectionCode =
                state.uri.queryParameters['collectionCode'] ?? '';
            String holdingLibrary =
                state.uri.queryParameters['holdingLibrary'] ?? '';

            FinderParams finderParams = FinderParams(
              biblioNumber: biblionumber,
              title: title,
              classification: classification,
              collection: collection,
              collectionCode: collectionCode,
              holdingLibrary: holdingLibrary,
            );
            return FinderView(params: finderParams);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Catálogo Bibliotecario UV',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: _locale,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Inter',
        drawerTheme: DrawerThemeData(
          backgroundColor: Colors.white,
          surfaceTintColor: primaryColor,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: primaryColor,
        ),
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
      ),
      routerConfig: _router,
    );
  }
}
