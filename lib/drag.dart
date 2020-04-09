import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:math';

/// State manager that holds all the individual drags.
class DragState {
  List<_Drag> _drags;
  void Function(double distance) _onUpdateDrag;
  void Function() _onCommitDrag;
  bool _increase;

  DragState(this._onUpdateDrag, this._onCommitDrag)
      : _drags = [],
        _increase = true;

  int get dragCount => _drags.length;

  /// Creates and keeps track of an additional drag.
  ///
  /// Returns the newly created drag.
  Drag addDrag(double scale) {
    if (_drags.firstWhere((drag) => !drag.active, orElse: () => null) != null) {
      _drags.clear();
    }
    var dragState = _Drag(_onDrag);
    _drags.add(dragState);
    for (var drag in _drags) {
      drag.scale = scale;
    }
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
  double _distance;
  double _scale;
  bool _active;
  void Function() _updateDragState;

  _Drag(this._updateDragState)
      : _distance = 0,
        _active = true;

  bool get active => _active;

  set scale(double scale) => _scale = scale;

  @override
  void cancel() => _completeDrag();

  @override
  void end(DragEndDetails details) => _completeDrag();

  @override
  void update(DragUpdateDetails details) {
    _active = true;
    _distance -= details.delta.dy * _scale;
    _updateDragState();
  }

  void _completeDrag() {
    _active = false;
    _updateDragState();
    _distance = 0;
  }
}
