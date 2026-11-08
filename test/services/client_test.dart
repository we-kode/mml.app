import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mml_app/services/client.dart';
import 'package:mml_app/services/secure_storage.dart';

/// Adapter, which answers requests to known urls and fails for all others.
class _Adapter implements HttpClientAdapter {
  final Map<String, (int, Object)> routes;
  final List<RequestOptions> requests = [];

  _Adapter(this.routes);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final route = routes[options.uri.toString()];
    if (route == null) {
      throw DioException.connectionError(
        requestOptions: options,
        reason: 'unreachable',
      );
    }

    return ResponseBody.fromString(
      jsonEncode(route.$2),
      route.$1,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const oldServer = 'old.example.com:5050';
  const newServer = 'new.example.com';
  const tokenUrl = 'https://$newServer/api/v1.0/identity/connect/token';
  const clientUrl = 'https://$newServer/api/v2.0/identity/client/';
  final storage = SecureStorageService.getInstance();

  Future<String> sign(String message, String privateKey) async => 'signature';

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({
      SecureStorageService.serverNameStorageKey: oldServer,
      SecureStorageService.appKeyStorageKey: 'appKey',
      SecureStorageService.clientIdStorageKey: 'clientId',
      SecureStorageService.clientSecretStorageKey: 'clientSecret',
      SecureStorageService.rsaPrivateStorageKey: 'private',
      SecureStorageService.accessTokenStorageKey: 'oldToken',
    });
  });

  Future<void> expectKept() async {
    expect(
      await storage.get(SecureStorageService.serverNameStorageKey),
      oldServer,
    );
    expect(
      await storage.get(SecureStorageService.accessTokenStorageKey),
      'oldToken',
    );
    expect(
      await storage.get(SecureStorageService.clientIdStorageKey),
      'clientId',
    );
    expect(
      await storage.get(SecureStorageService.clientSecretStorageKey),
      'clientSecret',
    );
  }

  test('concurrent token refreshes share one request', () async {
    FlutterSecureStorage.setMockInitialValues({});
    final service = ClientService.getInstance();

    final first = service.refreshToken();
    final second = service.refreshToken();
    expect(identical(first, second), isTrue);

    await first.catchError((_) {});
    expect(
      identical(service.refreshToken()..catchError((_) {}), first),
      isFalse,
    );
  });

  group('moving to another server', () {
    test('moves, if the client is registered on the new server', () async {
      final adapter = _Adapter({
        tokenUrl: (200, {'access_token': 'newToken'}),
        clientUrl: (200, {'registered': true, 'serverName': newServer}),
      });

      await ClientService.withMoveAdapter(adapter, sign).moveServer(newServer);

      expect(
        await storage.get(SecureStorageService.serverNameStorageKey),
        newServer,
      );
      expect(
        await storage.get(SecureStorageService.accessTokenStorageKey),
        'newToken',
      );
      expect(adapter.requests.first.headers['App-Key'], 'appKey');
      expect(adapter.requests.first.data['code_challenge'], 'signature');
      expect(adapter.requests.last.headers['Authorization'], 'Bearer newToken');
    });

    test(
      'keeps the registration, if the new server rejects the client',
      () async {
        final adapter = _Adapter({
          tokenUrl: (401, {'error': 'unauthorized'}),
        });

        await ClientService.withMoveAdapter(
          adapter,
          sign,
        ).moveServer(newServer);

        await expectKept();
      },
    );

    test('keeps the server, if the client is not registered there', () async {
      final adapter = _Adapter({
        tokenUrl: (200, {'access_token': 'newToken'}),
        clientUrl: (200, {'registered': false, 'serverName': newServer}),
      });

      await ClientService.withMoveAdapter(adapter, sign).moveServer(newServer);

      await expectKept();
    });

    test('keeps the server, if the new server announces another one', () async {
      final adapter = _Adapter({
        tokenUrl: (200, {'access_token': 'newToken'}),
        clientUrl: (200, {'registered': true}),
      });

      await ClientService.withMoveAdapter(adapter, sign).moveServer(newServer);

      await expectKept();
    });

    test('keeps the server, if the new server is not reachable', () async {
      final adapter = _Adapter({});

      await ClientService.withMoveAdapter(adapter, sign).moveServer(newServer);

      await expectKept();
      expect(adapter.requests, hasLength(1));
    });

    for (final invalid in [
      'https://$newServer',
      '$newServer/api',
      '$newServer:443',
      'user@$newServer',
      '$newServer?x=1',
      '',
    ]) {
      test('sends no request to the invalid server name "$invalid"', () async {
        final adapter = _Adapter({});

        await ClientService.withMoveAdapter(adapter, sign).moveServer(invalid);

        await expectKept();
        expect(adapter.requests, isEmpty);
      });
    }

    test('sends no request, if the server did not change', () async {
      final adapter = _Adapter({});

      await ClientService.withMoveAdapter(
        adapter,
        sign,
      ).moveServer(oldServer.toUpperCase());

      await expectKept();
      expect(adapter.requests, isEmpty);
    });
  });
}
