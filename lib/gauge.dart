import 'package:flutter/widgets.dart';

class Gauge extends StatelessWidget {
  final Color lowColor = Color(0xFF0010F0);
  final Color highColor = Color(0xFFF00010);
  final double value;

  Gauge(this.value);

  @override
  Widget build(BuildContext context) => Container(
        color: Color(0x30000000),
        child: CustomPaint(
          painter: _Painter(value ?? 0, lowColor, highColor),
        ),
      );
}

class _Painter extends CustomPainter {
  final Color _lowColor;
  final Color _highColor;
  final double _value;
  final int _segments = 10;

  _Painter(this._value, this._lowColor, this._highColor);

  @override
  void paint(Canvas canvas, Size size) {
    var segmentsToDraw = (_segments * _value).round();
    var space = 2;
    double segmentHeight = size.height /
        _segments *
        size.height /
        (size.height + space * (_segments + 1));

    for (var i = 1; i <= segmentsToDraw; i++) {
      int red = (_lowColor.red +
              (i - 1) * (_highColor.red - _lowColor.red) / (_segments - 1))
          .round();
      int green = (_lowColor.green +
              (i - 1) * (_highColor.green - _lowColor.green) / (_segments - 1))
          .round();
      int blue = (_lowColor.blue +
              (i - 1) * (_highColor.blue - _lowColor.blue) / (_segments - 1))
          .round();
      Color segmentColor = Color.fromARGB(255, red, green, blue);
      canvas.drawRect(
        Rect.fromLTWH(
            0,
            (_segments - i) * segmentHeight + (_segments - i + 1) * space,
            size.width,
            segmentHeight),
        Paint()
          ..color = segmentColor
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
