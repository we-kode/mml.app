// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'mml_app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Meine Mediathek';

  @override
  String get badCertificate => 'Es ist ein Zertifikatsfehler aufgetreten!';

  @override
  String get unknownError => 'Es ist ein unbekannter Fehler aufgetreten!';

  @override
  String offlineErrorTitle(String appTitle) {
    return '$appTitle ist nicht erreichbar';
  }

  @override
  String get offlineError =>
      'Stellen Sie die Internetverbindung her und versuchen Sie es erneut';

  @override
  String unexpectedError(String message) {
    return 'Es ist ein unerwarteter Fehler aufgetreten: $message';
  }

  @override
  String get forbidden =>
      'Sie haben nicht die notwendigen Rechte, die Aktion auszuführen!';

  @override
  String get done => 'Fertig';

  @override
  String get skip => 'Überspringen';

  @override
  String get registrationTitle => 'Registrierung';

  @override
  String get registrationScan =>
      'Scannen Sie den QR-Code in der Administration, um Ihr Gerät zu registrieren.';

  @override
  String get registrationError =>
      'Ein Fehler ist beim Registrieren aufgetreten. Versuchen Sie es erneut!';

  @override
  String get registrationSuccess => 'Gerät wurde erfolgreich registriert!';

  @override
  String get registrationProgress => 'Gerät wird registriert...';

  @override
  String get registrationEnterName =>
      'Geben Sie Ihren Namen ein, um sich zu registrieren.';

  @override
  String get registrationRSA =>
      'Sicherheitsschlüssel wird generiert. Das kann einen Augenblick dauern.';

  @override
  String get reRegister =>
      'Ihre Registrierung ist nicht mehr gültig. Registrieren Sie Ihr Gerät erneut!';

  @override
  String get records => 'Aufnahmen';

  @override
  String get settings => 'Einstellungen';

  @override
  String get playlist => 'Gespeicherte Titel';

  @override
  String get next => 'Weiter';

  @override
  String get firstName => 'Vorname';

  @override
  String get lastName => 'Nachname';

  @override
  String get invalidFirstName => 'Bitte geben Sie einen Vornamen an!';

  @override
  String get invalidLastName => 'Bitte geben Sie einen Nachnamen an!';

  @override
  String get notReachable =>
      'Der Server ist nicht erreichbar! Bitte prüfen Sie Ihre Netzwerkverbindung!';

  @override
  String get changeServerConnection => 'Server-Verbindung ändern';

  @override
  String get removeRegistration => 'Registrierung löschen';

  @override
  String get info => 'Info';

  @override
  String get privacyPolicy => 'Datenschutzerklärung';

  @override
  String get legalInformation => 'Impressum';

  @override
  String get licenses => 'Lizenzen';

  @override
  String get updateConnectionSettingsTitle => 'Server-Verbindung ändern';

  @override
  String get updateConnectionSettingsScan =>
      'Scannen Sie den QR-Code in der Administration, um die Einstellungen zu ändern.';

  @override
  String get updateConnectionSettingsError =>
      'Ein Fehler ist bei der Änderung aufgetreten. Versuchen Sie es erneut!';

  @override
  String get updateConnectionSettingsSuccess =>
      'Einstellungen wurden erfolgreich geändert!';

  @override
  String get updateConnectionSettingsProgress =>
      'Einstellungen werden geändert...';

  @override
  String get introTitleRegister => 'Registrieren';

  @override
  String get introTextRegister =>
      'Scannen Sie den QR-Code in der Administration, um Ihr Gerät zu registrieren.';

  @override
  String get introTitleRecords => 'Hören';

  @override
  String get introTextRecords =>
      'Greifen Sie auf verfügbare Audio-Aufnahmen zu, filtern Sie diese nach Belieben und hören Sie diese an.';

  @override
  String get introTitlePlaylist => 'Mitnehmen';

  @override
  String get introTextPlaylist =>
      'Fügen Sie Ihre Lieblingsaufnahmen zu offline Playlists hinzu und hören Sie diese auch wenn gerade kein Internet da ist.';

  @override
  String get unknown => 'Unbekannt';

  @override
  String get save => 'Anwenden';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get noData => 'Keine Datensätze wurden gefunden!';

  @override
  String get reload => 'Neu laden';

  @override
  String get date => 'Datum';

  @override
  String get artist => 'Interpret';

  @override
  String get genre => 'Genre';

  @override
  String get album => 'Album';

  @override
  String get filter => 'Filter';

  @override
  String get add => 'Hinzufügen';

  @override
  String get notFound => 'Der aufgerufene Datensatz wurde nicht gefunden!';

  @override
  String get editPlaylist => 'Wiedergabeliste bearbeiten';

  @override
  String get addPlaylist => 'Wiedergabeliste hinzufügen';

  @override
  String get invalidDisplayName => 'Bitte geben Sie einen Namen an!';

  @override
  String get playlistUniqueConstraintFailed =>
      'Wiedergabeliste ist bereits vorhanden.';

  @override
  String get remove => 'Löschen';

  @override
  String get yes => 'Ja';

  @override
  String get deleteConfirmation =>
      'Möchten Sie tatsächlich die gewählten Datensätze löschen?';

  @override
  String get download => 'Download';

  @override
  String get fileNotFound =>
      'Datei konnte nicht gefunden werden. Fügen Sie die Aufnahme erneut zu einer Playlist hinzu.';

  @override
  String get downloadError =>
      'Download fehlgeschlagen. Überprüfen Sie ihre Verbindung und Speicherplatz und versuchen Sie es erneut.';

  @override
  String get back => 'zurück';

  @override
  String get folder => 'Ordner';

  @override
  String get language => 'Sprache';

  @override
  String get notReachableRecord =>
      'Die Aufnahme konnte nicht geladen werden! Versuchen Sie es später noch einmal.';

  @override
  String get faq => 'Hilfe';

  @override
  String get faqAddFavorites => 'Wie speichere ich Aufnahmen?';

  @override
  String get sendFeedback => 'Feedback senden/Probleme melden';

  @override
  String get display => 'Darstellung';

  @override
  String get displayDescription =>
      'Welche Elemente sollen in der Liste der Aufnahmen angezeigt werden?';

  @override
  String get showGenre => 'Genre';

  @override
  String get showLanguage => 'Sprache';

  @override
  String get showTrackNumber => 'Tracknummer';

  @override
  String get faqAddFavoritesDescription =>
      'Es können mehrere Ordner angelegt werden, wo Aufnahmen abgespeichert werden. Dazu auf das Plus-Symbol in der \'Gespeicherte Titel\' Ansicht unten rechts klicken und einen Namen für den Ordner angeben. Aufnahmen können gespeichert werden durch gedrückt halten auf einer Aufnahme in der Liste. Es erscheint die Möglichkeit mehrere Elemente gleichzeitig auszuwählen. Oben rechts auf den Stern drücken und dann den Ordner auswählen in dem man die Aufnahmen speichern will. Die aktuell abgespielte Aufnahme kann im Player unten rechts gespeichert werden.';

  @override
  String get faqRemoveFavorites => 'Wie lösche ich gespeicherte Aufnahmen?';

  @override
  String get faqRemoveFavoritesDescription =>
      'Um eine oder mehrere gespeicherte Aufnahmen zu entfernen, eine Aufnahme oder den ganzen Ordner in der Liste gedrückt halten. Es erscheint eine Möglichkeit mehrere Elemente auszuwählen. Oben rechts auf den Mülleimersymbol drücken, um die ausgewählten Elemente zu entfernen.';

  @override
  String get development => 'Entwicklung';

  @override
  String get clearLogs => 'Logs löschen';

  @override
  String get showLogs => 'Logs anzeigen';

  @override
  String get livestreams => 'Livestreams';

  @override
  String get saveFilters => 'Filter merken';

  @override
  String get cover => 'Cover';

  @override
  String get notCompatibleFile =>
      'Datei konnte nicht gelesen werden. Format fehlerhaft.';

  @override
  String fileTooLarge(int size) {
    return 'Datei ist zu groß und kann nicht importiert werden (max. $size MB).';
  }

  @override
  String get notDownloaded => 'Nicht heruntergeladen';

  @override
  String get notDownloadedRecords =>
      'Folgende Aufnahmen sind nicht mehr verfügbar oder Sie haben kein Recht es herunterzuladen.';

  @override
  String get overview => 'Übersicht';

  @override
  String get favorites => 'Favoriten';

  @override
  String get livestreamShort => 'Live';

  @override
  String get discover => 'Stöbern';

  @override
  String get artists => 'Interpreten';

  @override
  String get genres => 'Genres';

  @override
  String get albums => 'Alben';

  @override
  String get languages => 'Sprachen';

  @override
  String get newest => 'Neueste';

  @override
  String get newestArtists => 'Neueste Interpreten';

  @override
  String get commonArtists => 'Häufige Interpreten';

  @override
  String get commonGenres => 'Häufige Genres';

  @override
  String get shuffle => 'Zufallswiedergabe';

  @override
  String get repeat => 'Wiederholung';

  @override
  String get stop => 'Stopp';

  @override
  String errorAuthenticationExpired(String appTitle) {
    return 'Registrieren Sie sich in $appTitle';
  }

  @override
  String get cacheSettings => 'Speicherverwaltung';

  @override
  String get cacheRemove => 'Cache löschen';

  @override
  String get cacheRemoveTime => 'Löschen, nach';

  @override
  String get cacheRangeWeek => '1 Woche';

  @override
  String get cacheRangeMonth => '1 Monat';

  @override
  String get cacheRangeYear => '1 Jahr';

  @override
  String get cacheRangeNever => 'Nie';

  @override
  String get cacheCleared => 'Cache wurde erfolgreich gelöscht.';

  @override
  String get cacheClearedFailed => 'Cache konnte nicht gelöscht werden.';

  @override
  String get linkNotOpened => 'Der Link konnte nicht geöffnet werden.';

  @override
  String get announcements => 'Mitteilungen';

  @override
  String get showAnnouncementsOnStart => 'Mitteilungen beim Start anzeigen';

  @override
  String get noAnnouncements => 'Es gibt keine aktuellen Mitteilungen.';

  @override
  String get doNotShowAgain => 'Nicht mehr anzeigen';

  @override
  String get close => 'Schließen';

  @override
  String announcementPosition(int index, int count) {
    return '$index von $count';
  }

  @override
  String get previous => 'Zurück';

  @override
  String get showAnnouncements => 'Aktuelle Mitteilungen anzeigen';

  @override
  String get share => 'Teilen';

  @override
  String get shareSearchLink => 'Link zur Suche teilen';

  @override
  String get sharePlayLink => 'Link zur Wiedergabe teilen';

  @override
  String get shareDownloadLink => 'Download-Link teilen';

  @override
  String get shareValidFor => 'Gültigkeit';

  @override
  String get shareValid1Hour => '1 Stunde';

  @override
  String get shareValid1Day => '1 Tag';

  @override
  String get shareValid7Days => '7 Tage';

  @override
  String get shareValid30Days => '30 Tage';

  @override
  String get shareValid90Days => '90 Tage';

  @override
  String get shareSingleUse => 'Einmal-Link';

  @override
  String get shareSingleUseHint =>
      'Der Link kann nur einmal zum Herunterladen geöffnet werden.';

  @override
  String get shareUseAsDefault =>
      'Als Standard verwenden und nicht mehr fragen';

  @override
  String get shareSettings => 'Download-Links';

  @override
  String get shareMyLinks => 'Meine aktiven Links';

  @override
  String get shareNoLinks => 'Keine aktiven Links.';

  @override
  String shareLinkRecords(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Aufnahmen',
      one: '1 Aufnahme',
    );
    return '$_temp0';
  }

  @override
  String shareLinkCreatedAt(String date) {
    return 'Erstellt am $date';
  }

  @override
  String shareLinkExpiresAt(String date) {
    return 'Gültig bis $date';
  }

  @override
  String get shareLinkDeleteInfo =>
      'Der Link wird sofort ungültig. Wer ihn bereits erhalten hat, kann nichts mehr herunterladen.';

  @override
  String get shareSettingsInfo =>
      'Diese Einstellungen gelten für Download-Links, die Sie erstellen. Sie greifen nur, wenn Sie Aufnahmen teilen dürfen und der Administrator die Auswahl erlaubt.';

  @override
  String get shareAskBeforeSharing => 'Vor dem Teilen nachfragen';

  @override
  String sharePartial(int shareable, int total) {
    return 'Sie dürfen nur $shareable von $total ausgewählten Aufnahmen teilen. Es werden nur diese geteilt.';
  }

  @override
  String get shareLinkOtherServer => 'Der Link gehört zu einem anderen Server.';

  @override
  String shareSearchTooLarge(int max) {
    return 'Die Suche enthält zu viele Filterwerte und kann nicht geteilt werden. Erlaubt sind höchstens $max.';
  }

  @override
  String get resumePlayback => 'Wiedergabe fortsetzen';

  @override
  String get faqShareLinks =>
      'Wie teile ich eine Suche oder die aktuelle Wiedergabe?';

  @override
  String get faqShareLinksDescription =>
      'Tippen Sie in der Aufnahmenliste oben rechts auf das Symbol für Links, um die aktuelle Suche mit allen Filtern zu teilen. Das Symbol erscheint nur, wenn ein Suchtext oder ein Filter gesetzt ist. Im Player teilt das Symbol die laufende Aufnahme an der aktuellen Position. Wer den Link öffnet, landet in der App mit derselben Suche beziehungsweise hört die Aufnahme an derselben Stelle. Dazu muss die App auf dem Gerät installiert und für denselben Server eingerichtet sein. Aufnahmen, für die jemand keine Berechtigung hat, werden nicht angezeigt oder abgespielt.';

  @override
  String get faqShareDownload => 'Wie teile ich Aufnahmen zum Herunterladen?';

  @override
  String get faqShareDownloadDescription =>
      'Halten Sie in der Aufnahmenliste eine Aufnahme oder einen Ordner gedrückt und wählen Sie weitere aus. Tippen Sie dann oben rechts auf das Symbol zum Teilen eines Download-Links. Wer den Link öffnet, lädt die Aufnahmen im Browser herunter, auch ohne die App: eine Aufnahme als Audiodatei, mehrere als ZIP-Archiv, jeweils mit dem Titel als Dateiname. Ein Link kann höchstens 100 Aufnahmen enthalten. Das Symbol erscheint nur, wenn Sie die ausgewählten Aufnahmen teilen dürfen. Dürfen Sie nur einen Teil teilen, werden Sie darauf hingewiesen und nur dieser Teil wird geteilt. Ob Gültigkeit und Einmal-Link in den Einstellungen unter „Download-Links“ gewählt werden können, bestimmt der Administrator. Ihre aktiven Download-Links sehen und löschen Sie in den Einstellungen unter „Meine aktiven Links“. Ein gelöschter Link funktioniert sofort nicht mehr.';

  @override
  String get faqResumePlayback =>
      'Wie setze ich die Wiedergabe nach dem Öffnen der App fort?';

  @override
  String get faqResumePlaybackDescription =>
      'Aktivieren Sie in den Einstellungen „Wiedergabe fortsetzen“. Beim nächsten Öffnen der App wird die zuletzt gehörte Aufnahme an der Stelle bereitgestellt, an der Sie aufgehört haben. Starten Sie sie mit der Wiedergabetaste. Die Funktion ist standardmäßig ausgeschaltet.';

  @override
  String shareTooMany(int limit) {
    return 'Ein Link kann höchstens $limit Aufnahmen enthalten. Wählen Sie weniger Aufnahmen oder einen kleineren Ordner aus und erstellen Sie bei Bedarf mehrere Links.';
  }
}
