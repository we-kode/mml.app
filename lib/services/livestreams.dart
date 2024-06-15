import 'package:dio/dio.dart';
import 'package:mml_app/models/livestream.dart';
import 'package:mml_app/models/model_list.dart';
import 'package:mml_app/services/api.dart';

class LivestreamService {
  /// Instance of the livestream service.
  static final LivestreamService _instance = LivestreamService._();

  /// Instance of the [ApiService] to access the server with.
  final ApiService _apiService = ApiService.getInstance();

  /// Private constructor of the service.
  LivestreamService._();

  /// Returns the singleton instance of the [LivestreamService].
  static LivestreamService getInstance() {
    return _instance;
  }

  /// Loads a list of livestream items filtered by [filter] with given [offset].
  Future<ModelList> get(
    String? filter,
    int? offset,
    int? take,
  ) async {
    var params = <String, String?>{};

    if (filter != null) {
      params['filter'] = filter;
    }

    if (offset != null) {
      params['skip'] = offset.toString();
    }

    if (take != null) {
      params['take'] = take.toString();
    }

    try {
      var response = await _apiService.request(
        '/media/livestream/list',
        queryParameters: params,
        options: Options(
          method: 'POST',
        ),
      );

      return ModelList(
        List<Livestream>.from(
          response.data['items'].map((item) => Livestream.fromJson(item)),
        ),
        offset ?? 0,
        response.data["totalCount"],
      );
    } catch (e) {
      return ModelList(
        List<Livestream>.empty(),
        offset ?? 0,
        0,
      );
    }
  }
}
