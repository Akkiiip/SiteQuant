import 'package:flutter/material.dart';

import '../widgets/app_scaffold.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/section_header.dart';
import 'concrete_screen.dart';
import 'masonry_screen.dart';
import 'unit_converter_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showUnavailable(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('🚧 $feature Coming Soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppScaffold(
      title: 'SiteQuant',
      actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Tooltip(
              message: 'Civil engineering toolkit',
              child: Icon(Icons.engineering_rounded, color: colorScheme.primary),
            ),
          ),
      ],
      bodyBuilder: (context, padding) => LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth >= 900
              ? 4
              : constraints.maxWidth >= 600
              ? 3
              : 2;

          return ListView(
            padding: padding,
            children: [
              _HomeHero(color: colorScheme.primary),
              const SizedBox(height: 28),
              const SectionHeader(
                title: 'Material Calculators',
                subtitle: 'Estimate quantities before procurement',
              ),
              const SizedBox(height: 12),
              _CalculatorGrid(
                crossAxisCount: crossAxisCount,
                children: [
                  DashboardCard(
                    title: 'Concrete',
                    subtitle: 'Cement / Sand / Aggregate',
                    icon: Icons.foundation_rounded,
                    color: colorScheme.primary,
                    compact: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ConcreteScreen()),
                      );
                    },
                  ),
                  DashboardCard(
                    title: 'Masonry',
                    subtitle: 'Brick • AAC • Block • Laterite',
                    icon: Icons.view_quilt_rounded,
                    color: colorScheme.primary,
                    compact: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MasonryScreen()),
                      );
                    },
                  ),
                  DashboardCard(
                    title: 'Plaster',
                    subtitle: '🚧 Coming Soon',
                    icon: Icons.format_paint_rounded,
                    color: colorScheme.primary,
                    compact: true,
                    onTap: () => _showUnavailable(context, 'Plaster'),
                  ),
                  DashboardCard(
                    title: 'Steel Weight',
                    subtitle: '🚧 Coming Soon',
                    icon: Icons.hardware_rounded,
                    color: colorScheme.primary,
                    compact: true,
                    onTap: () => _showUnavailable(context, 'Steel Weight'),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const SectionHeader(
                title: 'Volume Calculators',
                subtitle: 'Measure common structural elements',
              ),
              const SizedBox(height: 12),
              _CalculatorGrid(
                crossAxisCount: crossAxisCount,
                children: [
                  DashboardCard(
                    title: 'Slab',
                    subtitle: 'Concrete volume',
                    icon: Icons.crop_16_9_rounded,
                    color: colorScheme.primary,
                    compact: true,
                    onTap: () => _showUnavailable(context, 'Slab calculator'),
                  ),
                  DashboardCard(
                    title: 'Beam',
                    subtitle: 'Concrete volume',
                    icon: Icons.view_agenda_rounded,
                    color: colorScheme.primary,
                    compact: true,
                    onTap: () => _showUnavailable(context, 'Beam calculator'),
                  ),
                  DashboardCard(
                    title: 'Column',
                    subtitle: 'Concrete volume',
                    icon: Icons.account_balance_rounded,
                    color: colorScheme.primary,
                    compact: true,
                    onTap: () => _showUnavailable(context, 'Column calculator'),
                  ),
                  DashboardCard(
                    title: 'Footing',
                    subtitle: 'Concrete volume',
                    icon: Icons.architecture_rounded,
                    color: colorScheme.primary,
                    compact: true,
                    onTap: () => _showUnavailable(context, 'Footing calculator'),
                  ),
                  DashboardCard(
                    title: 'Excavation',
                    subtitle: 'Earthwork',
                    icon: Icons.landscape_rounded,
                    color: colorScheme.primary,
                    compact: true,
                    onTap: () => _showUnavailable(context, 'Excavation calculator'),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const SectionHeader(
                title: 'Utilities',
                subtitle: 'Supporting site tools',
              ),
              const SizedBox(height: 12),
              _CalculatorGrid(
                crossAxisCount: crossAxisCount,
                children: [
                  DashboardCard(
                    title: 'Unit Converter',
                    subtitle: 'Length • Area • Volume • Weight',
                    icon: Icons.swap_horiz_rounded,
                    color: colorScheme.primary,
                    compact: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const UnitConverterScreen(),
                        ),
                      );
                    },
                  ),
                  DashboardCard(
                    title: 'Settings',
                    subtitle: 'Preferences',
                    icon: Icons.settings_rounded,
                    color: colorScheme.primary,
                    compact: true,
                    onTap: () => _showUnavailable(context, 'Settings'),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HomeHero extends StatelessWidget {
  final Color color;

  const _HomeHero({required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
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
    );
  }
}

class _CalculatorGrid extends StatelessWidget {
  final int crossAxisCount;
  final List<Widget> children;

  const _CalculatorGrid({required this.crossAxisCount, required this.children});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: crossAxisCount == 2 ? 1.05 : 1.18,
      children: children,
    );
  }
}
