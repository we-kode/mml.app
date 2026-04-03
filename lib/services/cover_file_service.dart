import 'package:dio/dio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart';
import 'package:mml_app/services/api.dart';

/// Service for the file service of the cache manager to load files from the api.
class CoverFileService extends FileService {
  /// Instance of the service.
  static final CoverFileService _instance = CoverFileService._();

  CoverFileService._();

  /// Returns the singleton instance of the [CoverFileService].
  static CoverFileService getInstance() {
    return _instance;
  }

  /// Instance of the [ApiService] to access the server with.
  final ApiService _apiService = ApiService.getInstance();

  @override
  Future<FileServiceResponse> get(String url, {Map<String, String>? headers}) async {
    final response = await _apiService.request(
      '/media/record/cover/$url',
      options: Options(
        method: 'GET',
        responseType: ResponseType.bytes
      ),
    );

    var stream = ByteStream.fromBytes(response.data);

    return HttpGetResponse(StreamedResponse(stream, response.statusCode ?? 200));
  }
}
