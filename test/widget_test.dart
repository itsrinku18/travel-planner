import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:travel_planner/core/di/injection_container.dart';
import 'package:travel_planner/core/storage/prefs_keys.dart';
import 'package:travel_planner/main.dart';

void main() {
  setUp(() async {
    // Skip onboarding so the HomePage is the immediate root.
    SharedPreferences.setMockInitialValues({PrefsKeys.onboardingDone: true});
    await sl.reset();
    await initDependencies();
  });

  testWidgets('App boots and shows all five navigation labels', (
    WidgetTester tester,
  ) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await tester.pumpWidget(const TravelPlannerApp());
    await tester.pumpAndSettle();

    expect(find.text('Explore'), findsWidgets);
    expect(find.text('Planner'), findsWidgets);
    expect(find.text('Experiences'), findsWidgets);
    expect(find.text('Saved'), findsWidgets);
    expect(find.text('Profile'), findsWidgets);
  });

  testWidgets('Discovery tab shows hero copy', (WidgetTester tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await tester.pumpWidget(const TravelPlannerApp());
    await tester.pumpAndSettle();

    expect(find.text('Discover your next trip'), findsOneWidget);
  });

  testWidgets('Switching to Planner tab shows the New trip button', (
    WidgetTester tester,
  ) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await tester.pumpWidget(const TravelPlannerApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Planner').first);
    await tester.pumpAndSettle();

    expect(
      find.widgetWithText(FloatingActionButton, 'New trip'),
      findsOneWidget,
    );
  });

  testWidgets('Onboarding shows on first launch when flag is unset', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await sl.reset();
    await initDependencies();

    TestWidgetsFlutterBinding.ensureInitialized();
    await tester.pumpWidget(const TravelPlannerApp());
    await tester.pumpAndSettle();

    expect(find.text('Discover places you’ll love'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
  });
}
