import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:math';

/// State manager that holds all the individual drags.
class DragState {
  List<_Drag> _drags = [];
  void Function(double distance) _onUpdateDrag;
  void Function() _onCommitDrag;
  bool _increase = true;

  DragState(this._onUpdateDrag, this._onCommitDrag);

  int get dragCount => _drags.length;

  /// Creates and keeps track of an additional drag.
  ///
  /// Returns the newly created drag.
  Drag addDrag() {
    if (_drags.firstWhere((drag) => !drag.active, orElse: () => null) != null) {
      _drags.clear();
    }
    var dragState = _Drag(_onDrag);
    _drags.add(dragState);
    return dragState;
  }

  void _onDrag() {
    if (_drags.firstWhere((drag) => !drag.active, orElse: () => null) != null) {
      _onCommitDrag();
      _drags.clear();
    } else {
      var mean = _drags.fold<double>(0, (sum, drag) => sum + drag._distance) /
          _drags.length;
      _increase = mean >= 0;
      var maxDistance = _drags.fold<double>(
          0, (distance, drag) => max<double>(distance, drag._distance.abs()));
      _onUpdateDrag(_increase ? maxDistance : -maxDistance);
    }
  }
}

/// Drag event receiver for a single drag.
class _Drag implements Drag {
  double _distance = 0;
  bool active = true;
  void Function() _updateDragState;

  _Drag(this._updateDragState);

  @override
  void cancel() => _completeDrag();

  @override
  void end(DragEndDetails details) => _completeDrag();

  @override
  void update(DragUpdateDetails details) {
    active = true;
    _distance -= details.delta.dy;
    _updateDragState();
  }

  void _completeDrag() {
    active = false;
    _updateDragState();
    _distance = 0;
  }
}
