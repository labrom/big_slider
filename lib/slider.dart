library big_slider;

import 'dart:math';

import 'package:big_slider/default_skin.dart';

import 'drag.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// A slider widget that can handle multiple independent values using different
/// multi-touch vertical drag gestures.
///
/// The widget is built using a map of touch gesture types (as in: the number of
/// pointers or fingers) and value descriptors.
class BigSlider extends StatefulWidget {
  final List<double> _values;
  final List<ValueDescriptor> _descriptors;
  final ValueListener _listener;
  final SkinBuilder _builder;

  BigSlider(Map<TouchType, ValueDescriptor> descriptors, this._listener,
      {SkinBuilder builder})
      : _values = List(TouchType.values.length),
        _descriptors = List(TouchType.values.length),
        _builder = builder ?? defaultSkinBuilder(descriptors) {
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

/// A builder function for displaying the widget with its values.
///
/// The 'TouchType' is the current value, it is null if no
/// value is currently being adjusted.
/// The map contains the current values for all the supported touch gestures.
typedef SkinBuilder = Widget Function(TouchType, Map<TouchType, double>);

/// A value listener function that receives updates for different values.
///
/// A value listener must be provided to the widget in order to receive value updates.
/// When a values are adjusted, the listener will received the updated values,
/// along with the type of touch gesture the value is associated to.
typedef ValueListener = void Function(TouchType, double);

/// The different touch interactions that can be used to update different values.
enum TouchType { oneFinger, twoFinger, threeFinger, fourFinger, fiveFinger }

/// Descriptor for a given type of value.
class ValueDescriptor {
  final double initialValue;
  final double maxValue;
  final double minValue;
  final double increment;
  final double scale;
  final String name;

  ValueDescriptor({
    this.initialValue = 0,
    this.maxValue,
    this.minValue,
    this.increment = 1,
    this.scale = 1,
    this.name,
  }) {
    _validate();
  }

  void _validate() {
    if (minValue != null && minValue > initialValue)
      throw FormatException(
          'minValue must be smaller than or equal to initialValue');
    if (maxValue != null && maxValue < initialValue)
      throw Exception('maxValue must be greater than or equal to initialValue');
    if (increment != null) {
      if ((initialValue / increment).floor() != initialValue / increment)
        throw Exception('initialValue must be a multiple of increment');
      if (minValue != null &&
          (minValue / increment).floor() != minValue / increment)
        throw Exception('minValue must be a multiple of increment');
      if (maxValue != null &&
          (maxValue / increment).floor() != maxValue / increment)
        throw Exception('maxValue must be a multiple of increment');
      if (scale == 0) throw Exception('scale must be different from 0');
      if (scale != null && (increment / scale).floor() != increment / scale)
        throw Exception('increment must be a multiple of scale');
    }
  }

  /// Snaps 'value' to the closest increment of this descriptor.
  ///
  /// If this descriptor doesn't have increments, this function returns 'value' unchanged.
  double snapValue(double value) {
    if (increment != null) {
      return ((value / increment).floor() +
              ((value % increment) / increment).round()) *
          increment;
    }
    return value;
  }

  /// Indicates what proportion (from 0 to 1) of this descriptor's range 'value' is.
  ///
  /// For example, if this descriptor's minimum value is 0 and its maximum value is 10,
  /// this function will return 0.8 for 'value' = 8.
  /// This is useful for drawing a range indicator in the widget.
  /// If this descriptor doesn't have a minimum value and a maximum value,
  /// this function always returns 0. It also returns 0 if 'value' is null.
  double valueRatio(double value) {
    if (value != null && maxValue != null && minValue != null) {
      return max(0, min(1, (value - minValue) / (maxValue - minValue)));
    }
    return 0;
  }
}

class _BigSliderState extends State<BigSlider> {
  double _valueChange;
  int _fingers;
  bool _display;
  DragState _state;

  @override
  void initState() {
    _valueChange = 0;
    _fingers = 0;
    _display = false;
    _state = DragState(_updateValue, _commitValue);
    super.initState();
  }

  @override
  Widget build(BuildContext context) => RawGestureDetector(
        gestures: <Type, GestureRecognizerFactory>{
          VerticalMultiDragGestureRecognizer: _verticalMultiDragGestureFactory,
        },
        child: widget._builder(_touchType, _valuesByType),
      );

  GestureRecognizerFactory get _verticalMultiDragGestureFactory =>
      GestureRecognizerFactoryWithHandlers<VerticalMultiDragGestureRecognizer>(
        () => VerticalMultiDragGestureRecognizer(),
        (instance) => instance.onStart = _onDragStart,
      );

  Drag _onDragStart(Offset offset) {
    // Getting the scale from the descriptor of current drag count + 1.
    // It might not be an actual touch gesture, in which case the scale is null.
    var scale = widget._descriptors[_state.dragCount]?.scale;
    var newDrag = _state.addDrag(scale);
    setState(() {
      _display = scale != null;
      _fingers = _state.dragCount;
    });
    return newDrag;
  }

  TouchType get _touchType =>
      _display && widget._descriptors[_fingers - 1] != null
          ? TouchType.values[_fingers - 1]
          : null;

  Map<TouchType, double> get _valuesByType {
    var valuesByType = <TouchType, double>{};
    for (var i = 0; i < widget._values.length; i++) {
      var value = widget._values[i];
      if (value != null) {
        // If this value is the one being adjusted, add up the value change.
        if (i == _fingers - 1) {
          value += _valueChange;
        }
        valuesByType[TouchType.values[i]] = value;
      }
    }
    return valuesByType;
  }

  /// Updates the value as it's being changed using the corresponding drag gesture.
  void _updateValue(double distance) {
    if (!_validateTouch()) return;

    var previousValueChange = _valueChange;
    _valueChange = distance;
    var max = widget._descriptors[_fingers - 1].maxValue;
    var min = widget._descriptors[_fingers - 1].minValue;
    var newValue = widget._values[_fingers - 1] + _valueChange;
    if (max != null && newValue > max) {
      _valueChange -= newValue - max;
    }
    if (min != null && newValue < min) {
      _valueChange += min - newValue;
    }

    var snappedDistance =
        widget._descriptors[_fingers - 1].snapValue(_valueChange);
    var previousSnappedDistance =
        widget._descriptors[_fingers - 1].snapValue(previousValueChange);
    if (snappedDistance != previousSnappedDistance) {
      setState(() {});
      widget._listener(TouchType.values[_fingers - 1],
          widget._values[_fingers - 1] + snappedDistance);
    }
  }

  /// Updates the widget's value at the end of a given drag gesture.
  ///
  /// The system is also reset so that another (or the same) value can be adjusted
  /// using another drag gesture.
  void _commitValue() {
    if (!_validateTouch()) return;

    widget._incrementValue(
        _fingers, widget._descriptors[_fingers - 1].snapValue(_valueChange));
    _valueChange = 0;
  }

  bool _validateTouch() {
    if (widget._descriptors[_fingers - 1] == null) {
      print('Invalid touch gesture: ${TouchType.values[_fingers - 1]}');
      return false;
    }
    return true;
  }
}
