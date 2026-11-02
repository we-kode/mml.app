import 'package:json_annotation/json_annotation.dart';

part 'announcement.g.dart';

/// Message of the admins, e.g. an announcement of a maintenance.
@JsonSerializable(createToJson: false)
class Announcement {
  /// Id of the announcement.
  final String notificationId;

  /// Title of the announcement.
  final String title;

  /// Plain text message of the announcement.
  final String message;

  /// Severity of the announcement, see [AnnouncementSeverity].
  final int severity;

  /// End of the validity or null, if it is valid until it is deleted.
  final DateTime? validTo;

  /// Time of the last change.
  final DateTime updatedAt;

  /// Initializes the model.
  Announcement({
    required this.notificationId,
    required this.title,
    required this.message,
    required this.severity,
    required this.updatedAt,
    this.validTo,
  });

  /// Converts a json object/map to the model.
  factory Announcement.fromJson(Map<String, dynamic> json) =>
      _$AnnouncementFromJson(json);

  /// Version of the announcement, which changes when the admin edits it.
  String get version => '$notificationId@${updatedAt.toIso8601String()}';
}
