import 'package:catbiblio_app/l10n/app_localizations.dart';
import 'package:catbiblio_app/models/global_provider.dart';
import 'package:catbiblio_app/ui/views/book_view.dart';
import 'package:catbiblio_app/ui/views/home_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setUrlStrategy(HashUrlStrategy());
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
          path: '/book-details/:biblionumber',
          builder: (BuildContext context, GoRouterState state) {
            final String biblioNumber =
                state.pathParameters['biblionumber'] ?? 'No ID Found';
            return BookView(biblioNumber: biblioNumber);
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
