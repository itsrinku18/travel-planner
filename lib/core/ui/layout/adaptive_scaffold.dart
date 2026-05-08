import 'package:flutter/material.dart';
import 'package:travel_planner/core/platform/breakpoints.dart';
import 'package:travel_planner/core/routing/app_destinations.dart';

class AdaptiveScaffold extends StatelessWidget {
  const AdaptiveScaffold({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
    required this.destinations,
    this.topBar,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final List<AppDestination> destinations;
  final PreferredSizeWidget? topBar;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width < Breakpoints.mobile) {
      return Scaffold(
        appBar: topBar,
        body: IndexedStack(
          index: selectedIndex,
          children:
              destinations.map((d) => Builder(builder: d.builder)).toList(),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: onSelected,
          destinations:
              destinations
                  .map(
                    (d) => NavigationDestination(
                      icon: Icon(d.icon),
                      selectedIcon: Icon(d.selectedIcon),
                      label: d.label,
                    ),
                  )
                  .toList(),
        ),
      );
    }

    if (width < Breakpoints.tablet) {
      return Scaffold(
        appBar: topBar,
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: onSelected,
              labelType: NavigationRailLabelType.all,
              destinations:
                  destinations
                      .map(
                        (d) => NavigationRailDestination(
                          icon: Icon(d.icon),
                          selectedIcon: Icon(d.selectedIcon),
                          label: Text(d.label),
                        ),
                      )
                      .toList(),
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: IndexedStack(
                index: selectedIndex,
                children:
                    destinations
                        .map((d) => Builder(builder: d.builder))
                        .toList(),
              ),
            ),
          ],
        ),
      );
    }

    // Desktop/web: sidebar feel (rail + wide content), plus room for top bars.
    return Scaffold(
      appBar: topBar,
      body: Row(
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints.tightFor(width: 320),
            child: Material(
              color: Theme.of(
                context,
              ).colorScheme.surface.withValues(alpha: 0.7),
              child: SafeArea(
                right: false,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Travel Planner',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 10),
                      ...List.generate(destinations.length, (i) {
                        final d = destinations[i];
                        final selected = i == selectedIndex;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            selected: selected,
                            leading: Icon(selected ? d.selectedIcon : d.icon),
                            title: Text(d.label),
                            onTap: () => onSelected(i),
                          ),
                        );
                      }),
                      const Spacer(),
                      Text(
                        'Premium travel engine (MVP)',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: IndexedStack(
              index: selectedIndex,
              children:
                  destinations.map((d) => Builder(builder: d.builder)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
