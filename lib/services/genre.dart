import 'package:dio/dio.dart';
import 'package:mml_app/models/model_list.dart';
import 'package:mml_app/models/genre.dart';
import 'package:mml_app/services/api.dart';

/// Service that handles the genres data of the server.
class GenreService {
  /// Instance of the genre service.
  static final GenreService _instance = GenreService._();

  /// Instance of the [ApiService] to access the server with.
  final ApiService _apiService = ApiService.getInstance();

  /// Private constructor of the service.
  GenreService._();

  /// Returns the singleton instance of the [GenreService].
  static GenreService getInstance() {
    return _instance;
  }

  /// Returns a list of genres with the amount of [take] starting from the [offset].
  Future<ModelList> getGenres(String? filter, int? offset, int? take) async {
    var response = await _apiService.request(
      '/media/genre/genres',
      queryParameters: {"filter": filter, "skip": offset, "take": take},
      options: Options(
        method: 'GET',
      ),
    );

    return ModelList(
      List<Genre>.from(
        response.data['items'].map((item) => Genre.fromJson(item)),
      ),
      offset ?? 0,
      response.data["totalCount"],
    );
  }

  Future<ModelList> getCommonGenres() async {
    var response = await _apiService.request(
      '/media/genre/commonGenres',
      options: Options(
        method: 'GET',
      ),
    );

    return ModelList(
      List<Genre>.from(
        response.data['items'].map((item) => Genre.fromJson(item)),
      ),
      0,
      response.data["totalCount"],
    );
  }
}
