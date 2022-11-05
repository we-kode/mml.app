import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fast_rsa/fast_rsa.dart';
import 'package:flutter/material.dart';
import 'package:mml_app/models/client_registration.dart';
import 'package:mml_app/services/api.dart';
import 'package:mml_app/services/db.dart';
import 'package:mml_app/services/file.dart';
import 'package:mml_app/services/messenger.dart';
import 'package:mml_app/services/router.dart';
import 'package:mml_app/services/secure_storage.dart';
import 'package:mml_app/view_models/register.dart';

/// Service that handles the client data of the server.
class ClientService {
  /// Instance of the client service.
  static final ClientService _instance = ClientService._();

  /// Instance of the [ApiService] to access the server with.
  final ApiService _apiService = ApiService.getInstance();

  /// Instance of the [SecureStorageService] to handle data in the secure
  /// storage.
  final SecureStorageService _storage = SecureStorageService.getInstance();

  /// Instance of the [MessengerService] used to show messages to the user.
  final MessengerService _messenger = MessengerService.getInstance();

  /// Private constructor of the service.
  ClientService._();

  /// Returns the singleton instance of the [ClientService].
  static ClientService getInstance() {
    return _instance;
  }

  /// Tries to register.
  ///
  /// If the register is successfully the returned data gets persisted to the
  /// secure storage.
  Future register(
    ClientRegistration clientRegistration,
    String name,
    String deviceIdentifier,
  ) async {
    await _storage.set(
      SecureStorageService.appKeyStorageKey,
      clientRegistration.appKey,
    );
    await _storage.set(
      SecureStorageService.serverNameStorageKey,
      clientRegistration.endpoint,
    );

    var publicKey = await _storage.get(
      SecureStorageService.rsaPublicStorageKey,
    );

    var response = await _apiService.request(
      '/identity/client/register/${clientRegistration.token}',
      data: {
        'base64PublicKey': (publicKey ?? '')
            .replaceAll('-----BEGIN RSA PUBLIC KEY-----', '')
            .replaceAll('-----END RSA PUBLIC KEY-----', '')
            .replaceAll('\n', ''),
        'displayName': name,
        'deviceIdentifier': deviceIdentifier,
      },
      options: Options(method: 'POST'),
    );

    if (response.statusCode == HttpStatus.ok) {
      await _storage.set(
        SecureStorageService.clientIdStorageKey,
        response.data?['clientId'],
      );
      await _storage.set(
        SecureStorageService.clientSecretStorageKey,
        response.data?['clientSecret'],
      );

      await refreshToken();
    }
  }

  /// Tries to remove the registration of the current client.
  ///
  /// If an error occurs and the remove process was not called [automatic] due
  /// to an unauthorized error the error will be shown. Otherwise the removal
  /// process is finished by removing the data from the storage and redirecting
  /// to registration screen.
  Future removeRegistration({automatic = false}) async {
    var successfull = false;
    var message = "";

    try {
      var dio = Dio();
      _apiService.initDio(dio, false);

      var response = await dio.request(
        '/identity/client/removeRegistration',
        data: {},
        options: Options(method: 'POST'),
      );

      successfull = response.statusCode == HttpStatus.ok;
    } catch (e) {
      successfull =
          e is DioError && e.response?.statusCode == HttpStatus.unauthorized;

      if (e is DioError) {
        if (e.error is SocketException) {
          message = _messenger.notReachable;
        } else if (e.type is! HandshakeException) {
          message = _messenger.unexpectedError(e.message);
        }
      } else {
        message = _messenger.unexpectedError(
          FlutterErrorDetails(
            exception: e,
          ).summary.toDescription(),
        );
      }
    }

    if (successfull || automatic) {
      await FileService.getInstance().clear();
      await DBService.getInstance().clean();
      await _storage.clearTokens();
      await RouterService.getInstance().pushReplacementNamed(
        RegisterViewModel.route,
      );
    } else {
      _messenger.showMessage(message);
    }
  }

  /// Returns a boolean that indicates whether the client is registered.
  Future<bool> isClientRegistered({bool handleErrors = true}) async {
    Response response;

    var url = '/identity/client/';
    var options = Options(method: 'GET');

    if (handleErrors) {
      response = await _apiService.request(url, options: options);
    } else {
      var dio = Dio();
      _apiService.initDio(dio, false);

      response = await dio.request(url, options: options);
    }

    return response.data['registered'];
  }

  /// Tries to refresh the current access token.
  ///
  /// If an error occurs [removeRegistration] gets called to remove the
  /// client registration.
  Future refreshToken() async {
    var dio = Dio();
    _apiService.initDio(dio, false);

    try {
      var clientId = await _storage.get(
        SecureStorageService.clientIdStorageKey,
      );
      var clientSecret = await _storage.get(
        SecureStorageService.clientSecretStorageKey,
      );
      var rsaPrivate = await _storage.get(
        SecureStorageService.rsaPrivateStorageKey,
      );

      var data = {
        'grant_type': 'client_credentials',
        'client_id': clientId,
        'client_secret': clientSecret,
      };
      data['code_challenge'] = await RSA.signPKCS1v15(
        '{"grant_type":"client_credentials","client_id":"$clientId","client_secret":"$clientSecret"}',
        Hash.SHA512,
        rsaPrivate ?? '',
      );

      Response<Map> response = await dio.request(
        '/identity/connect/token',
        data: data,
        options: Options(
          method: 'POST',
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      // Store the token on successfull request.
      if (response.statusCode == HttpStatus.ok) {
        await _storage.set(
          SecureStorageService.accessTokenStorageKey,
          response.data?['access_token'],
        );
      } else {
        _messenger.showMessage(_messenger.reRegister);
        await removeRegistration(automatic: true);
      }
    } catch (e) {
      // Rethrow the error on login page, to abort the register process
      // correctly or on not authorized errors to prevent logout on server
      // errors.
      if (!(await _storage.has(SecureStorageService.accessTokenStorageKey)) ||
          (e is DioError &&
              (e.response?.statusCode != HttpStatus.unauthorized &&
                  e.response?.data['error'] != 'Error occurred 333'))) {
        rethrow;
      }

      // Remove registration on errors
      _messenger.showMessage(_messenger.reRegister);
      await removeRegistration(automatic: true);
    }
  }
}
