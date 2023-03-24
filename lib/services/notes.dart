import 'package:dio/dio.dart';
import 'package:mml_app/models/info.dart';
import 'package:mml_app/models/model_list.dart';
import 'package:mml_app/services/api.dart';

/// Service that handles the notes data of the server.
class NotesService {
  /// Instance of the notes service.
  static final NotesService _instance = NotesService._();

  /// Instance of the [ApiService] to access the server with.
  final ApiService _apiService = ApiService.getInstance();

  /// Private constructor of the service.
  NotesService._();

  /// Returns the singleton instance of the [NotesService].
  static NotesService getInstance() {
    return _instance;
  }

  /// Loads the content of a file of current [path].
  Future<String> loadContent(String path) async {
    var response = await _apiService.request(
      '/info/content',
      queryParameters: {"path": path},
      options: Options(
        method: 'GET',
      ),
    );

    return response.data;
  }

  /// Lists all a number of files and directories given by [take] inside given [path] with given [offset].
  Future<ModelList> list(String? path, int? offset, int? take) async {
    var response = await _apiService.request(
      '/info',
      queryParameters: {"path": path, "skip": offset, "take": take},
      options: Options(
        method: 'GET',
      ),
    );

    return ModelList(
      List<Info>.from(
        response.data['items'].map((item) => Info.fromJson(item)),
      ),
      offset ?? 0,
      response.data["totalCount"],
    );
  }
}
