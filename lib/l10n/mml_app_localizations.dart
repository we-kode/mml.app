import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'mml_app_localizations_de.dart';
import 'mml_app_localizations_en.dart';
import 'mml_app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/mml_app_localizations.dart';
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
    Locale('de'),
    Locale('en'),
    Locale('ru')
  ];

  /// No description provided for @appTitle.
  ///
  /// In de, this message translates to:
  /// **'Meine Mediathek'**
  String get appTitle;

  /// No description provided for @badCertificate.
  ///
  /// In de, this message translates to:
  /// **'Es ist ein Zertifikatsfehler aufgetreten!'**
  String get badCertificate;

  /// No description provided for @unknownError.
  ///
  /// In de, this message translates to:
  /// **'Es ist ein unbekannter Fehler aufgetreten!'**
  String get unknownError;

  /// No description provided for @offlineErrorTitle.
  ///
  /// In de, this message translates to:
  /// **'{appTitle} ist nicht erreichbar'**
  String offlineErrorTitle(String appTitle);

  /// No description provided for @offlineError.
  ///
  /// In de, this message translates to:
  /// **'Stellen Sie die Internetverbindung her und versuchen Sie es erneut'**
  String get offlineError;

  /// No description provided for @unexpectedError.
  ///
  /// In de, this message translates to:
  /// **'Es ist ein unerwarteter Fehler aufgetreten: {message}'**
  String unexpectedError(String message);

  /// No description provided for @forbidden.
  ///
  /// In de, this message translates to:
  /// **'Sie haben nicht die notwendigen Rechte, die Aktion auszuführen!'**
  String get forbidden;

  /// No description provided for @done.
  ///
  /// In de, this message translates to:
  /// **'Fertig'**
  String get done;

  /// No description provided for @skip.
  ///
  /// In de, this message translates to:
  /// **'Überspringen'**
  String get skip;

  /// No description provided for @registrationTitle.
  ///
  /// In de, this message translates to:
  /// **'Registrierung'**
  String get registrationTitle;

  /// No description provided for @registrationScan.
  ///
  /// In de, this message translates to:
  /// **'Scannen Sie den QR-Code in der Administration, um Ihr Gerät zu registrieren.'**
  String get registrationScan;

  /// No description provided for @registrationError.
  ///
  /// In de, this message translates to:
  /// **'Ein Fehler ist beim Registrieren aufgetreten. Versuchen Sie es erneut!'**
  String get registrationError;

  /// No description provided for @registrationSuccess.
  ///
  /// In de, this message translates to:
  /// **'Gerät wurde erfolgreich registriert!'**
  String get registrationSuccess;

  /// No description provided for @registrationProgress.
  ///
  /// In de, this message translates to:
  /// **'Gerät wird registriert...'**
  String get registrationProgress;

  /// No description provided for @registrationEnterName.
  ///
  /// In de, this message translates to:
  /// **'Geben Sie Ihren Namen ein, um sich zu registrieren.'**
  String get registrationEnterName;

  /// No description provided for @registrationRSA.
  ///
  /// In de, this message translates to:
  /// **'Sicherheitsschlüssel wird generiert. Das kann einen Augenblick dauern.'**
  String get registrationRSA;

  /// No description provided for @reRegister.
  ///
  /// In de, this message translates to:
  /// **'Ihre Registrierung ist nicht mehr gültig. Registrieren Sie Ihr Gerät erneut!'**
  String get reRegister;

  /// No description provided for @records.
  ///
  /// In de, this message translates to:
  /// **'Aufnahmen'**
  String get records;

  /// No description provided for @settings.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get settings;

  /// No description provided for @playlist.
  ///
  /// In de, this message translates to:
  /// **'Gespeicherte Titel'**
  String get playlist;

  /// No description provided for @next.
  ///
  /// In de, this message translates to:
  /// **'Weiter'**
  String get next;

  /// No description provided for @firstName.
  ///
  /// In de, this message translates to:
  /// **'Vorname'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In de, this message translates to:
  /// **'Nachname'**
  String get lastName;

  /// No description provided for @invalidFirstName.
  ///
  /// In de, this message translates to:
  /// **'Bitte geben Sie einen Vornamen an!'**
  String get invalidFirstName;

  /// No description provided for @invalidLastName.
  ///
  /// In de, this message translates to:
  /// **'Bitte geben Sie einen Nachnamen an!'**
  String get invalidLastName;

  /// No description provided for @notReachable.
  ///
  /// In de, this message translates to:
  /// **'Der Server ist nicht erreichbar! Bitte prüfen Sie Ihre Netzwerkverbindung!'**
  String get notReachable;

  /// No description provided for @changeServerConnection.
  ///
  /// In de, this message translates to:
  /// **'Server-Verbindung ändern'**
  String get changeServerConnection;

  /// No description provided for @removeRegistration.
  ///
  /// In de, this message translates to:
  /// **'Registrierung löschen'**
  String get removeRegistration;

  /// No description provided for @info.
  ///
  /// In de, this message translates to:
  /// **'Info'**
  String get info;

  /// No description provided for @privacyPolicy.
  ///
  /// In de, this message translates to:
  /// **'Datenschutzerklärung'**
  String get privacyPolicy;

  /// No description provided for @legalInformation.
  ///
  /// In de, this message translates to:
  /// **'Impressum'**
  String get legalInformation;

  /// No description provided for @licenses.
  ///
  /// In de, this message translates to:
  /// **'Lizenzen'**
  String get licenses;

  /// No description provided for @updateConnectionSettingsTitle.
  ///
  /// In de, this message translates to:
  /// **'Server-Verbindung ändern'**
  String get updateConnectionSettingsTitle;

  /// No description provided for @updateConnectionSettingsScan.
  ///
  /// In de, this message translates to:
  /// **'Scannen Sie den QR-Code in der Administration, um die Einstellungen zu ändern.'**
  String get updateConnectionSettingsScan;

  /// No description provided for @updateConnectionSettingsError.
  ///
  /// In de, this message translates to:
  /// **'Ein Fehler ist bei der Änderung aufgetreten. Versuchen Sie es erneut!'**
  String get updateConnectionSettingsError;

  /// No description provided for @updateConnectionSettingsSuccess.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen wurden erfolgreich geändert!'**
  String get updateConnectionSettingsSuccess;

  /// No description provided for @updateConnectionSettingsProgress.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen werden geändert...'**
  String get updateConnectionSettingsProgress;

  /// No description provided for @introTitleRegister.
  ///
  /// In de, this message translates to:
  /// **'Registrieren'**
  String get introTitleRegister;

  /// No description provided for @introTextRegister.
  ///
  /// In de, this message translates to:
  /// **'Scannen Sie den QR-Code in der Administration, um Ihr Gerät zu registrieren.'**
  String get introTextRegister;

  /// No description provided for @introTitleRecords.
  ///
  /// In de, this message translates to:
  /// **'Hören'**
  String get introTitleRecords;

  /// No description provided for @introTextRecords.
  ///
  /// In de, this message translates to:
  /// **'Greifen Sie auf verfügbare Audio-Aufnahmen zu, filtern Sie diese nach Belieben und hören Sie diese an.'**
  String get introTextRecords;

  /// No description provided for @introTitlePlaylist.
  ///
  /// In de, this message translates to:
  /// **'Mitnehmen'**
  String get introTitlePlaylist;

  /// No description provided for @introTextPlaylist.
  ///
  /// In de, this message translates to:
  /// **'Fügen Sie Ihre Lieblingsaufnahmen zu offline Playlists hinzu und hören Sie diese auch wenn gerade kein Internet da ist.'**
  String get introTextPlaylist;

  /// No description provided for @unknown.
  ///
  /// In de, this message translates to:
  /// **'Unbekannt'**
  String get unknown;

  /// No description provided for @save.
  ///
  /// In de, this message translates to:
  /// **'Anwenden'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In de, this message translates to:
  /// **'Abbrechen'**
  String get cancel;

  /// No description provided for @noData.
  ///
  /// In de, this message translates to:
  /// **'Keine Datensätze wurden gefunden!'**
  String get noData;

  /// No description provided for @reload.
  ///
  /// In de, this message translates to:
  /// **'Neu laden'**
  String get reload;

  /// No description provided for @date.
  ///
  /// In de, this message translates to:
  /// **'Datum'**
  String get date;

  /// No description provided for @artist.
  ///
  /// In de, this message translates to:
  /// **'Interpret'**
  String get artist;

  /// No description provided for @genre.
  ///
  /// In de, this message translates to:
  /// **'Genre'**
  String get genre;

  /// No description provided for @album.
  ///
  /// In de, this message translates to:
  /// **'Album'**
  String get album;

  /// No description provided for @filter.
  ///
  /// In de, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @add.
  ///
  /// In de, this message translates to:
  /// **'Hinzufügen'**
  String get add;

  /// No description provided for @notFound.
  ///
  /// In de, this message translates to:
  /// **'Der aufgerufene Datensatz wurde nicht gefunden!'**
  String get notFound;

  /// No description provided for @editPlaylist.
  ///
  /// In de, this message translates to:
  /// **'Wiedergabeliste bearbeiten'**
  String get editPlaylist;

  /// No description provided for @addPlaylist.
  ///
  /// In de, this message translates to:
  /// **'Wiedergabeliste hinzufügen'**
  String get addPlaylist;

  /// No description provided for @invalidDisplayName.
  ///
  /// In de, this message translates to:
  /// **'Bitte geben Sie einen Namen an!'**
  String get invalidDisplayName;

  /// No description provided for @playlistUniqueConstraintFailed.
  ///
  /// In de, this message translates to:
  /// **'Wiedergabeliste ist bereits vorhanden.'**
  String get playlistUniqueConstraintFailed;

  /// No description provided for @remove.
  ///
  /// In de, this message translates to:
  /// **'Löschen'**
  String get remove;

  /// No description provided for @yes.
  ///
  /// In de, this message translates to:
  /// **'Ja'**
  String get yes;

  /// No description provided for @deleteConfirmation.
  ///
  /// In de, this message translates to:
  /// **'Möchten Sie tatsächlich die gewählten Datensätze löschen?'**
  String get deleteConfirmation;

  /// No description provided for @download.
  ///
  /// In de, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @fileNotFound.
  ///
  /// In de, this message translates to:
  /// **'Datei konnte nicht gefunden werden. Fügen Sie die Aufnahme erneut zu einer Playlist hinzu.'**
  String get fileNotFound;

  /// No description provided for @downloadError.
  ///
  /// In de, this message translates to:
  /// **'Download fehlgeschlagen. Überprüfen Sie ihre Verbindung und Speicherplatz und versuchen Sie es erneut.'**
  String get downloadError;

  /// No description provided for @back.
  ///
  /// In de, this message translates to:
  /// **'zurück'**
  String get back;

  /// No description provided for @folder.
  ///
  /// In de, this message translates to:
  /// **'Ordner'**
  String get folder;

  /// No description provided for @language.
  ///
  /// In de, this message translates to:
  /// **'Sprache'**
  String get language;

  /// No description provided for @notReachableRecord.
  ///
  /// In de, this message translates to:
  /// **'Die Aufnahme konnte nicht geladen werden! Versuchen Sie es später noch einmal.'**
  String get notReachableRecord;

  /// No description provided for @faq.
  ///
  /// In de, this message translates to:
  /// **'Hilfe'**
  String get faq;

  /// No description provided for @faqAddFavorites.
  ///
  /// In de, this message translates to:
  /// **'Wie speichere ich Aufnahmen?'**
  String get faqAddFavorites;

  /// No description provided for @sendFeedback.
  ///
  /// In de, this message translates to:
  /// **'Feedback senden/Probleme melden'**
  String get sendFeedback;

  /// No description provided for @display.
  ///
  /// In de, this message translates to:
  /// **'Darstellung'**
  String get display;

  /// No description provided for @displayDescription.
  ///
  /// In de, this message translates to:
  /// **'Welche Elemente sollen in der Liste der Aufnahmen angezeigt werden?'**
  String get displayDescription;

  /// No description provided for @showGenre.
  ///
  /// In de, this message translates to:
  /// **'Genre'**
  String get showGenre;

  /// No description provided for @showLanguage.
  ///
  /// In de, this message translates to:
  /// **'Sprache'**
  String get showLanguage;

  /// No description provided for @showTrackNumber.
  ///
  /// In de, this message translates to:
  /// **'Tracknummer'**
  String get showTrackNumber;

  /// No description provided for @faqAddFavoritesDescription.
  ///
  /// In de, this message translates to:
  /// **'Es können mehrere Ordner angelegt werden, wo Aufnahmen abgespeichert werden. Dazu auf das Plus-Symbol in der \'Gespeicherte Titel\' Ansicht unten rechts klicken und einen Namen für den Ordner angeben. Aufnahmen können gespeichert werden durch gedrückt halten auf einer Aufnahme in der Liste. Es erscheint die Möglichkeit mehrere Elemente gleichzeitig auszuwählen. Oben rechts auf den Stern drücken und dann den Ordner auswählen in dem man die Aufnahmen speichern will. Die aktuell abgespielte Aufnahme kann im Player unten rechts gespeichert werden.'**
  String get faqAddFavoritesDescription;

  /// No description provided for @faqRemoveFavorites.
  ///
  /// In de, this message translates to:
  /// **'Wie lösche ich gespeicherte Aufnahmen?'**
  String get faqRemoveFavorites;

  /// No description provided for @faqRemoveFavoritesDescription.
  ///
  /// In de, this message translates to:
  /// **'Um eine oder mehrere gespeicherte Aufnahmen zu entfernen, eine Aufnahme oder den ganzen Ordner in der Liste gedrückt halten. Es erscheint eine Möglichkeit mehrere Elemente auszuwählen. Oben rechts auf den Mülleimersymbol drücken, um die ausgewählten Elemente zu entfernen.'**
  String get faqRemoveFavoritesDescription;

  /// No description provided for @development.
  ///
  /// In de, this message translates to:
  /// **'Entwicklung'**
  String get development;

  /// No description provided for @clearLogs.
  ///
  /// In de, this message translates to:
  /// **'Logs löschen'**
  String get clearLogs;

  /// No description provided for @showLogs.
  ///
  /// In de, this message translates to:
  /// **'Logs anzeigen'**
  String get showLogs;

  /// No description provided for @livestreams.
  ///
  /// In de, this message translates to:
  /// **'Livestreams'**
  String get livestreams;

  /// No description provided for @saveFilters.
  ///
  /// In de, this message translates to:
  /// **'Filter merken'**
  String get saveFilters;

  /// No description provided for @cover.
  ///
  /// In de, this message translates to:
  /// **'Cover'**
  String get cover;

  /// No description provided for @notCompatibleFile.
  ///
  /// In de, this message translates to:
  /// **'Datei konnte nicht gelesen werden. Format fehlerhaft.'**
  String get notCompatibleFile;

  /// No description provided for @notDownloaded.
  ///
  /// In de, this message translates to:
  /// **'Nicht heruntergeladen'**
  String get notDownloaded;

  /// No description provided for @notDownloadedRecords.
  ///
  /// In de, this message translates to:
  /// **'Folgende Aufnahmen sind nicht mehr verfügbar oder Sie haben kein Recht es herunterzuladen.'**
  String get notDownloadedRecords;

  /// No description provided for @overview.
  ///
  /// In de, this message translates to:
  /// **'Übersicht'**
  String get overview;

  /// No description provided for @favorites.
  ///
  /// In de, this message translates to:
  /// **'Favoriten'**
  String get favorites;

  /// No description provided for @livestreamShort.
  ///
  /// In de, this message translates to:
  /// **'Live'**
  String get livestreamShort;

  /// No description provided for @discover.
  ///
  /// In de, this message translates to:
  /// **'Stöbern'**
  String get discover;

  /// No description provided for @artists.
  ///
  /// In de, this message translates to:
  /// **'Interpreten'**
  String get artists;

  /// No description provided for @genres.
  ///
  /// In de, this message translates to:
  /// **'Genres'**
  String get genres;

  /// No description provided for @albums.
  ///
  /// In de, this message translates to:
  /// **'Alben'**
  String get albums;

  /// No description provided for @languages.
  ///
  /// In de, this message translates to:
  /// **'Sprachen'**
  String get languages;

  /// No description provided for @newest.
  ///
  /// In de, this message translates to:
  /// **'Neueste'**
  String get newest;

  /// No description provided for @newestArtists.
  ///
  /// In de, this message translates to:
  /// **'Neueste Interpreten'**
  String get newestArtists;

  /// No description provided for @commonArtists.
  ///
  /// In de, this message translates to:
  /// **'Häufige Interpreten'**
  String get commonArtists;

  /// No description provided for @commonGenres.
  ///
  /// In de, this message translates to:
  /// **'Häufige Genres'**
  String get commonGenres;

  /// No description provided for @shuffle.
  ///
  /// In de, this message translates to:
  /// **'Zufallswiedergabe'**
  String get shuffle;

  /// No description provided for @repeat.
  ///
  /// In de, this message translates to:
  /// **'Wiederholung'**
  String get repeat;

  /// No description provided for @errorAuthenticationExpired.
  ///
  /// In de, this message translates to:
  /// **'Registrieren Sie sich in {appTitle}'**
  String errorAuthenticationExpired(String appTitle);
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
      <String>['de', 'en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
