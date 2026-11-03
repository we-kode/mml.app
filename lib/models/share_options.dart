/// Options of a share link for the download of records.
class ShareOptions {
  /// The validities in hours a user can choose from.
  static const List<int> validForHoursChoices = [1, 24, 168, 720, 2160];

  /// Validity of the link in hours.
  int validForHours;

  /// Whether the link can be used only once.
  bool singleUse;

  /// Initializes the options with the longest validity and a single use link.
  ShareOptions({this.validForHours = 2160, this.singleUse = true});
}
