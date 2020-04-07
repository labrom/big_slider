import 'package:big_slider/slider.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('The widget is inserted.', (tester) async {
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: BigSlider(<TouchType, ValueDescriptor>{}, null),
    ));
    expect(find.byType(BigSlider), findsOneWidget);
    expect(find.text(''), findsNWidgets(2));
  });

  testWidgets(
      'A value is displayed without a label when the descriptor has no name'
      ' and a drag gesture is performed.', (tester) async {
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: BigSlider(<TouchType, ValueDescriptor>{
        TouchType.oneFinger: ValueDescriptor(initialValue: 0),
      }, (type, value) => print('Value: $value')),
    ));
    await tester.drag(find.byType(BigSlider), Offset(0, -1));
    await tester.pumpAndSettle();
    expect(find.text('1'), findsOneWidget);
    expect(find.text(''), findsOneWidget);
  });

  testWidgets(
      'A value is displayed with a label when the descriptor has a name'
      ' and a drag gesture is performed.', (tester) async {
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: BigSlider(<TouchType, ValueDescriptor>{
        TouchType.oneFinger: ValueDescriptor(initialValue: 0, name: "throttle"),
      }, (type, value) => print('Value: $value')),
    ));
    await tester.drag(find.byType(BigSlider), Offset(0, -1));
    await tester.pumpAndSettle();
    expect(find.text('1'), findsOneWidget);
    expect(find.text('throttle'), findsOneWidget);
  });

  testWidgets(
      'Value 0 is displayed with a label when the descriptor has a name'
      ' and a horizontal drag gesture is performed.', (tester) async {
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: BigSlider(<TouchType, ValueDescriptor>{
        TouchType.oneFinger: ValueDescriptor(initialValue: 0, name: "throttle"),
      }, (type, value) => print('Value: $value')),
    ));
    await tester.drag(find.byType(BigSlider), Offset(1, 0));
    await tester.pumpAndSettle();
    expect(find.text('0'), findsOneWidget);
    expect(find.text('throttle'), findsOneWidget);
  });

  testWidgets(
      'A positive value is displayed when a drag up gesture is performed.',
          (tester) async {
        await tester.pumpWidget(Directionality(
          textDirection: TextDirection.ltr,
          child: BigSlider(<TouchType, ValueDescriptor>{
            TouchType.oneFinger: ValueDescriptor(initialValue: 0),
          }, (type, value) => print('Value: $value')),
        ));
        await tester.drag(find.byType(BigSlider), Offset(0, -1));
        await tester.pumpAndSettle();
        expect(find.text('1'), findsOneWidget);
      });

  testWidgets(
      'A negative value is displayed when a drag down gesture is performed.',
      (tester) async {
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: BigSlider(<TouchType, ValueDescriptor>{
        TouchType.oneFinger: ValueDescriptor(initialValue: 0),
      }, (type, value) => print('Value: $value')),
    ));
    await tester.drag(find.byType(BigSlider), Offset(0, 1));
    await tester.pumpAndSettle();
    expect(find.text('-1'), findsOneWidget);
  });
}
