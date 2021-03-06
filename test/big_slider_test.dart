import 'package:big_slider/slider.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void Function(TouchType, double) valuePrinter =
    (type, value) => print('Value: $value');

void main() {
  testWidgets('The widget is inserted.', (tester) async {
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: BigSlider(<TouchType, ValueDescriptor>{}, null),
    ));
    expect(find.byType(BigSlider), findsOneWidget);
    expect(find.text(''), findsOneWidget);
  });

  testWidgets(
      'A value is displayed without a label when the descriptor has no name'
      ' and a drag gesture is performed.', (tester) async {
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: BigSlider(<TouchType, ValueDescriptor>{
        TouchType.oneFinger: ValueDescriptor(),
      }, valuePrinter),
    ));
    await tester.drag(find.byType(BigSlider), Offset(0, -1));
    await tester.pumpAndSettle();
    expect(find.text('1'), findsNWidgets(2));
    expect(find.text(''), findsOneWidget);
  });

  testWidgets(
      'A value is displayed with a label when the descriptor has a name'
      ' and a drag gesture is performed.', (tester) async {
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: BigSlider(<TouchType, ValueDescriptor>{
        TouchType.oneFinger: ValueDescriptor(name: "throttle"),
      }, valuePrinter),
    ));
    await tester.drag(find.byType(BigSlider), Offset(0, -1));
    await tester.pumpAndSettle();
    expect(find.text('1'), findsNWidgets(2));
    expect(find.text('throttle'), findsOneWidget);
  });

  testWidgets(
      'Value 0 is displayed with a label when the descriptor has a name'
      ' and a horizontal drag gesture is performed.', (tester) async {
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: BigSlider(<TouchType, ValueDescriptor>{
        TouchType.oneFinger: ValueDescriptor(name: "throttle"),
      }, valuePrinter),
    ));
    await tester.drag(find.byType(BigSlider), Offset(1, 0));
    await tester.pumpAndSettle();
    expect(find.text('0'), findsNWidgets(2));
    expect(find.text('throttle'), findsOneWidget);
  });

  testWidgets(
      'A positive value is displayed when a drag up gesture is performed.',
      (tester) async {
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: BigSlider(<TouchType, ValueDescriptor>{
        TouchType.oneFinger: ValueDescriptor(),
      }, valuePrinter),
    ));
    await tester.drag(find.byType(BigSlider), Offset(0, -1));
    await tester.pumpAndSettle();
    expect(find.text('1'), findsNWidgets(2));
  });

  testWidgets(
      'A negative value is displayed when a drag down gesture is performed.',
      (tester) async {
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: BigSlider(<TouchType, ValueDescriptor>{
        TouchType.oneFinger: ValueDescriptor(),
      }, valuePrinter),
    ));
    await tester.drag(find.byType(BigSlider), Offset(0, 1));
    await tester.pumpAndSettle();
    expect(find.text('-1'), findsNWidgets(2));
  });

  testWidgets('A value is not reset between two drag gestures.',
      (tester) async {
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: BigSlider(<TouchType, ValueDescriptor>{
        TouchType.oneFinger: ValueDescriptor(),
      }, valuePrinter),
    ));
    await tester.drag(find.byType(BigSlider), Offset(0, -1));
    await tester.pumpAndSettle();
    expect(find.text('1'), findsNWidgets(2));
    await tester.drag(find.byType(BigSlider), Offset(0, -1));
    await tester.pumpAndSettle();
    expect(find.text('2'), findsNWidgets(2));
    await tester.drag(find.byType(BigSlider), Offset(0, 3));
    await tester.pumpAndSettle();
    expect(find.text('-1'), findsNWidgets(2));
  });

  testWidgets('A value never goes beyond the maximum or minimum.',
      (tester) async {
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: BigSlider(<TouchType, ValueDescriptor>{
        TouchType.oneFinger: ValueDescriptor(minValue: -3, maxValue: 5),
      }, valuePrinter),
    ));
    await tester.drag(find.byType(BigSlider), Offset(0, 10));
    await tester.pumpAndSettle();
    expect(find.text('-3'), findsNWidgets(2));
    await tester.drag(find.byType(BigSlider), Offset(0, -10));
    await tester.pumpAndSettle();
    expect(find.text('5'), findsNWidgets(2));
  });

  testWidgets('A value changes in increments.', (tester) async {
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: BigSlider(<TouchType, ValueDescriptor>{
        TouchType.oneFinger: ValueDescriptor(increment: 10),
      }, valuePrinter),
    ));
    await tester.drag(find.byType(BigSlider), Offset(0, -10));
    await tester.pumpAndSettle();
    expect(find.text('10'), findsNWidgets(2));
    await tester.drag(find.byType(BigSlider), Offset(0, -4));
    await tester.pumpAndSettle();
    expect(find.text('10'), findsNWidgets(2));
    await tester.drag(find.byType(BigSlider), Offset(0, -6));
    await tester.pumpAndSettle();
    expect(find.text('20'), findsNWidgets(2));
    await tester.drag(find.byType(BigSlider), Offset(0, -16));
    await tester.pumpAndSettle();
    expect(find.text('40'), findsNWidgets(2));
  });

  testWidgets('A value changes with a scale.', (tester) async {
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: BigSlider(<TouchType, ValueDescriptor>{
        TouchType.oneFinger:
            ValueDescriptor(scale: 0.1, maxValue: 3, initialValue: 1),
      }, valuePrinter),
    ));
    await tester.drag(find.byType(BigSlider), Offset(0, -10));
    await tester.pumpAndSettle();
    expect(find.text('2'), findsNWidgets(2));
    await tester.drag(find.byType(BigSlider), Offset(0, -15));
    await tester.pumpAndSettle();
    expect(find.text('3'), findsNWidgets(2));
  });
}
