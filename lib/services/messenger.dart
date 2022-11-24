import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/mml_app_localizations.dart';

/// Service that shows messages in the snackbar of the app.
class MessengerService {
  /// Instance of the messenger service.
  static final MessengerService _instance = MessengerService._();

  /// Global key to access the state of the snackbar.
  final GlobalKey<ScaffoldMessengerState> snackbarKey = GlobalKey();

  /// Private constructor of the service.
  MessengerService._();

  /// Returns the singleton instance of the [MessengerService].
  static MessengerService getInstance() {
    return _instance;
  }

  /// Shows the given [text] in the app snackbar.
  showMessage(String text) {
    final SnackBar snackBar = SnackBar(
      content: Text(text),
      duration: const Duration(seconds: 5),
    );
    snackbarKey.currentState?.showSnackBar(snackBar);
  }

  /// Translated string for bad certificate errors.
  String get badCertificate {
    return AppLocalizations.of(snackbarKey.currentContext!)!.badCertificate;
  }

  /// Translated string for a message if a record is not found.
  String get notFound {
    return AppLocalizations.of(snackbarKey.currentContext!)!.notFound;
  }

  /// Returns the translated string for unexpected errors with the passed
  /// [message].
  String unexpectedError(String message) {
    return AppLocalizations.of(snackbarKey.currentContext!)!
        .unexpectedError(message);
  }

  /// Translated string for forbidden errors.
  String get forbidden {
    return AppLocalizations.of(snackbarKey.currentContext!)!.forbidden;
  }

  /// Translated string for automatic logout.
  String get reRegister {
    return AppLocalizations.of(snackbarKey.currentContext!)!.reRegister;
  }

  /// Translated string for server not reachable.
  String get notReachable {
    return AppLocalizations.of(snackbarKey.currentContext!)!.notReachable;
  }

  /// Translated string for file not found.
  String get fileNotFound {
    return AppLocalizations.of(snackbarKey.currentContext!)!.fileNotFound;
  }

  /// Translated string for error on downloading.
  String get downloadError {
    return AppLocalizations.of(snackbarKey.currentContext!)!.downloadError;
  }
}
