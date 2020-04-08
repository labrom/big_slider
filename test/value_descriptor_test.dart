import 'package:big_slider/slider.dart';
import 'package:test/test.dart';

void main() {
  test('Snap to increments of 5.', () {
    var descriptor = ValueDescriptor(increment: 5);
    expect(descriptor.snapValue(0), 0);
    expect(descriptor.snapValue(2), 0);
    expect(descriptor.snapValue(3), 5);
    expect(descriptor.snapValue(5), 5);
    expect(descriptor.snapValue(7), 5);
    expect(descriptor.snapValue(-2), 0);
    expect(descriptor.snapValue(-3), -5);
    expect(descriptor.snapValue(-5), -5);
    expect(descriptor.snapValue(-7), -5);
  });

  test('Initial value has no bearing on values.', () {
    var descriptor = ValueDescriptor(increment: 5, initialValue: 10);
    expect(descriptor.snapValue(0), 0);
    expect(descriptor.snapValue(2), 0);
    expect(descriptor.snapValue(3), 5);
    expect(descriptor.snapValue(5), 5);
    expect(descriptor.snapValue(7), 5);
    expect(descriptor.snapValue(-2), 0);
    expect(descriptor.snapValue(-3), -5);
    expect(descriptor.snapValue(-5), -5);
    expect(descriptor.snapValue(-7), -5);
  });

  test('Snap to increments of 0.5.', () {
    var descriptor = ValueDescriptor(increment: 0.5);
    expect(descriptor.snapValue(0), 0);
    expect(descriptor.snapValue(0.2), 0);
    expect(descriptor.snapValue(0.3), 0.5);
    expect(descriptor.snapValue(0.5), 0.5);
    expect(descriptor.snapValue(0.7), 0.5);
    expect(descriptor.snapValue(-.2), 0);
    expect(descriptor.snapValue(-0.3), -0.5);
    expect(descriptor.snapValue(-0.5), -0.5);
    expect(descriptor.snapValue(-0.7), -0.5);
  });
}
