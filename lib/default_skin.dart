import 'dart:math';

import 'package:big_slider/slider.dart';
import 'package:flutter/widgets.dart';

SkinBuilder defaultSkinBuilder(Map<TouchType, ValueDescriptor> descriptors) =>
    (TouchType activeTouch, Map<TouchType, double> values) {
      return _DefaultSkin(
        activeValueText:
            _valueDisplay(values[activeTouch], descriptors[activeTouch]),
        activeValueLevel: _ValueLevel(
            descriptors[activeTouch]?.valueRatio(values[activeTouch])),
        medallions: List.from(descriptors.entries.map(
          (entry) => _Medallion(
            active: entry.key == activeTouch,
            label: entry.value.name ?? '',
            fingers: entry.key.index + 1,
            value: _valueDisplay(values[entry.key], entry.value),
          ),
        )),
      );
    };

String _valueDisplay(double value, ValueDescriptor descriptor) =>
    value != null ? _pack(descriptor.snapValue(value)).toString() : '';

num _pack(double value) => value == value.floor() ? value.floor() : value;

class _DefaultSkin extends StatelessWidget {
  final String activeValueText;
  final _ValueLevel activeValueLevel;
  final List<_Medallion> medallions;

  _DefaultSkin({
    this.activeValueText,
    this.activeValueLevel,
    this.medallions,
  });

  @override
  Widget build(BuildContext context) => Container(
        color: Color(0xFFFFFFFF),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Flexible(
              flex: 1,
              child: activeValueLevel,
            ),
            Expanded(
              flex: 7,
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: medallions,
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        activeValueText,
                        style: TextStyle(fontSize: 120),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _Medallion extends StatelessWidget {
  final bool active;
  final String label;
  final String value;
  final int fingers;

  const _Medallion({this.active, this.label, this.value, this.fingers});
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              style: BorderStyle.solid,
              width: 1,
            ),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: active ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontStyle: FontStyle.italic,
                  fontWeight: active ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      );
}

class _ValueLevel extends StatelessWidget {
  /// Minimum height factor as it cannot be 0.
  static const _minHeightFactor = 0.0001;

  final double _ratio;

  _ValueLevel(this._ratio);

  @override
  Widget build(BuildContext context) => FractionallySizedBox(
        widthFactor: 1,
        heightFactor: max(_ratio ?? _minHeightFactor, _minHeightFactor),
        child: Container(
          color: Color(0x99000000),
        ),
      );
}
