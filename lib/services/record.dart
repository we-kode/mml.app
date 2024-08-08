import 'package:dio/dio.dart';
import 'package:mml_app/models/id3_tag_filter.dart';
import 'package:mml_app/models/model_list.dart';
import 'package:mml_app/models/record.dart';
import 'package:mml_app/models/record_folder.dart';
import 'package:mml_app/models/record_view_settings.dart';
import 'package:mml_app/services/api.dart';

/// Service that handles the records data of the server.
class RecordService {
  /// Instance of the record service.
  static final RecordService _instance = RecordService._();

  /// Instance of the [ApiService] to access the server with.
  final ApiService _apiService = ApiService.getInstance();

  /// Private constructor of the service.
  RecordService._();

  /// Returns the singleton instance of the [RecordService].
  static RecordService getInstance() {
    return _instance;
  }

  /// Returns a list of records with the amount of [take] that match the given
  /// [filter] starting from the [offset].
  Future<ModelList> getRecords(
    String? filter,
    int? offset,
    int? take,
    ID3TagFilter? tagFilter,
    RecordViewSettings recordViewSettings,
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

    var response = await _apiService.request(
      '/media/record/list',
      queryParameters: params,
      data: tagFilter != null ? tagFilter.toJson() : {},
      options: Options(
        method: 'POST',
      ),
    );

    return ModelList(
      List<Record>.from(
        response.data['items'].map(
          (item) {
            var rec = Record.fromJson(item);
            rec.viewSettings = recordViewSettings;
            return rec;
          },
        ),
      ),
      offset ?? 0,
      response.data["totalCount"],
    );
  }

  /// Loads the record with the given [id] from the server.
  ///
  /// Returns the [Record] instance or null if the record was not found.
  Future<Record> getRecord(String id) async {
    var response = await _apiService.request(
      '/media/record/$id',
      options: Options(
        method: 'GET',
      ),
    );

    return Record.fromJson(response.data);
  }

  /// Returns a list of records which are part of the checksums.
  Future<ModelList> getRecordsByChecksum(
    List<String> checksums,
  ) async {
    var response = await _apiService.request(
      '/media/record/check',
      data: checksums,
      options: Options(
        method: 'POST',
        contentType: Headers.jsonContentType,
      ),
    );

    return ModelList(
      List<Record>.from(
        response.data.map(
          (item) {
            var rec = Record.fromJson(item);
            return rec;
          },
        ),
      ),
      0,
      response.data.length,
    );
  }

  /// Returns a list of record folder group with the amount of [take] that match the given
  /// [filter] starting from the [offset].
  Future<ModelList> getRecordsFolder(
    String? filter,
    int? offset,
    int? take,
    ID3TagFilter subfilter,
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

    var response = await _apiService.request(
      '/media/record/listFolder',
      queryParameters: params,
      data: subfilter.toJson(),
      options: Options(
        method: 'POST',
      ),
    );

    return ModelList(
      List<RecordFolder>.from(
        response.data['items'].map(
          (item) => RecordFolder.fromJson(item),
        ),
      ),
      offset ?? 0,
      response.data["totalCount"],
    );
  }
}
