// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of angular_components.model.selection.selection_model;

/// Interface for something that can be observed for selection.
abstract class SelectionObservable<T> {
  /// Synchronously deliver all [SelectionChangeRecord]s.
  ///
  /// Returns true if any records were delivered.
  bool deliverSelectionChanges();

  /// Returns true if a subscriber is listening to [selectionChanges].
  bool get hasSelectionObservers;

  /// Schedules a [SelectionChangeRecord].
  void notifySelectionChange({Iterable<T> added, Iterable<T> removed});

  /// A stream that returns changes to selected elements.
  Stream<List<SelectionChangeRecord<T>>> get selectionChanges;
}

/// Mixin for providing [SelectionModel.selectionChanges].
abstract class SelectionChangeNotifier<T> implements SelectionModel<T> {
  StreamController<List<SelectionChangeRecord<T>>>? _selectionChangeController;
  List<SelectionChangeRecord<T>>? _selectionChangeRecords;

  @override
  bool deliverSelectionChanges() {
    if (hasSelectionObservers &&
        _selectionChangeRecords != null &&
        _selectionChangeRecords!.isNotEmpty) {
      //if (hasSelectionObservers) {
      var records = UnmodifiableListView<SelectionChangeRecord<T>>(
          _selectionChangeRecords!);
      _selectionChangeRecords = null;
      if (_selectionChangeController != null) {
        _selectionChangeController!.add(records);
      }
      return true;
    } else {
      return false;
    }
  }

  @override
  void notifySelectionChange(
      {Iterable<T> added = const [], Iterable<T> removed = const []}) {
    if (hasSelectionObservers) {
      var record = SelectionChangeRecord<T>(added: added, removed: removed);
      if (_selectionChangeRecords == null) {
        _selectionChangeRecords = [];
        scheduleMicrotask(deliverSelectionChanges);
      }
      _selectionChangeRecords!.add(record);
    }
  }

  @override
  bool get hasSelectionObservers {
    return _selectionChangeController != null &&
        (_selectionChangeController?.hasListener ?? false);
  }

  @override
  Stream<List<SelectionChangeRecord<T>>> get selectionChanges {
    if (_selectionChangeController == null) {
      _selectionChangeController =
          StreamController<List<SelectionChangeRecord<T>>>.broadcast(
              sync: true);
    }
    return _selectionChangeController!.stream;
  }
}

/// Default implementation of [SelectionChangeRecord].
class _SelectionChangeRecordImpl<T> extends ChangeRecord
    implements SelectionChangeRecord<T> {
  @override
  final Iterable<T> added;

  @override
  final Iterable<T> removed;

  factory _SelectionChangeRecordImpl(
      {Iterable<T> added = const [], Iterable<T> removed = const []}) {
    var localAdded = UnmodifiableListView(added);
    var localRemoved = UnmodifiableListView(removed);
    /*    
    added = (added != null ? UnmodifiableListView(added) : const [])
        as Iterable<T>;
    removed = (removed != null ? UnmodifiableListView(removed) : const [])
        as Iterable<T>;
    */
    return _SelectionChangeRecordImpl._(localAdded, localRemoved);
  }

  _SelectionChangeRecordImpl._(this.added, this.removed);

  @override
  String toString() =>
      'SelectionChangeRecord{added: $added, removed: $removed}';
}
