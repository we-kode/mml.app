import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'client_registration.g.dart';

/// Client model that holds all information of a client.
@JsonSerializable(includeIfNull: false)
class ClientRegistration {
  /// Token for the running registration.
  final String token;

  /// Endpoint to which the registration request should be sent.
  final String endpoint;

  /// Key which should be passed during requests.
  final String appKey;

  /// Creates a new client instance with the given values.
  ClientRegistration({
    required this.token,
    required this.endpoint,
    required this.appKey,
  });

  /// Converts a json object/map to the client model.
  factory ClientRegistration.fromJson(Map<String, dynamic> json) =>
      _$ClientRegistrationFromJson(json);

  /// Converts the current client model to a json object/map.
  Map<String, dynamic> toJson() => _$ClientRegistrationToJson(this);

  /// Converts the model to a base64 string.
  ///
  /// An empty string gets returned if an error occurs during conversion.
  @override
  String toString() {
    try {
      return base64Encode(utf8.encode(jsonEncode(toJson())));
    } on FormatException catch (_) {
      return "";
    }
  }

  /// Tries to convert the passed [value] encoded in base64 to the model object.
  ///
  /// If an error occurs during conversion null will be returned.
  static ClientRegistration? fromString(String value) {
    try {
      Map<String, dynamic> json = jsonDecode(utf8.decode(base64Decode(value)));

      if (!json.keys.toSet().containsAll({'token', 'endpoint', 'appKey'})) {
        return null;
      }

      return ClientRegistration.fromJson(json);
    } on FormatException catch (_) {
      return null;
    }
  }
}
