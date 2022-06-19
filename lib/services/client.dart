import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fast_rsa/fast_rsa.dart';
import 'package:flutter/material.dart';
import 'package:mml_app/models/client_registration.dart';
import 'package:mml_app/services/api.dart';
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
  Future register(ClientRegistration clientRegistration) async {
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

  Future removeRegistration() async {
    // TODO: Remove Registration on Server and handle errors correctly

    await _storage.delete(SecureStorageService.accessTokenStorageKey);
    await _storage.delete(SecureStorageService.appKeyStorageKey);
    await _storage.delete(SecureStorageService.clientIdStorageKey);
    await _storage.delete(SecureStorageService.clientSecretStorageKey);
    await _storage.delete(SecureStorageService.rsaPrivateStorageKey);
    await _storage.delete(SecureStorageService.rsaPublicStorageKey);
    await _storage.delete(SecureStorageService.serverNameStorageKey);

    NavigatorState state =
        RouterService.getInstance().navigatorKey.currentState!;
    state.pushReplacementNamed(RegisterViewModel.route);
  }

  ///
  Future<bool> isClientRegistered() async {
    var response = await _apiService.request(
      '/identity/client/',
      options: Options(method: 'GET'),
    );

    return response.data['Registered'];
  }

  ///
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
        '{ "clientId" : "$clientId", "clientSecret" : "$clientSecret", "grant_type" : "client_credentials" }',
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
        //_messenger.showMessage(_messenger.reRegister);
        await removeRegistration();
      }
    } catch (e) {
      // Remove registration on errors
      //_messenger.showMessage(_messenger.reRegister);
      await removeRegistration();

      // TODO: If no accessToken is available (during registration) remove registration
      // and rethrow error instead of redirect
    }
  }
}
