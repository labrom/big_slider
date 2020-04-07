library big_slider;

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
  final String name;

  ValueDescriptor({
    this.initialValue,
    this.maxValue,
    this.minValue,
    this.increment,
    this.name,
  });
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
        child: _body,
      );

  GestureRecognizerFactory get _verticalMultiDragGestureFactory =>
      GestureRecognizerFactoryWithHandlers<VerticalMultiDragGestureRecognizer>(
        () => VerticalMultiDragGestureRecognizer(),
        (instance) => instance.onStart = _onDragStart,
      );

  Drag _onDragStart(Offset offset) {
    var newDrag = _state.addDrag();
    setState(() {
      _display = true;
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
      _display ? widget._descriptors[_fingers - 1].name ?? '' : '';

  String get _valueDisplay => _display
      ? (widget._values[_fingers - 1] + _valueChange).round().toString()
      : '';

  /// Updates the value as it's being changed using the corresponding drag gesture.
  void _updateValue(double distance) {
    setState(() {
      _valueChange = distance;
    });
    widget._listener(TouchType.values[_fingers - 1],
        widget._values[_fingers - 1] + _valueChange);
  }

  /// Updates the widget's value at the end of a given drag gesture.
  ///
  /// The system is also reset so that another (or the same) value can be adjusted
  /// using another drag gesture.
  void _commitValue() {
    widget._incrementValue(_fingers, _valueChange);
    _valueChange = 0;
  }
}
