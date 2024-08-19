import 'package:dio/dio.dart';
import 'package:mml_app/models/model_list.dart';
import 'package:mml_app/models/album.dart';
import 'package:mml_app/services/api.dart';

/// Service that handles the album data of the server.
class AlbumService {
  /// Instance of the Album service.
  static final AlbumService _instance = AlbumService._();

  /// Instance of the [ApiService] to access the server with.
  final ApiService _apiService = ApiService.getInstance();

  /// Private constructor of the service.
  AlbumService._();

  /// Returns the singleton instance of the [AlbumService].
  static AlbumService getInstance() {
    return _instance;
  }

  /// Returns a list of albums with the amount of [take] starting from the [offset].
  Future<ModelList> getAlbums(String? filter, int? offset, int? take) async {
    var response = await _apiService.request(
      '/media/album/albums',
      queryParameters: {"filter": filter, "skip": offset, "take": take},
      options: Options(
        method: 'GET',
      ),
    );

    return ModelList(
      List<Album>.from(
        response.data['items'].map((item) => Album.fromJson(item)),
      ),
      offset ?? 0,
      response.data["totalCount"],
    );
  }
}
