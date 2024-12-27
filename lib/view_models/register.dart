import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:fast_rsa/fast_rsa.dart';
import 'package:flutter/material.dart';
import 'package:mml_app/models/client_registration.dart';
import 'package:mml_app/services/client.dart';
import 'package:mml_app/services/router.dart';
import 'package:mml_app/services/secure_storage.dart';
import 'package:mml_app/l10n/mml_app_localizations.dart';
import 'package:mml_app/util/xor_encryptor.dart';
import 'package:mml_app/view_models/main.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// View model for the register screen.
class RegisterViewModel extends ChangeNotifier {
  /// Route of the register screen.
  static const String route = '/register';

  /// [RegistrationState] of the current process.
  late RegistrationState _state;

  /// Info message that should be shown to the user.
  late String infoMessage;

  /// [SecureStorageService] used to load data from the secure storage.
  final SecureStorageService _storage = SecureStorageService.getInstance();

  /// [ClientService] that is used to register the client.
  final ClientService _clientService = ClientService.getInstance();

  /// Key of the user register form.
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// Locales of the application.
  late AppLocalizations locales;

  /// Users first name who wants to register a device.
  String? firstName;

  /// Users last name who wants to register a device.
  String? lastName;

  /// The identifier of the device.
  late String deviceIdentifier;

  /// Initializes the registration screen and generates a new RSA-Key if
  /// a new registration should be executed.
  Future<bool> init(BuildContext context) async {
    locales = AppLocalizations.of(context)!;

    return Future<bool>.microtask(() async {
      if (await _storage.has(SecureStorageService.accessTokenStorageKey)) {
        try {
          print("DEBUG:::RegisterViewModel:56");
          var isRegistered = await _clientService.isClientRegistered();
          print("DEBUG:::RegisterViewModel:58:$isRegistered");
          if (isRegistered) {
            Future.microtask(() async {
              print("DEBUG:::RegisterViewModel:61");
              await afterRegistration();
            });

            return false;
          }
        } catch (e) {
          if (e is! DioException ||
              e.response?.statusCode != HttpStatus.unauthorized) {
            print("DEBUG:::RegisterViewModel:70");
            Future.microtask(() async {
              print("DEBUG:::RegisterViewModel:72");
              await afterRegistration();
            });

            return false;
          }
        }
      }

      print("DEBUG:::RegisterViewModel:81");
      if (Platform.isAndroid) {
        deviceIdentifier = (await DeviceInfoPlugin().androidInfo).model;
      }

      if (Platform.isIOS) {
        deviceIdentifier = (await DeviceInfoPlugin().iosInfo).utsname.machine;
      }

      state = RegistrationState.rsa;
      Future.microtask(() async {
        await generateKeys();
      });

      return true;
    });
  }

  /// Generates rsa key.
  Future generateKeys() async {
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

    final crypt = XorEncryptor.generateKey();
    await _storage.set(
      SecureStorageService.cryptoKey,
      crypt.toString(),
    );

    state = RegistrationState.init;
    notifyListeners();
  }

  /// Redirects the route with main route after successful registration.
  Future afterRegistration() async {
    print("DEBUG:::RegisterViewModel:126");
    await RouterService.getInstance().pushReplacementNamed(MainViewModel.route);
  }

  /// Sets the registration state of the process to the passed [state].
  set state(RegistrationState state) {
    _state = state;
    print("DEBUG:::RegisterViewModel:132:changingState:$state");
    switch (_state) {
      case RegistrationState.rsa:
        infoMessage = locales.registrationRSA;
        break;
      case RegistrationState.init:
        infoMessage = locales.registrationEnterName;
        break;
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
  void register(Barcode barcode) async {
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
      await _clientService.register(
        clientRegistration,
        "${firstName!.trim()} ${lastName!.trim()}",
        deviceIdentifier,
      );
      state = RegistrationState.success;
    } catch (e) {
      state = RegistrationState.error;
    }
  }

  /// Validates the given [name] and returns an error message or null if
  /// the [name] is valid.
  String? validateFirstName(String? name) {
    return (firstName ?? '').isNotEmpty ? null : locales.invalidFirstName;
  }

  /// Validates the given [name] and returns an error message or null if
  /// the [name] is valid.
  String? validateLastName(String? name) {
    return (lastName ?? '').isNotEmpty ? null : locales.invalidLastName;
  }

  /// Caches the entered name and sets the [RegistrationState] to scan if values are valid.
  void saveName() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      _state = RegistrationState.scan;
      notifyListeners();
    }
  }
}

/// State of the registration process.
enum RegistrationState {
  rsa,
  init,
  scan,
  register,
  error,
  success,
}
