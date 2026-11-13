/// Result of the check, how many of the selected records can be shared.
class ShareCheck {
  /// Largest number of records in one link, as long as the server does not
  /// tell another limit.
  static const int defaultLimit = 200;

  /// Number of the records the user is allowed to share.
  final int shareable;

  /// Number of the selected records, including the records of folders.
  final int total;

  /// Largest number of records in one link.
  final int limit;

  /// Ids of the explicitly selected records the user is allowed to share.
  final List<String> shareableRecords;

  /// Initializes the result.
  const ShareCheck({
    this.shareable = 0,
    this.total = 0,
    this.limit = defaultLimit,
    this.shareableRecords = const [],
  });

  /// Converts a json object/map to the model.
  factory ShareCheck.fromJson(Map<String, dynamic> json) => ShareCheck(
    shareable: json['shareable'] as int? ?? 0,
    total: json['total'] as int? ?? 0,
    limit: json['limit'] as int? ?? defaultLimit,
    shareableRecords: List<String>.from(json['shareableRecords'] ?? []),
  );

  /// Whether some, but not all of the selected records can be shared.
  bool get isPartial => shareable > 0 && shareable < total;

  /// Whether more records can be shared than fit into one link.
  bool get isTooLarge => shareable > limit;
}
