import 'package:mml_app/services/api.dart';

/// Service that handles the records data of the server.
class NewsService {
  /// Instance of the record service.
  static final NewsService _instance = NewsService._();

  /// Instance of the [ApiService] to access the server with.
  final ApiService _apiService = ApiService.getInstance();

  /// Private constructor of the service.
  NewsService._();

  /// Returns the singleton instance of the [RecordService].
  static NewsService getInstance() {
    return _instance;
  }

  /// Returns a list of records with the amount of [take] that match the given
  /// [filter] starting from the [offset].
  Future<String> getNewsUrl() async{
    return "${await _apiService.getBaseUrl()}info";
  }
}