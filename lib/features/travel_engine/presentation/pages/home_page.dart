import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_planner/features/travel_engine/presentation/bloc/experience_cubit.dart';
import 'package:travel_planner/features/travel_engine/presentation/bloc/experience_state.dart';
import 'package:travel_planner/features/travel_engine/presentation/bloc/trips_cubit.dart';
import 'package:travel_planner/features/travel_engine/presentation/bloc/trips_state.dart';
import 'package:travel_planner/features/travel_engine/presentation/pages/planner_page.dart';
import 'package:travel_planner/features/travel_engine/presentation/pages/recommendations_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<TripsCubit, TripsState>(
          listenWhen: (_, s) => s.errorMessage != null,
          listener: (context, s) {
            final msg = s.errorMessage;
            if (msg == null) return;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(msg)));
          },
        ),
        BlocListener<ExperienceCubit, ExperienceState>(
          listenWhen: (_, s) => s.errorMessage != null,
          listener: (context, s) {
            final msg = s.errorMessage;
            if (msg == null) return;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(msg)));
          },
        ),
      ],
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: const [PlannerPage(), RecommendationsPage()],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.map_outlined),
              selectedIcon: Icon(Icons.map),
              label: 'Planner',
            ),
            NavigationDestination(
              icon: Icon(Icons.auto_awesome_outlined),
              selectedIcon: Icon(Icons.auto_awesome),
              label: 'Experiences',
            ),
          ],
        ),
      ),
    );
  }
}
