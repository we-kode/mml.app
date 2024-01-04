import 'package:flutter/material.dart';
import 'package:mml_app/models/subfilter.dart';

/// A subfilter view for the [AsyncListView].
abstract class ListSubfilterView extends StatelessWidget {
  /// [Subfilter] associated with this view.
  final Subfilter filter;

  /// Initializes the [ListSubfilterView] with the specific [filter].
  const ListSubfilterView({
    super.key,
    required this.filter,
  });
}
