import 'dart:async';
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

  /// The running refresh of the access token or null.
  Future<void>? _refresh;

  /// The running move to another server or null.
  Future<void>? _move;

  /// Adapter used to send the requests while moving to another server or null
  /// for the default adapter.
  final HttpClientAdapter? _moveAdapter;

  /// Signs the [message] with the [privateKey] of the client.
  final Future<String> Function(String message, String privateKey) _sign;

  /// Private constructor of the service.
  ClientService._([
    this._moveAdapter,
    Future<String> Function(String message, String privateKey)? sign,
  ]) : _sign =
           sign ??
           ((message, privateKey) =>
               RSA.signPKCS1v15(message, Hash.SHA512, privateKey));

  /// Creates a service, that sends the requests of [moveServer] with the
  /// [adapter] and signs token requests with [sign].
  @visibleForTesting
  factory ClientService.withMoveAdapter(
    HttpClientAdapter adapter,
    Future<String> Function(String message, String privateKey) sign,
  ) {
    return ClientService._(adapter, sign);
  }

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
      apiVersion: '2.0',
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
  Future removeRegistration({bool automatic = false}) async {
    var successful = false;
    var message = "";

    try {
      var dio = Dio();
      _apiService.initDio(dio, false);

      var response = await dio.request(
        '/v1.0/identity/client/removeRegistration',
        data: {},
        options: Options(method: 'POST'),
      );

      successful = response.statusCode == HttpStatus.ok;
    } catch (e) {
      successful = e is DioException;

      if (e is! DioException) {
        message = _messenger.unexpectedError(
          FlutterErrorDetails(exception: e).summary.toDescription(),
        );
      }
    }

    if (successful || automatic) {
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
  ///
  /// Moves the client in the background with [moveServer], if the server
  /// announces another server name.
  Future<bool> isClientRegistered({bool handleErrors = true}) async {
    Response response;

    var url = '/identity/client/';
    var options = Options(method: 'GET');

    if (handleErrors) {
      response = await _apiService.request(
        url,
        options: options,
        apiVersion: '2.0',
      );
    } else {
      var dio = Dio();
      _apiService.initDio(dio, false);

      response = await dio.request(url, options: options);
    }

    final serverName = response.data['serverName'];
    if (serverName is String && serverName.isNotEmpty) {
      unawaited(moveServer(serverName));
    }

    return response.data['registered'];
  }

  /// Moves the client to the server [serverName] in the format host[:port].
  ///
  /// The client is moved only, if [serverName] is a host with an optional
  /// port, the client is registered on [serverName] and the
  /// server announces the same server name. Otherwise or on any error the
  /// current server is kept, so the client never loses its registration.
  /// Concurrent calls wait for the same move.
  Future<void> moveServer(String serverName) {
    return _move ??= _moveServer(serverName).whenComplete(() => _move = null);
  }

  Future<void> _moveServer(String serverName) async {
    final current = await _storage.get(
      SecureStorageService.serverNameStorageKey,
    );
    if (current == null ||
        !_isServerName(serverName) ||
        _isSameServer(current, serverName)) {
      return;
    }

    try {
      final appKey = await _storage.get(SecureStorageService.appKeyStorageKey);
      final dio = Dio(
        BaseOptions(
          baseUrl: 'https://$serverName/api/',
          connectTimeout: const Duration(seconds: 5),
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
          headers: {'App-Key': ?appKey},
        ),
      );
      if (_moveAdapter != null) {
        dio.httpClientAdapter = _moveAdapter;
      }

      final token = (await _requestToken(dio)).data?['access_token'];
      if (token is! String || token.isEmpty) {
        return;
      }

      final response = await dio.request(
        '/v2.0/identity/client/',
        options: Options(
          method: 'GET',
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      final data = response.data;
      if (data is! Map ||
          data['registered'] != true ||
          data['serverName'] is! String ||
          !_isSameServer(data['serverName'], serverName)) {
        return;
      }

      // The secure storage must not be written concurrently and the server
      // must not have been changed in the meantime, e.g. by scanning new
      // connection settings.
      await _refresh;
      final now = await _storage.get(SecureStorageService.serverNameStorageKey);
      if (now == null || !_isSameServer(now, current)) {
        return;
      }

      await _storage.set(SecureStorageService.accessTokenStorageKey, token);
      await _storage.set(SecureStorageService.serverNameStorageKey, serverName);
    } catch (_) {
      // Keep the current server and try again on the next start.
    }
  }

  bool _isSameServer(String a, String b) => a.toLowerCase() == b.toLowerCase();

  bool _isServerName(String value) {
    final uri = Uri.tryParse('https://$value');
    return uri != null &&
        uri.host.isNotEmpty &&
        uri.userInfo.isEmpty &&
        uri.path.isEmpty &&
        !uri.hasQuery &&
        !uri.hasFragment &&
        _isSameServer(uri.authority, value);
  }

  Future<Response<Map>> _requestToken(Dio dio) async {
    var clientId = await _storage.get(SecureStorageService.clientIdStorageKey);
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
    data['code_challenge'] = await _sign(
      '{"grant_type":"client_credentials","client_id":"$clientId","client_secret":"$clientSecret"}',
      rsaPrivate ?? '',
    );

    return dio.request(
      '/v1.0/identity/connect/token',
      data: data,
      options: Options(
        method: 'POST',
        contentType: Headers.formUrlEncodedContentType,
      ),
    );
  }

  /// Tries to refresh the current access token. Concurrent calls wait for the
  /// same refresh.
  ///
  /// If an error occurs [removeRegistration] gets called to remove the
  /// client registration.
  Future<void> refreshToken() {
    return _refresh ??= _refreshToken().whenComplete(() => _refresh = null);
  }

  // The secure storage must not be written concurrently, so only one refresh
  // runs at a time.
  Future<void> _refreshToken() async {
    var dio = Dio();
    _apiService.initDio(dio, false);

    try {
      Response<Map> response = await _requestToken(dio);

      // Store the token on successful request.
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
          (e is DioException &&
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
