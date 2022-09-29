/// Double extensions, that allows to convert double milliseconds to [Duration]
/// objects or formatted duration strings.
extension DurationDouble on double {
  /// Formats a double duration to a formatted string.
  String asFormattedDuration() {
    int seconds = ((this / 1000) % 60).toInt();
    int minutes = ((this / (1000 * 60)) % 60).toInt();
    int hours = ((this / (1000 * 60 * 60)) % 24).toInt();
    return "${_valueString(hours)}:${_valueString(minutes)}:${_valueString(seconds)}";
  }

  /// Converts a double duration to a [Duration] object.
  Duration asDuration() {
    int seconds = ((this / 1000) % 60).toInt();
    int minutes = ((this / (1000 * 60)) % 60).toInt();
    int hours = ((this / (1000 * 60 * 60)) % 24).toInt();
    return Duration(seconds: seconds, minutes: minutes, hours: hours,);
  }

  /// Adds a 0 before [value] if [value] is smaller than ten.
  String _valueString(int value) {
    return value < 10 ? "0$value" : "$value";
  }
}
