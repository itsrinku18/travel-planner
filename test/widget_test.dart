// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:travel_planner/core/di/injection_container.dart';
import 'package:travel_planner/main.dart';

void main() {
  testWidgets('App boots and shows tabs', (WidgetTester tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await sl.reset();
    await initDependencies();
    await tester.pumpWidget(const TravelPlannerApp());
    await tester.pumpAndSettle();

    expect(find.text('Planner'), findsOneWidget);
    expect(find.text('Experiences'), findsOneWidget);
  });
}
