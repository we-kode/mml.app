import 'dart:collection';
import 'dart:math';

import 'package:mml_app/models/model_base.dart';


/// A lazy list of models.
class ModelList extends ListBase<ModelBase?> {
  /// List containing the models at the specified offset with a specified
  /// length.
  ///
  /// In the indices before the offset and after offset + length of data null
  /// will be set, since the data at this indices the data is not loaded.
  List<ModelBase?> _l = [];

  /// Total length of the model list, not only the loaded data length.
  int totalCount;

  /// Instantiates the lazy model list.
  ///
  /// Creates a list with a length of [totalCount] and sets the passed [data]
  /// in the list starting at [offset].
  /// If the length of the [data] exceeds the [totalCount], the exceeding [data]
  /// will be dropped.
  ModelList(List<ModelBase> data, int offset, this.totalCount) {
    _l = [];
    _l.length = totalCount;
    _l.replaceRange(offset, min(_l.length, offset + data.length), data);
  }

  @override
  set length(int newLength) {
    throw UnimplementedError();
  }

  @override
  int get length => _l.length;

  @override
  ModelBase? operator [](int index) => _l[index];

  @override
  void operator []=(int index, ModelBase? value) {
    throw UnimplementedError();
  }
}
