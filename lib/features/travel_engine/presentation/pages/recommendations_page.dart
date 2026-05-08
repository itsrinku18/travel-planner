import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_planner/features/travel_engine/domain/entities/activity.dart';
import 'package:travel_planner/features/travel_engine/presentation/bloc/experience_cubit.dart';
import 'package:travel_planner/features/travel_engine/presentation/bloc/experience_state.dart';
import 'package:travel_planner/features/travel_engine/presentation/ui/category_ui.dart';

class RecommendationsPage extends StatelessWidget {
  const RecommendationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Experience Engine'),
        actions: [
          TextButton(
            onPressed: () => context.read<ExperienceCubit>().clear(),
            child: const Text('Clear'),
          ),
        ],
      ),
      body: BlocBuilder<ExperienceCubit, ExperienceState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            children: [
              Text(
                'Pick what you enjoy',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children:
                    ActivityCategory.values.map((cat) {
                      final selected = state.preferences.contains(cat);
                      return FilterChip(
                        selected: selected,
                        onSelected:
                            (_) => context
                                .read<ExperienceCubit>()
                                .togglePreference(cat),
                        avatar: Icon(CategoryUi.icon(cat), size: 18),
                        label: Text(CategoryUi.label(cat)),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'Recommendations',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  if (state.isLoading)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              if (state.recommendations.isEmpty && !state.isLoading)
                const Text(
                  'No suggestions right now. Try selecting preferences.',
                ),
              ...state.recommendations.map(
                (r) => Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Icon(CategoryUi.icon(r.category)),
                    ),
                    title: Text(r.title),
                    subtitle: Text(
                      '${CategoryUi.label(r.category)} • ${r.estimatedMinutes} min\n${r.reason}',
                    ),
                    isThreeLine: true,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
