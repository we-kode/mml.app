import 'dart:io';

import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:mml_app/services/client.dart';
import 'package:mml_app/services/messenger.dart';
import 'package:mml_app/services/secure_storage.dart';

/// Service that handles requests to the server by adding all necessary headers
/// and handles errors with interceptors, that can occur during requests.
class ApiService {
  /// Instance of the api service.
  static final ApiService _instance = ApiService._();

  /// [Dio] instance that is used to send request.
  final Dio _dio = Dio();

  /// Instance of the messenger service, to show messages with.
  final MessengerService _messenger = MessengerService.getInstance();

  /// Instance of the [SecureStorageService] to handle data in the secure
  /// storage.
  final SecureStorageService _store = SecureStorageService.getInstance();

  /// Private constructor of the service.
  ApiService._() {
    initDio(_dio, true);
  }

  /// Returns the singleton instance of the [ApiService].
  static ApiService getInstance() {
    return _instance;
  }

  /// Sends a request with the given parameters to the server.
  Future<Response<T>> request<T>(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return _dio.request<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      options: options,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// Initializes the [dio] instance with interceptors for the default handling.
  ///
  /// Adds interceptors for error handling if [addErrorHandling] is set to true.
  void initDio(Dio dio, bool addErrorHandling) {
    dio.options.connectTimeout = const Duration(seconds: 5);
    dio.options.sendTimeout = const Duration(seconds: 5);
    dio.options.receiveTimeout = const Duration(seconds: 5);

    _addRequestOptionsInterceptor(dio);

    if (addErrorHandling) {
      _addDefaultErrorHandlerInterceptor(dio);
    }
  }

  /// Returns the headers that should be used for requests to the server.
  Future<Map<String, String>> getHeaders() async {
    Map<String, String> headers = {};

    headers['Accept-Language'] = Intl.shortLocale(
      Platform.localeName,
    );

    var accessToken = await _store.get(
      SecureStorageService.accessTokenStorageKey,
    );

    if (accessToken != null) {
      headers['Authorization'] = "Bearer $accessToken";
    }

    var appKey = await _store.get(SecureStorageService.appKeyStorageKey);

    if (appKey != null) {
      headers['App-Key'] = appKey;
    }

    return headers;
  }

  /// Returns the base url of the server to send requests to.
  Future<String> getBaseUrl() async {
    var serverName = await _store.get(
      SecureStorageService.serverNameStorageKey,
    );

    return 'https://$serverName/api/v1.0/';
  }

  /// Adds an interceptor to the [dio] instance, that adds all necessary headers
  /// to a request send with the passed instance.
  void _addRequestOptionsInterceptor(Dio dio) {
    dio.interceptors.add(
      InterceptorsWrapper(onRequest: (options, handler) async {
        options.baseUrl = await getBaseUrl();
        options.headers.addAll(await getHeaders());

        return handler.next(options);
      }),
    );
  }

  /// Adds an interceptor to the [dio] instance, that handles errors occured
  /// during requests send with the passed instance.
  void _addDefaultErrorHandlerInterceptor(Dio dio) {
    dio.interceptors.add(
      InterceptorsWrapper(onError: (DioException e, handler) async {
        if (e.response != null) {
          var statusCode = e.response!.statusCode;
          if (statusCode == HttpStatus.unauthorized) {
            RequestOptions requestOptions = e.requestOptions;

            var hasClientId = await _store.has(
              SecureStorageService.clientIdStorageKey,
            );

            var hasClientSecret = await _store.has(
              SecureStorageService.clientSecretStorageKey,
            );

            if (!hasClientId || !hasClientSecret) {
              return handler.reject(e);
            }

            await ClientService.getInstance().refreshToken();

            var hasAccessToken = await _store.has(
              SecureStorageService.accessTokenStorageKey,
            );

            if (!hasAccessToken) {
              return handler.reject(e);
            }

            // Retry request with the new token.
            var retryDio = Dio();
            initDio(retryDio, true);

            var options = Options(
              method: requestOptions.method,
              contentType: requestOptions.contentType,
              headers: requestOptions.headers,
            );

            try {
              var retryResponse = await retryDio.request(
                requestOptions.path,
                cancelToken: requestOptions.cancelToken,
                onReceiveProgress: requestOptions.onReceiveProgress,
                options: options,
                data: requestOptions.data,
                queryParameters: requestOptions.queryParameters,
              );

              return handler.resolve(retryResponse);
            } catch (e) {
              return handler.reject(e as DioException);
            }
          } else if (statusCode == HttpStatus.forbidden) {
            _messenger.showMessage(_messenger.forbidden);
            return handler.reject(e);
          } else if (statusCode != null &&
              statusCode >= HttpStatus.badRequest &&
              statusCode < HttpStatus.internalServerError) {
            // Client errors should be handled by the specific widget!
            return handler.reject(e);
          }
        }

        // All other errors except certificate errors!
        if (e.error is SocketException) {
          _messenger.showMessage(_messenger.notReachable);
        } else if (e.type is! HandshakeException) {
          _messenger.showMessage(_messenger.unexpectedError(e.message ?? ''));
        }

        return handler.reject(e);
      }),
    );
  }
}
