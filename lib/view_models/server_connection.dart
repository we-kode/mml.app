import 'package:flutter/material.dart';
import 'package:mml_app/models/connection_settings.dart';
import 'package:mml_app/services/client.dart';
import 'package:mml_app/services/router.dart';
import 'package:mml_app/services/secure_storage.dart';
import 'package:flutter_gen/gen_l10n/mml_app_localizations.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// View model of the server connection update screen.
class ServerConnectionViewModel extends ChangeNotifier {
  /// Route of the server connection screen.
  static String route = '/server_connection';

  /// [UpdateState] of the current process.
  late UpdateState _state;

  /// Info message that should be shown to the user.
  late String infoMessage;

  /// [SecureStorageService] used to load data from the secure storage.
  final SecureStorageService _storage = SecureStorageService.getInstance();

  /// [ClientService] that is used to check the new connection settings the
  /// client.
  final ClientService _clientService = ClientService.getInstance();

  /// Locales of the application.
  late AppLocalizations locales;

  /// Initializes the update connection settings screen.
  Future<bool> init(BuildContext context) async {
    locales = AppLocalizations.of(context)!;

    return Future<bool>.microtask(() async {
      state = UpdateState.scan;

      return true;
    });
  }

  /// Redirects the route with main route after successfull connection update.
  Future afterConnectionUpdate() async {
    await RouterService.getInstance().popNestedRoute();
  }

  /// Sets the update state of the process to the passed [state].
  set state(UpdateState state) {
    _state = state;

    switch (_state) {
      case UpdateState.scan:
        infoMessage = locales.updateConnectionSettingsScan;
        break;
      case UpdateState.update:
        infoMessage = locales.updateConnectionSettingsProgress;
        break;
      case UpdateState.error:
        infoMessage = locales.updateConnectionSettingsError;
        break;
      case UpdateState.success:
        infoMessage = locales.updateConnectionSettingsSuccess;
        break;
    }

    notifyListeners();
  }

  /// Returns the current [state] of the update connection settings process.
  UpdateState get state {
    return _state;
  }

  /// Tries to update the server connection settings if a new [barcode] gets
  /// scanned.
  void updateConnectionSettings(
    Barcode barcode,
  ) async {
    if (barcode.rawValue == null) {
      return;
    }

    state = UpdateState.update;

    ConnectionSettings? connectionSettings = ConnectionSettings.fromString(
      barcode.rawValue!,
    );

    if (connectionSettings == null) {
      state = UpdateState.error;
      return;
    }

    try {
      await _storage.set(
        SecureStorageService.appKeyStorageKey,
        connectionSettings.apiKey,
      );
      await _storage.set(
        SecureStorageService.serverNameStorageKey,
        connectionSettings.serverName,
      );
      var isRegistered = await _clientService.isClientRegistered(
        handleErrors: false,
      );
      state = isRegistered ? UpdateState.success : UpdateState.error;
    } catch (e) {
      state = UpdateState.error;
    }
  }
}

/// State of the update connection settings process.
enum UpdateState {
  scan,
  update,
  error,
  success,
}
