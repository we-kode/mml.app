import 'package:dio/dio.dart';
import 'package:mml_app/models/model_list.dart';
import 'package:mml_app/models/language.dart';
import 'package:mml_app/services/api.dart';

/// Service that handles the languages data of the server.
class LanguageService {
  /// Instance of the language service.
  static final LanguageService _instance = LanguageService._();

  /// Instance of the [ApiService] to access the server with.
  final ApiService _apiService = ApiService.getInstance();

  /// Private constructor of the service.
  LanguageService._();

  /// Returns the singleton instance of the [LanguageService].
  static LanguageService getInstance() {
    return _instance;
  }

  /// Returns a list of languages with the amount of [take] starting from the [offset] with the passed [filter],
  Future<ModelList> getLanguages(String? filter, int? offset, int? take) async {
    var response = await _apiService.request(
      '/media/language/languages',
      queryParameters: {"filter": filter, "skip": offset, "take": take},
      options: Options(
        method: 'GET',
      ),
    );

    return ModelList(
      List<Language>.from(
        response.data['items'].map((item) => Language.fromJson(item)),
      ),
      offset ?? 0,
      response.data["totalCount"],
    );
  }
}
