import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'client_registration.g.dart';

/// Client model that holds all information of a client.
@JsonSerializable(includeIfNull: false)
class ClientRegistration {
  ///
  final String token;

  ///
  final String serverName;

  ///
  final String appKey;

  /// Creates a new client instance with the given values.
  ClientRegistration({
    required this.token,
    required this.serverName,
    required this.appKey,
  });

  /// Converts a json object/map to the client model.
  factory ClientRegistration.fromJson(Map<String, dynamic> json) =>
      _$ClientRegistrationFromJson(json);

  /// Converts the current client model to a json object/map.
  Map<String, dynamic> toJson() => _$ClientRegistrationToJson(this);

  ///
  @override
  String toString() {
    try {
      return base64Encode(utf8.encode(jsonEncode(toJson())));
    } on FormatException catch (_) {
      return "";
    }
  }

  ///
  static ClientRegistration? fromString(String value) {
    try {
      Map<String, dynamic> json = jsonDecode(utf8.decode(base64Decode(value)));

      if (!json.keys.toSet().containsAll({'token', 'serverName', 'appKey'})) {
        return null;
      }

      return ClientRegistration.fromJson(json);
    } on FormatException catch (_) {
      return null;
    }
  }
}
