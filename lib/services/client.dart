import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mml_app/services/api.dart';
import 'package:mml_app/services/secure_storage.dart';

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

  /// Tries to login.
  ///
  /// If the login is successfully the returned tokens gets persisted to the
  /// secure storage.
  Future login() async {
    var clientId = await _storage.get(SecureStorageService.clientIdStorageKey);
    var clientSecret =
        await _storage.get(SecureStorageService.clientSecretStorageKey);
    var rsaPrivate =
        await _storage.get(SecureStorageService.rsaPrivateStorageKey);
    // TODO sign ckleint credentials with rsa and send as code challenge
    var signedData = '';

    Response<Map> response = await _apiService.request(
      '/identity/connect/token',
      data: {
        'grant_type': 'client_credentials',
        'client_id': clientId,
        'client_secret': clientSecret,
        'code_challenge': signedData
      },
      options: Options(
        method: 'POST',
        contentType: Headers.formUrlEncodedContentType,
      ),
    );

    if (response.statusCode == HttpStatus.ok) {
      await _storage.set(
        SecureStorageService.accessTokenStorageKey,
        response.data?['access_token'],
      );
    }
  }
}
