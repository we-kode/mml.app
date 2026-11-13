import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mml_app/models/share_options.dart';
import 'package:mml_app/services/api.dart';
import 'package:mml_app/services/secure_storage.dart';
import 'package:mml_app/services/share.dart';

/// Api, which answers all requests with the same [status].
class _Api extends Fake implements ApiService {
  final int? status;

  _Api(this.status);

  @override
  Future<Response<T>> request<T>(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    String apiVersion = '2.0',
  }) {
    final requestOptions = RequestOptions(path: path);
    throw DioException(
      requestOptions: requestOptions,
      response: status == null
          ? null
          : Response(requestOptions: requestOptions, statusCode: status),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final service = ShareService.getInstance();

  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  group('refreshing the rights', () {
    const rights = '{"canShare":true,"hasLinks":true}';

    setUp(() {
      FlutterSecureStorage.setMockInitialValues({
        SecureStorageService.shareStateStorageKey: rights,
      });
    });

    test('removes them, if the server does not support sharing', () async {
      final service = ShareService.withApi(_Api(404));

      await service.refresh();

      expect(service.supported.value, isFalse);
      expect(await service.canShare(), isFalse);
      expect(await service.hasLinks(), isFalse);
    });

    test('keeps them, if the server can not be reached', () async {
      final service = ShareService.withApi(_Api(null));

      await service.refresh();

      expect(service.supported.value, isTrue);
      expect(await service.canShare(), isTrue);
    });

    test('keeps them on server errors', () async {
      final service = ShareService.withApi(_Api(500));

      await service.refresh();

      expect(service.supported.value, isTrue);
      expect(await service.canShare(), isTrue);
    });
  });

  test('defaults are the longest validity and single use links', () async {
    final options = await service.loadDefaults();

    expect(options.validForHours, ShareOptions.validForHoursChoices.last);
    expect(options.singleUse, isTrue);
    expect(await service.useDefaults(), isFalse);
  });

  test('defaults are stored together and restored', () async {
    await service.saveDefaults(
      ShareOptions(validForHours: 24, singleUse: false),
      true,
    );

    final options = await service.loadDefaults();
    expect(options.validForHours, 24);
    expect(options.singleUse, isFalse);
    expect(await service.useDefaults(), isTrue);
  });

  test('remembering links keeps the known rights', () async {
    FlutterSecureStorage.setMockInitialValues({
      SecureStorageService.shareStateStorageKey: '{"canShare":true}',
    });

    await service.rememberLinks(true);

    expect(await service.canShare(), isTrue);
    expect(await service.hasLinks(), isTrue);
    expect(await service.userChoosesOptions(), isFalse);
  });

  test('invalid stored values are ignored', () async {
    FlutterSecureStorage.setMockInitialValues({
      SecureStorageService.shareStateStorageKey: 'no json',
      SecureStorageService.shareDefaultsStorageKey: '{"validForHours":5}',
    });

    expect(await service.canShare(), isFalse);
    expect(
      (await service.loadDefaults()).validForHours,
      ShareOptions.validForHoursChoices.last,
    );
  });
}
