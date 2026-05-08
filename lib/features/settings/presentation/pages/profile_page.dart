import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_planner/core/design/app_gradients.dart';
import 'package:travel_planner/core/design/app_radii.dart';
import 'package:travel_planner/features/settings/presentation/settings_cubit.dart';
import 'package:travel_planner/features/travel_engine/presentation/bloc/trips_cubit.dart';
import 'package:travel_planner/features/travel_engine/presentation/bloc/trips_state.dart';
import 'package:travel_planner/features/wishlist/presentation/wishlist_cubit.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          const _ProfileHeader(),
          const SizedBox(height: 16),
          const _StatsRow(),
          const SizedBox(height: 16),
          Text('Appearance', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          const _ThemeSelector(),
          const SizedBox(height: 16),
          Text('About', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('About Travel Planner'),
                  subtitle: const Text('v1.0.0 — premium MVP'),
                  onTap:
                      () => showAboutDialog(
                        context: context,
                        applicationName: 'Travel Planner',
                        applicationVersion: '1.0.0',
                        applicationLegalese:
                            '© 2026 Travel Planner. Plan smarter, travel happier.',
                      ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Privacy'),
                  subtitle: const Text('Your data is stored on this device'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text('Help & feedback'),
                  subtitle: const Text('Get in touch'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isDark ? AppGradients.heroDark : AppGradients.hero,
        borderRadius: BorderRadius.circular(AppRadii.r24),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hi, Traveler',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Plan smarter, travel happier.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: BlocBuilder<TripsCubit, TripsState>(
            builder:
                (context, s) => _StatCard(
                  icon: Icons.map_outlined,
                  label: 'Trips',
                  value: '${s.trips.length}',
                ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: BlocBuilder<WishlistCubit, WishlistState>(
            builder:
                (context, w) => _StatCard(
                  icon: Icons.favorite_border,
                  label: 'Wishlist',
                  value: '${w.ids.length}',
                ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: BlocBuilder<TripsCubit, TripsState>(
            builder: (context, s) {
              final activities = s.trips.fold<int>(
                0,
                (acc, t) => acc + t.activities.length,
              );
              return _StatCard(
                icon: Icons.event_available_outlined,
                label: 'Activities',
                value: '$activities',
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadii.r20),
      ),
      child: Column(
        children: [
          Icon(icon, color: cs.primary),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, s) {
        return SegmentedButton<ThemeMode>(
          segments: const [
            ButtonSegment(
              value: ThemeMode.system,
              label: Text('System'),
              icon: Icon(Icons.brightness_auto),
            ),
            ButtonSegment(
              value: ThemeMode.light,
              label: Text('Light'),
              icon: Icon(Icons.light_mode_outlined),
            ),
            ButtonSegment(
              value: ThemeMode.dark,
              label: Text('Dark'),
              icon: Icon(Icons.dark_mode_outlined),
            ),
          ],
          selected: {s.themeMode},
          onSelectionChanged:
              (set) => context.read<SettingsCubit>().setThemeMode(set.first),
        );
      },
    );
  }
}
