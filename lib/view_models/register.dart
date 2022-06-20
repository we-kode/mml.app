import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fast_rsa/fast_rsa.dart';
import 'package:flutter/material.dart';
import 'package:mml_app/models/client_registration.dart';
import 'package:mml_app/services/client.dart';
import 'package:mml_app/services/router.dart';
import 'package:mml_app/services/secure_storage.dart';
import 'package:flutter_gen/gen_l10n/mml_app_localizations.dart';
import 'package:mml_app/view_models/main.dart';

/// View model for the register screen.
class RegisterViewModel extends ChangeNotifier {
  /// Route of the register screen.
  static String route = '/register';

  /// [RegistrationState] of the current process.
  late RegistrationState _state;

  /// Info message that should be shown to the user.
  late String infoMessage;

  /// [SecureStorageService] used to load data from the secure storage.
  final SecureStorageService _storage = SecureStorageService.getInstance();

  /// [ClientService] that is used to register the client.
  final ClientService _clientService = ClientService.getInstance();

  /// Locales of the application.
  late AppLocalizations locales;

  /// Initializes the registration screen and generates a new RSA-Key if
  /// a new registration should be executed.
  Future<bool> init(BuildContext context) async {
    locales = AppLocalizations.of(context)!;

    return Future<bool>.microtask(() async {
      if (await _storage.has(SecureStorageService.accessTokenStorageKey)) {
        try {
          var isRegistered = await _clientService.isClientRegistered();

          if (isRegistered) {
            Future.microtask(() async {
              await afterRegistration();
            });

            return false;
          }
        } catch (e) {
          if (e is! DioError ||
              e.response?.statusCode != HttpStatus.unauthorized) {
            Future.microtask(() async {
              await afterRegistration();
            });

            return false;
          }
        }
      }

      var keyPair = await RSA.generate(4096);
      var private = await RSA.convertPrivateKeyToPKCS1(keyPair.privateKey);
      var public = await RSA.convertPublicKeyToPKCS1(keyPair.publicKey);

      await _storage.set(
        SecureStorageService.rsaPrivateStorageKey,
        private,
      );
      await _storage.set(
        SecureStorageService.rsaPublicStorageKey,
        public,
      );

      state = RegistrationState.scan;

      return true;
    });
  }

  /// Redirects the route with main route after successfull registration.
  Future afterRegistration() async {
    await RouterService.getInstance().pushReplacementNamed(MainViewModel.route);
  }

  /// Sets the registration state of the process to the passed [state].
  set state(RegistrationState state) {
    _state = state;

    switch (_state) {
      case RegistrationState.scan:
        infoMessage = locales.registrationScan;
        break;
      case RegistrationState.register:
        infoMessage = locales.registrationProgress;
        break;
      case RegistrationState.error:
        infoMessage = locales.registrationError;
        break;
      case RegistrationState.success:
        infoMessage = locales.registrationSuccess;
        break;
    }

    notifyListeners();
  }

  /// Returns the current [state] of the registration process.
  RegistrationState get state {
    return _state;
  }

  /// Tries to register the client if a new [barcode] gets scanned.
  void register(barcode, args) async {
    if (barcode.rawValue == null) {
      return;
    }

    ClientRegistration? clientRegistration = ClientRegistration.fromString(
      barcode.rawValue!,
    );

    if (clientRegistration == null) {
      return;
    }

    state = RegistrationState.register;

    try {
      await _clientService.register(clientRegistration);
      state = RegistrationState.success;
    } catch (e) {
      state = RegistrationState.error;
    }
  }
}

/// State of the registration process.
enum RegistrationState {
  scan,
  register,
  error,
  success,
}
