import 'package:dio/dio.dart';
import 'package:mml_app/models/model_list.dart';
import 'package:mml_app/models/artist.dart';
import 'package:mml_app/services/api.dart';

/// Service that handles the artist data of the server.
class ArtistService {
  /// Instance of the Artist service.
  static final ArtistService _instance = ArtistService._();

  /// Instance of the [ApiService] to access the server with.
  final ApiService _apiService = ApiService.getInstance();

  /// Private constructor of the service.
  ArtistService._();

  /// Returns the singleton instance of the [ArtistService].
  static ArtistService getInstance() {
    return _instance;
  }

  /// Returns a list of artists with the amount of [take] starting from the [offset].
  Future<ModelList> getArtists(String? filter, int? offset, int? take) async {
    var response = await _apiService.request(
      '/media/artist/artists',
      queryParameters: {"filter": filter, "skip": offset, "take": take},
      options: Options(
        method: 'GET',
      ),
    );

    return ModelList(
      List<Artist>.from(
        response.data['items'].map((item) => Artist.fromJson(item)),
      ),
      offset ?? 0,
      response.data["totalCount"],
    );
  }

  /// Returns a list of newest artists.
  Future<ModelList> getNewestArtists() async {
    var response = await _apiService.request(
      '/media/artist/newestArtists',
      options: Options(
        method: 'GET',
      ),
    );

    return ModelList(
      List<Artist>.from(
        response.data['items'].map((item) => Artist.fromJson(item)),
      ),
      0,
      response.data["totalCount"],
    );
  }

  /// Returns a list of common artists.
  Future<ModelList> getCommonArtists() async {
    var response = await _apiService.request(
      '/media/artist/commonArtists',
      options: Options(
        method: 'GET',
      ),
    );

    return ModelList(
      List<Artist>.from(
        response.data['items'].map((item) => Artist.fromJson(item)),
      ),
      0,
      response.data["totalCount"],
    );
  }
}
