import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_planner/core/storage/prefs_keys.dart';
import 'package:travel_planner/features/settings/presentation/settings_cubit.dart';

void main() {
  test('load() defaults to system theme and onboarding not done', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final cubit = SettingsCubit(prefs: prefs);

    await cubit.load();

    expect(cubit.state.themeMode, ThemeMode.system);
    expect(cubit.state.onboardingDone, isFalse);
    await cubit.close();
  });

  test('setThemeMode persists across instances', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final a = SettingsCubit(prefs: prefs);

    await a.load();
    await a.setThemeMode(ThemeMode.dark);
    expect(a.state.themeMode, ThemeMode.dark);

    final b = SettingsCubit(prefs: prefs);
    await b.load();
    expect(b.state.themeMode, ThemeMode.dark);

    await a.close();
    await b.close();
  });

  test('markOnboardingDone persists', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final cubit = SettingsCubit(prefs: prefs);

    await cubit.load();
    await cubit.markOnboardingDone();

    expect(cubit.state.onboardingDone, isTrue);
    expect(prefs.getBool(PrefsKeys.onboardingDone), isTrue);
    await cubit.close();
  });
}
