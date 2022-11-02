import 'package:flutter/material.dart';

/// Subfilter model, which can be extended by specific filters.
abstract class Subfilter extends ChangeNotifier {
  /// True, if the view should be grouped.
  bool isGrouped = false;
}
