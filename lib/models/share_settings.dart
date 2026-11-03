/// Server settings that control the share links of clients.
class ShareSettings {
  /// Whether clients choose validity and usage of their links themselves.
  final bool userSettingsAllowed;

  /// Initializes the settings.
  const ShareSettings({this.userSettingsAllowed = false});

  /// Converts a json object/map to the model.
  factory ShareSettings.fromJson(Map<String, dynamic> json) =>
      ShareSettings(userSettingsAllowed: json['userSettingsAllowed'] == true);
}
