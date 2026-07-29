import 'package:flutter/material.dart';

import '../widgets/dashboard_card.dart';
import 'concrete_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showUnavailable(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature is coming soon.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SiteQuant'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(Icons.engineering_rounded, color: colorScheme.primary),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          Card(
            color: colorScheme.primary,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.architecture_rounded,
                      color: Colors.white,
                      size: 29,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Civil Engineering Toolkit',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Accurate quantities for site planning.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.80),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          const _SectionHeader(
            title: 'Material calculators',
            subtitle: 'Estimate materials before procurement',
          ),
          const SizedBox(height: 12),
          DashboardCard(
            title: 'Concrete',
            subtitle: 'Cement / Sand / Aggregate',
            icon: Icons.foundation_rounded,
            color: colorScheme.primary,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ConcreteScreen()),
              );
            },
          ),
          const SizedBox(height: 12),
          DashboardCard(
            title: 'Brickwork',
            subtitle: 'Bricks / Mortar',
            icon: Icons.grid_view_rounded,
            color: colorScheme.primary,
            onTap: () => _showUnavailable(context, 'Brickwork calculator'),
          ),
          const SizedBox(height: 12),
          DashboardCard(
            title: 'Plaster',
            subtitle: 'Material estimation',
            icon: Icons.format_paint_rounded,
            color: colorScheme.primary,
            onTap: () => _showUnavailable(context, 'Plaster calculator'),
          ),
          const SizedBox(height: 12),
          DashboardCard(
            title: 'Steel Weight',
            subtitle: 'Weight calculator',
            icon: Icons.hardware_rounded,
            color: colorScheme.primary,
            onTap: () => _showUnavailable(context, 'Steel weight calculator'),
          ),
          const SizedBox(height: 30),
          const _SectionHeader(
            title: 'Volume calculators',
            subtitle: 'Measure common structural elements',
          ),
          const SizedBox(height: 12),
          DashboardCard(
            title: 'Slab',
            subtitle: 'Concrete volume',
            icon: Icons.crop_16_9_rounded,
            color: colorScheme.primary,
            onTap: () => _showUnavailable(context, 'Slab calculator'),
          ),
          const SizedBox(height: 12),
          DashboardCard(
            title: 'Beam',
            subtitle: 'Concrete volume',
            icon: Icons.view_agenda_rounded,
            color: colorScheme.primary,
            onTap: () => _showUnavailable(context, 'Beam calculator'),
          ),
          const SizedBox(height: 12),
          DashboardCard(
            title: 'Column',
            subtitle: 'Concrete volume',
            icon: Icons.account_balance_rounded,
            color: colorScheme.primary,
            onTap: () => _showUnavailable(context, 'Column calculator'),
          ),
          const SizedBox(height: 12),
          DashboardCard(
            title: 'Footing',
            subtitle: 'Concrete volume',
            icon: Icons.architecture_rounded,
            color: colorScheme.primary,
            onTap: () => _showUnavailable(context, 'Footing calculator'),
          ),
          const SizedBox(height: 12),
          DashboardCard(
            title: 'Excavation',
            subtitle: 'Earthwork',
            icon: Icons.landscape_rounded,
            color: colorScheme.primary,
            onTap: () => _showUnavailable(context, 'Excavation calculator'),
          ),
          const SizedBox(height: 30),
          const _SectionHeader(
            title: 'Utilities',
            subtitle: 'Supporting site tools',
          ),
          const SizedBox(height: 12),
          DashboardCard(
            title: 'Unit Converter',
            subtitle: 'Engineering units',
            icon: Icons.swap_horiz_rounded,
            color: colorScheme.primary,
            onTap: () => _showUnavailable(context, 'Unit converter'),
          ),
          const SizedBox(height: 12),
          DashboardCard(
            title: 'Settings',
            subtitle: 'Preferences',
            icon: Icons.settings_rounded,
            color: colorScheme.primary,
            onTap: () => _showUnavailable(context, 'Settings'),
          ),
          const SizedBox(height: 24),
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFDCE4EE)),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                'Google AdMob Banner',
                style: textTheme.labelMedium?.copyWith(
                  color: const Color(0xFF7A8798),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: textTheme.titleLarge),
        const SizedBox(height: 3),
        Text(subtitle, style: textTheme.bodyMedium),
      ],
    );
  }
}
