import 'package:material_ui/material_ui.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Severities of an announcement.
abstract class AnnouncementSeverity {
  /// General information.
  static const int info = 1;

  /// Announcement of a maintenance.
  static const int maintenance = 2;

  /// Important message.
  static const int important = 3;

  /// Returns the icon of the [severity].
  static IconData icon(int severity) {
    return switch (severity) {
      maintenance => Symbols.construction,
      important => Symbols.priority_high,
      _ => Symbols.info,
    };
  }

  /// Returns the color of the [severity], so the severities can be told apart
  /// at a glance.
  static Color color(int severity, ThemeData theme) {
    return switch (severity) {
      maintenance => Colors.orange,
      important => theme.colorScheme.error,
      _ => theme.colorScheme.primary,
    };
  }
}
