import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_planner/core/storage/prefs_keys.dart';

class SettingsState extends Equatable {
  const SettingsState({required this.themeMode, required this.onboardingDone});

  final ThemeMode themeMode;
  final bool onboardingDone;

  static const initial = SettingsState(
    themeMode: ThemeMode.system,
    onboardingDone: false,
  );

  SettingsState copyWith({ThemeMode? themeMode, bool? onboardingDone}) =>
      SettingsState(
        themeMode: themeMode ?? this.themeMode,
        onboardingDone: onboardingDone ?? this.onboardingDone,
      );

  @override
  List<Object?> get props => [themeMode, onboardingDone];
}

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({required SharedPreferences prefs})
    : _prefs = prefs,
      super(SettingsState.initial);

  final SharedPreferences _prefs;

  Future<void> load() async {
    final raw = _prefs.getString(PrefsKeys.themeMode);
    final mode = switch (raw) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    final done = _prefs.getBool(PrefsKeys.onboardingDone) ?? false;
    emit(state.copyWith(themeMode: mode, onboardingDone: done));
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setString(PrefsKeys.themeMode, mode.name);
    emit(state.copyWith(themeMode: mode));
  }

  Future<void> markOnboardingDone() async {
    await _prefs.setBool(PrefsKeys.onboardingDone, true);
    emit(state.copyWith(onboardingDone: true));
  }
}
