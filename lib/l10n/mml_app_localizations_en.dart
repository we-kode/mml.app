// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'mml_app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'My Media Lib';

  @override
  String get badCertificate => 'An certificate error occurred!';

  @override
  String get unknownError => 'An unknown error is occurred!';

  @override
  String offlineErrorTitle(String appTitle) {
    return '$appTitle not reachable';
  }

  @override
  String get offlineError => 'Create a internet connection and retry';

  @override
  String unexpectedError(String message) {
    return 'An unexpected error occurred: $message';
  }

  @override
  String get forbidden =>
      'You have not the necessary rights, to execute this action!';

  @override
  String get done => 'Done';

  @override
  String get skip => 'Skip';

  @override
  String get registrationTitle => 'Registration';

  @override
  String get registrationScan =>
      'To register your device, scan the QR-Code in the administration.';

  @override
  String get registrationError =>
      'An error occurred during registration. Please retry again!';

  @override
  String get registrationSuccess => 'Device has been successfully registered!';

  @override
  String get registrationProgress => 'Device registration is running...';

  @override
  String get registrationEnterName => 'To register, enter your name.';

  @override
  String get registrationRSA =>
      'Security key is generated. This may take a moment.';

  @override
  String get reRegister =>
      'Your registration is not valid any more. Re-Register your device!';

  @override
  String get records => 'Records';

  @override
  String get settings => 'Settings';

  @override
  String get playlist => 'Saved tracks';

  @override
  String get next => 'Next';

  @override
  String get firstName => 'First name';

  @override
  String get lastName => 'Last name';

  @override
  String get invalidFirstName => 'Please enter a first name!';

  @override
  String get invalidLastName => 'Please enter a last name!';

  @override
  String get notReachable =>
      'The server is not reachable! Please check your network connection!';

  @override
  String get changeServerConnection => 'Change server connection';

  @override
  String get removeRegistration => 'Remove registration';

  @override
  String get info => 'Info';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get legalInformation => 'Legal Information';

  @override
  String get licenses => 'Licenses';

  @override
  String get updateConnectionSettingsTitle => 'Change server connection';

  @override
  String get updateConnectionSettingsScan =>
      'To change the settings, scan the QR-Code in the administration.';

  @override
  String get updateConnectionSettingsError =>
      'An error occurred during change. Please retry again!';

  @override
  String get updateConnectionSettingsSuccess =>
      'Settings were successfully changed!';

  @override
  String get updateConnectionSettingsProgress => 'Changing settings...';

  @override
  String get introTitleRegister => 'Register';

  @override
  String get introTextRegister =>
      'Scan the QR code in the administration to register your device.';

  @override
  String get introTitleRecords => 'Listen';

  @override
  String get introTextRecords =>
      'Access available audio recordings, filter them as you like and listen to them.';

  @override
  String get introTitlePlaylist => 'Take with you';

  @override
  String get introTextPlaylist =>
      'Add your favorite recordings to offline playlists and listen to them even if there is no Internet at the moment.';

  @override
  String get unknown => 'Unknown';

  @override
  String get save => 'Apply';

  @override
  String get cancel => 'Cancel';

  @override
  String get noData => 'No records were found!';

  @override
  String get reload => 'Reload';

  @override
  String get date => 'Date';

  @override
  String get artist => 'Artist';

  @override
  String get genre => 'Genre';

  @override
  String get album => 'Album';

  @override
  String get filter => 'Filter';

  @override
  String get add => 'Add';

  @override
  String get notFound => 'The requested record wasn\'t found!';

  @override
  String get editPlaylist => 'Edit playlist';

  @override
  String get addPlaylist => 'Add playlist';

  @override
  String get invalidDisplayName => 'Please enter a name!';

  @override
  String get playlistUniqueConstraintFailed => 'Playlist already exists.';

  @override
  String get remove => 'Remove';

  @override
  String get yes => 'Yes';

  @override
  String get deleteConfirmation =>
      'Are you really want to delete the selected records?';

  @override
  String get download => 'Download';

  @override
  String get fileNotFound =>
      'File could not be found. Add the recording to a playlist again.';

  @override
  String get downloadError =>
      'Download failed. Check your connection and storage space and try again.';

  @override
  String get back => 'back';

  @override
  String get folder => 'Folder';

  @override
  String get language => 'Language';

  @override
  String get notReachableRecord =>
      'The record could not be loaded! Please retry later.';

  @override
  String get faq => 'Help';

  @override
  String get faqAddFavorites => 'How do I save records?';

  @override
  String get sendFeedback => 'Send feedback/Report problem';

  @override
  String get display => 'Display';

  @override
  String get displayDescription =>
      'Which elements should be displayed in the list of records?';

  @override
  String get showGenre => 'Genre';

  @override
  String get showLanguage => 'Language';

  @override
  String get showTrackNumber => 'Track-Number';

  @override
  String get faqAddFavoritesDescription =>
      'Several folders can be created where records are stored. To do this, click on the plus symbol in the \'Saved Titles\' view at the bottom right and specify a name for the folder. Records can be saved by long pressing on a record in the list. The option to select several elements at the same time appears. Press the star in the upper right corner and then select the folder in which you want to save the records. The currently playing record can be saved in the player at the bottom right.';

  @override
  String get faqRemoveFavorites => 'How do I delete saved records?';

  @override
  String get faqRemoveFavoritesDescription =>
      'To remove one or more saved records, press and hold a record or the entire folder in the list. A possibility to select several elements appears. Press the trash can icon at the top right to remove the selected items.';

  @override
  String get development => 'Development';

  @override
  String get clearLogs => 'Clear logs';

  @override
  String get showLogs => 'Show logs';

  @override
  String get livestreams => 'Livestreams';

  @override
  String get saveFilters => 'Save filter';

  @override
  String get cover => 'Cover';

  @override
  String get notCompatibleFile => 'File could not be read. Wrong format.';

  @override
  String get notDownloaded => 'Not downloaded';

  @override
  String get notDownloadedRecords =>
      'The following records are no longer available or you have no right to download them.';

  @override
  String get overview => 'Overview';

  @override
  String get favorites => 'Favorites';

  @override
  String get livestreamShort => 'Live';

  @override
  String get discover => 'Discover';

  @override
  String get artists => 'Artists';

  @override
  String get genres => 'Genres';

  @override
  String get albums => 'Albums';

  @override
  String get languages => 'Languages';

  @override
  String get newest => 'Newest';

  @override
  String get newestArtists => 'Newest artists';

  @override
  String get commonArtists => 'Common artists';

  @override
  String get commonGenres => 'Common genres';

  @override
  String get shuffle => 'Shuffle';

  @override
  String get repeat => 'Repeat';

  @override
  String errorAuthenticationExpired(String appTitle) {
    return 'Register in $appTitle';
  }
}
