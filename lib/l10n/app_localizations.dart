import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// home view top bar title
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Filter by dropdown hint
  ///
  /// In en, this message translates to:
  /// **'Search by'**
  String get searchBy;

  /// Library selection dropdown hint
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get library;

  /// Search field hint
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Our selections section title
  ///
  /// In en, this message translates to:
  /// **'Our Selections'**
  String get ourSelections;

  /// News section title
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get news;

  /// Search history section title
  ///
  /// In en, this message translates to:
  /// **'Search History'**
  String get searchHistory;

  /// Language selection hint
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Library directory section title
  ///
  /// In en, this message translates to:
  /// **'Library Directory'**
  String get libraryDirectory;

  /// Electronic resources section title
  ///
  /// In en, this message translates to:
  /// **'Electronic Resources'**
  String get electronicResources;

  /// Frequently asked questions section title
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get faq;

  /// Privacy notice section title
  ///
  /// In en, this message translates to:
  /// **'Privacy Notice'**
  String get privacyNotice;

  /// Search results view top bar title
  ///
  /// In en, this message translates to:
  /// **'Search Results'**
  String get searchTitle;

  /// Title entry in search by dropdown
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get titleEntry;

  /// Author entry in search by dropdown
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get authorEntry;

  /// Subject entry in search by dropdown
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get subjectEntry;

  /// ISBN entry in search by dropdown
  ///
  /// In en, this message translates to:
  /// **'ISBN'**
  String get isbnEntry;

  /// ISSN entry in search by dropdown
  ///
  /// In en, this message translates to:
  /// **'ISSN'**
  String get issnEntry;

  /// By author label in book preview
  ///
  /// In en, this message translates to:
  /// **'By'**
  String get byAuthor;

  /// Publishing details label in book preview
  ///
  /// In en, this message translates to:
  /// **'Publishing details'**
  String get publishingDetails;

  /// Availability label in book preview
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get availability;

  /// All libraries entry in library selection dropdown
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allLibraries;

  /// Details title in book view
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get detailsTitle;

  /// Snackbar message shown when the language is changed to Spanish
  ///
  /// In en, this message translates to:
  /// **'Language changed to Spanish'**
  String get languageChanged;

  /// Label for total number of search results
  ///
  /// In en, this message translates to:
  /// **'results'**
  String get totalResults;

  /// Message shown when no search results are found
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResults;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
