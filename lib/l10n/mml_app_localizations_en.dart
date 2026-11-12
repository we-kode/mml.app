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
  String fileTooLarge(int size) {
    return 'File is too large to be imported (max. $size MB).';
  }

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
  String get stop => 'Stop';

  @override
  String errorAuthenticationExpired(String appTitle) {
    return 'Register in $appTitle';
  }

  @override
  String get cacheSettings => 'Memory management';

  @override
  String get cacheRemove => 'Clear cache';

  @override
  String get cacheRemoveTime => 'Clear after';

  @override
  String get cacheRangeWeek => '1 Week';

  @override
  String get cacheRangeMonth => '1 Month';

  @override
  String get cacheRangeYear => '1 Year';

  @override
  String get cacheRangeNever => 'Never';

  @override
  String get cacheCleared => 'Cache was cleared successfully.';

  @override
  String get cacheClearedFailed => 'Cache could not be cleared.';

  @override
  String get linkNotOpened => 'The link could not be opened.';

  @override
  String get announcements => 'Announcements';

  @override
  String get showAnnouncementsOnStart => 'Show announcements on start';

  @override
  String get noAnnouncements => 'There are no current announcements.';

  @override
  String get doNotShowAgain => 'Do not show again';

  @override
  String get close => 'Close';

  @override
  String announcementPosition(int index, int count) {
    return '$index of $count';
  }

  @override
  String get previous => 'Back';

  @override
  String get showAnnouncements => 'Show current announcements';

  @override
  String get share => 'Share';

  @override
  String get shareSearchLink => 'Share link to the search';

  @override
  String get sharePlayLink => 'Share link to the playback';

  @override
  String get shareDownloadLink => 'Share download link';

  @override
  String get shareValidFor => 'Validity';

  @override
  String get shareValid1Hour => '1 hour';

  @override
  String get shareValid1Day => '1 day';

  @override
  String get shareValid7Days => '7 days';

  @override
  String get shareValid30Days => '30 days';

  @override
  String get shareValid90Days => '90 days';

  @override
  String get shareSingleUse => 'Single-use link';

  @override
  String get shareSingleUseHint =>
      'The link can be opened for download only once.';

  @override
  String get shareUseAsDefault => 'Use as default and do not ask again';

  @override
  String get shareSettings => 'Download links';

  @override
  String get shareMyLinks => 'My active links';

  @override
  String get shareNoLinks => 'No active links.';

  @override
  String shareLinkRecords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recordings',
      one: '1 recording',
    );
    return '$_temp0';
  }

  @override
  String shareLinkCreatedAt(String date) {
    return 'Created on $date';
  }

  @override
  String shareLinkExpiresAt(String date) {
    return 'Valid until $date';
  }

  @override
  String get shareLinkDeleteInfo =>
      'The link becomes invalid immediately. Whoever already received it can no longer download anything.';

  @override
  String get shareSettingsInfo =>
      'These settings apply to download links you create. They only take effect if you may share records and the administrator allows choosing them.';

  @override
  String get shareAskBeforeSharing => 'Ask before sharing';

  @override
  String sharePartial(int shareable, int total) {
    return 'You may share only $shareable of $total selected records. Only these are shared.';
  }

  @override
  String get shareLinkOtherServer => 'The link belongs to another server.';

  @override
  String shareSearchTooLarge(int max) {
    return 'The search contains too many filter values and cannot be shared. At most $max are allowed.';
  }

  @override
  String get resumePlayback => 'Continue playback';

  @override
  String get faqShareLinks =>
      'How do I share a search or the current playback?';

  @override
  String get faqShareLinksDescription =>
      'In the list of records tap the link icon at the top right to share the current search with all filters. The icon only appears if a search text or a filter is set. In the player the icon shares the playing record at the current position. Whoever opens the link lands in the app with the same search or listens to the record at the same position. The app must be installed and set up for the same server. Records someone has no permission for are not shown or played.';

  @override
  String get faqShareDownload => 'How do I share records for download?';

  @override
  String get faqShareDownloadDescription =>
      'In the list of records long press a record or a folder and select more. Then tap the icon to share a download link at the top right. Whoever opens the link downloads the records in the browser, even without the app: one record as audio file, several as ZIP archive, each named by its title. A link can contain 100 records at most. The icon only appears if you may share the selected records. If you may share only a part, you are notified and only that part is shared. Whether validity and single-use link can be chosen in the settings under “Download links” is decided by the administrator. You see and delete your active download links in the settings under “My active links”. A deleted link stops working immediately.';

  @override
  String get faqResumePlayback =>
      'How do I continue the playback after opening the app?';

  @override
  String get faqResumePlaybackDescription =>
      'Enable “Continue playback” in the settings. The next time you open the app the record you listened to last is prepared at the position where you stopped. Start it with the play button. The function is off by default.';

  @override
  String shareTooMany(int limit) {
    return 'A link can contain $limit records at most. Select fewer records or a smaller folder and create several links if needed.';
  }
}
