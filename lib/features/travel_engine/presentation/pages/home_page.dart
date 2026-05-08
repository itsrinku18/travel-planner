import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_planner/core/routing/app_destinations.dart';
import 'package:travel_planner/core/ui/layout/adaptive_scaffold.dart';
import 'package:travel_planner/features/discovery/presentation/pages/discovery_page.dart';
import 'package:travel_planner/features/settings/presentation/pages/profile_page.dart';
import 'package:travel_planner/features/travel_engine/presentation/bloc/experience_cubit.dart';
import 'package:travel_planner/features/travel_engine/presentation/bloc/experience_state.dart';
import 'package:travel_planner/features/travel_engine/presentation/bloc/trips_cubit.dart';
import 'package:travel_planner/features/travel_engine/presentation/bloc/trips_state.dart';
import 'package:travel_planner/features/travel_engine/presentation/pages/planner_page.dart';
import 'package:travel_planner/features/travel_engine/presentation/pages/recommendations_page.dart';
import 'package:travel_planner/features/wishlist/presentation/pages/wishlist_page.dart';

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
      child: AdaptiveScaffold(
        selectedIndex: _index,
        onSelected: (i) => setState(() => _index = i),
        destinations: [
          AppDestination(
            key: 'discovery',
            label: 'Explore',
            icon: Icons.explore_outlined,
            selectedIcon: Icons.explore,
            builder: (_) => const DiscoveryPage(),
          ),
          AppDestination(
            key: 'planner',
            label: 'Planner',
            icon: Icons.map_outlined,
            selectedIcon: Icons.map,
            builder: (_) => const PlannerPage(),
          ),
          AppDestination(
            key: 'experiences',
            label: 'Experiences',
            icon: Icons.auto_awesome_outlined,
            selectedIcon: Icons.auto_awesome,
            builder: (_) => const RecommendationsPage(),
          ),
          AppDestination(
            key: 'wishlist',
            label: 'Saved',
            icon: Icons.favorite_border,
            selectedIcon: Icons.favorite,
            builder: (_) => const WishlistPage(),
          ),
          AppDestination(
            key: 'profile',
            label: 'Profile',
            icon: Icons.person_outline,
            selectedIcon: Icons.person,
            builder: (_) => const ProfilePage(),
          ),
        ],
      ),
    );
  }
}
