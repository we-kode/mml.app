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

  ///
  late RegistrationState _state;

  ///
  late String infoMessage;

  /// [SecureStorageService] used to load data from the secure storage.
  final SecureStorageService _storage = SecureStorageService.getInstance();

  ///
  final ClientService _clientService = ClientService.getInstance();

  /// Locales of the application.
  late AppLocalizations locales;

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

      await _storage.set(
        SecureStorageService.rsaPrivateStorageKey,
        keyPair.privateKey,
      );
      await _storage.set(
        SecureStorageService.rsaPublicStorageKey,
        keyPair.publicKey,
      );

      state = RegistrationState.scan;

      return true;
    });
  }

  Future afterRegistration() async {
    await RouterService.getInstance()
        .navigatorKey
        .currentState!
        .pushReplacementNamed(MainViewModel.route);
  }

  ///
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

  ///
  RegistrationState get state {
    return _state;
  }

  ///
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

      Future.delayed(const Duration(seconds: 5), () async {
        afterRegistration();
      });
    } catch (e) {
      state = RegistrationState.error;

      Future.delayed(const Duration(seconds: 5), () {
        state = RegistrationState.scan;
      });
    }
  }
}

///
enum RegistrationState {
  scan,
  register,
  error,
  success,
}
