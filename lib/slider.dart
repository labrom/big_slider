library big_slider;

import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// The different touch interactions that can be used to update different values.
enum TouchType { oneFinger, twoFinger, threeFinger, fourFinger, fiveFinger }

/// Descriptor for a given type of value.
class ValueDescriptor {
  final double initialValue;
  final double maxValue;
  final double minValue;
  final double increment;
  final String name;

  ValueDescriptor({
    this.initialValue,
    this.maxValue,
    this.minValue,
    this.increment,
    this.name,
  });
}

/// A value listener function that receives updates for different values.
typedef ValueListener = void Function(TouchType, double);

/// A slider widget that can handle multiple independent values using multi-touch.
class BigSlider extends StatefulWidget {
  final List<double> _values;
  final List<ValueDescriptor> _descriptors;
  final ValueListener _listener;

  BigSlider(Map<TouchType, ValueDescriptor> descriptors, this._listener)
      : _values = List(descriptors.length),
        _descriptors = List(descriptors.length) {
    for (var entry in descriptors.entries) {
      _values[entry.key.index] = entry.value.initialValue;
      _descriptors[entry.key.index] = entry.value;
    }
  }

  @override
  State<StatefulWidget> createState() => _BigSliderState();

  void _incrementValue(int fingers, double increment) =>
      _values[fingers - 1] += increment;
}

class _BigSliderState extends State<BigSlider> {
  double _valueChange = 0;
  int _fingers = 0;
  _DragState _state;

  @override
  Widget build(BuildContext context) {
    _state = _DragState(_updateValue, _commitValue);
    return RawGestureDetector(
      gestures: <Type, GestureRecognizerFactory>{
        VerticalMultiDragGestureRecognizer: _verticalMultiDragGestureFactory,
      },
      child: _body,
    );
  }

  GestureRecognizerFactory get _verticalMultiDragGestureFactory =>
      GestureRecognizerFactoryWithHandlers<VerticalMultiDragGestureRecognizer>(
        () => VerticalMultiDragGestureRecognizer(),
        (instance) => instance.onStart = _onDragStart,
      );

  Drag _onDragStart(Offset offset) {
    var newDrag = _state.addDrag();
    setState(() {
      _fingers = _state.dragCount;
    });
    return newDrag;
  }

  Widget get _body => Container(
        color: Colors.amber,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_valueDisplay),
            Text(_nameDisplay),
          ],
        ),
      );

  String get _nameDisplay =>
      _fingers > 0 ? widget._descriptors[_fingers - 1].name : '';

  String get _valueDisplay => _fingers > 0
      ? (widget._values[_fingers - 1] + _valueChange).round().toString()
      : '';

  void _updateValue(double distance) {
    setState(() {
      _valueChange = distance;
    });
    widget._listener(TouchType.values[_fingers - 1],
        widget._values[_fingers - 1] + _valueChange);
  }

  void _commitValue() {
    widget._incrementValue(_fingers, _valueChange);
    _valueChange = 0;
    setState(() {
      _fingers = 0;
    });
  }
}

/// State manager that holds all the individual drags.
class _DragState {
  List<_Drag> _drags = [];
  void Function(double distance) _onUpdateDrag;
  void Function() _onCommitDrag;
  bool _increase = true;

  _DragState(this._onUpdateDrag, this._onCommitDrag);

  int get dragCount => _drags.length;

  /// Creates and keeps track of an additional drag.
  ///
  /// Returns the newly created drag.
  Drag addDrag() {
    if (_drags.firstWhere((drag) => !drag.active, orElse: () => null) != null) {
      _drags.clear();
    }
    var dragState = _Drag(_updateDrag);
    _drags.add(dragState);
    return dragState;
  }

  void _updateDrag() {
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
