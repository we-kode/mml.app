/// An active share link of the user. The secret token is not part of it, so the
/// link itself can not be shown again.
class ShareLinkInfo {
  /// Id of the link.
  final String id;

  /// Date when the link was created.
  final DateTime createdAt;

  /// Date when the link expires.
  final DateTime expiresAt;

  /// Whether the link can be used only once.
  final bool singleUse;

  /// Number of the records of the link.
  final int recordCount;

  /// Initializes the link.
  const ShareLinkInfo({
    required this.id,
    required this.createdAt,
    required this.expiresAt,
    required this.singleUse,
    required this.recordCount,
  });

  /// Converts a json object/map to the model.
  factory ShareLinkInfo.fromJson(Map<String, dynamic> json) => ShareLinkInfo(
    id: json['id'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    expiresAt: DateTime.parse(json['expiresAt'] as String),
    singleUse: json['singleUse'] as bool,
    recordCount: json['recordCount'] as int,
  );
}
