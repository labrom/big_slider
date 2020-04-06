library big_slider;

import 'drag.dart';
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
  DragState _state;

  @override
  Widget build(BuildContext context) {
    _state = DragState(_updateValue, _commitValue);
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
