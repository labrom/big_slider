import 'package:big_slider/slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

SkinBuilder defaultSkinBuilder(Map<TouchType, ValueDescriptor> descriptors) =>
    (TouchType activeTouch, Map<TouchType, double> values) {
      return Container(
        color: Colors.amber,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(activeTouch != null
                ? _valueDisplay(values[activeTouch], descriptors[activeTouch])
                : ''),
            Text(
                activeTouch != null ? descriptors[activeTouch].name ?? '' : ''),
          ],
        ),
      );
    };

String _valueDisplay(double value, ValueDescriptor descriptor) =>
    _pack(descriptor.snapValue(value)).toString();

num _pack(double value) => value == value.floor() ? value.floor() : value;
