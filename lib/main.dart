import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_planner/core/di/injection_container.dart';
import 'package:travel_planner/core/theme/app_theme.dart';
import 'package:travel_planner/features/travel_engine/presentation/bloc/experience_cubit.dart';
import 'package:travel_planner/features/travel_engine/presentation/bloc/trips_cubit.dart';
import 'package:travel_planner/features/travel_engine/presentation/pages/home_page.dart';

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
        BlocProvider(create: (_) => sl<TripsCubit>()),
        BlocProvider(create: (_) => sl<ExperienceCubit>()),
      ],
      child: MaterialApp(
        title: 'Travel Planning & Experience Engine',
        theme: AppTheme.light(),
        home: const HomePage(),
      ),
    );
  }
}
