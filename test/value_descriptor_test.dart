import 'package:big_slider/slider.dart';
import 'package:test/test.dart';

void main() {
  group('Invalid parameters', () {
    final failMessage = 'An Exception should have been thrown.';

    test('minValue smaller than initialValue', () {
      try {
        ValueDescriptor(minValue: 1);
        fail(failMessage);
      } catch (e) {
        expect(e.message, isNotEmpty);
      }
    });

    test('maxValue smaller than initialValue', () {
      try {
        ValueDescriptor(maxValue: -1);
        fail(failMessage);
      } catch (e) {
        expect(e.message, isNotEmpty);
      }
    });

    test('initialValue not a multiple of increment', () {
      try {
        ValueDescriptor(initialValue: 1, increment: 0.6);
        fail(failMessage);
      } catch (e) {
        expect(e.message, isNotEmpty);
      }
    });

    test('minValue not a multiple of increment', () {
      try {
        ValueDescriptor(minValue: -1, increment: 0.6);
        fail(failMessage);
      } catch (e) {
        expect(e.message, isNotEmpty);
      }
    });

    test('maxValue not a multiple of increment', () {
      try {
        ValueDescriptor(maxValue: 1, increment: 0.6);
        fail(failMessage);
      } catch (e) {
        expect(e.message, isNotEmpty);
      }
    });

    test('scale 0', () {
      try {
        ValueDescriptor(scale: 0);
        fail(failMessage);
      } catch (e) {
        expect(e.message, isNotEmpty);
      }
    });

    test('increment not a multiple of scale', () {
      try {
        ValueDescriptor(increment: 2, scale: 0.6);
        fail(failMessage);
      } catch (e) {
        expect(e.message, isNotEmpty);
      }
    });
  });

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

  test('Snap to increments of 0.5 with scale 0.5.', () {
    var descriptor = ValueDescriptor(increment: 0.5, scale: 0.5);
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

  test('Snap to increments of 0.5 with scale 0.1.', () {
    var descriptor = ValueDescriptor(increment: 0.5, scale: 0.1);
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
