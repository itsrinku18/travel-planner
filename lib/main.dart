import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_planner/core/di/injection_container.dart';
import 'package:travel_planner/core/theme/app_theme.dart';
import 'package:travel_planner/features/discovery/presentation/discovery_cubit.dart';
import 'package:travel_planner/features/onboarding/presentation/onboarding_page.dart';
import 'package:travel_planner/features/settings/presentation/settings_cubit.dart';
import 'package:travel_planner/features/travel_engine/presentation/bloc/experience_cubit.dart';
import 'package:travel_planner/features/travel_engine/presentation/bloc/trip_extras_cubit.dart';
import 'package:travel_planner/features/travel_engine/presentation/bloc/trips_cubit.dart';
import 'package:travel_planner/features/travel_engine/presentation/pages/home_page.dart';
import 'package:travel_planner/features/wishlist/presentation/wishlist_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const TravelPlannerApp());
}

class TravelPlannerApp extends StatelessWidget {
  const TravelPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<SettingsCubit>()),
        BlocProvider.value(value: sl<WishlistCubit>()),
        BlocProvider.value(value: sl<DiscoveryCubit>()),
        BlocProvider.value(value: sl<TripsCubit>()),
        BlocProvider.value(value: sl<ExperienceCubit>()),
        BlocProvider.value(value: sl<TripExtrasCubit>()),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settings) {
          return MaterialApp(
            title: 'Travel Planning & Experience Engine',
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: settings.themeMode,
            debugShowCheckedModeBanner: false,
            home:
                settings.onboardingDone
                    ? const HomePage()
                    : OnboardingPage(
                      onDone: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const HomePage()),
                        );
                      },
                    ),
          );
        },
      ),
    );
  }
}
