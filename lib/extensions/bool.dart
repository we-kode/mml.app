/// An extension to format int value to bool
extension BoolExtended on int {
  /// Returns the name of the date.
  bool toBool() {
    return this != 0 ? true : false;
  }
}