import 'package:flutter/material.dart';

import '../services/analytics_service.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/section_header.dart';
import '../widgets/home_adaptive_banner_slot.dart';
import 'concrete_screen.dart';
import 'excavation_screen.dart';
import 'masonry_v2_screen.dart';
import 'plaster_screen.dart';
import 'paint_screen.dart';
import 'steel_weight_screen.dart';
import 'settings_screen.dart';
import 'shuttering_screen.dart';
import 'unit_converter_screen.dart';
import 'volume_calculator_screen.dart';
import 'water_tank_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppScaffold(
      title: 'SiteQuant',
      showBottomBanner: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_rounded),
          tooltip: 'Settings',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
          },
        ),
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
              const _HomeHeader(),
              const SizedBox(height: 12),
              const HomeAdaptiveBannerSlot(),
              const SizedBox(height: 20),
              const SectionHeader(
                title: 'Quick Calculators',
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
                      AnalyticsService.logCalculatorOpened('concrete');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ConcreteScreen(),
                        ),
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
                      AnalyticsService.logCalculatorOpened('masonry');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MasonryV2Screen(),
                        ),
                      );
                    },
                  ),
                  DashboardCard(
                    title: 'Plaster Calculator',
                    subtitle: 'Wall • Ceiling',
                    icon: Icons.format_paint_rounded,
                    color: colorScheme.primary,
                    compact: true,
                    onTap: () {
                      AnalyticsService.logCalculatorOpened('plaster');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PlasterScreen(),
                        ),
                      );
                    },
                  ),
                  DashboardCard(
                    title: 'Paint & Finishes',
                    subtitle: 'Paint • Putty • Primer',
                    icon: Icons.format_paint_outlined,
                    color: colorScheme.primary,
                    compact: true,
                    onTap: () {
                      AnalyticsService.logCalculatorOpened('paint');
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PaintScreen()),
                      );
                    },
                  ),
                  DashboardCard(
                    title: 'Shuttering',
                    subtitle: 'Column • Beam • Slab',
                    icon: Icons.construction_rounded,
                    color: colorScheme.primary,
                    compact: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ShutteringScreen(),
                        ),
                      );
                    },
                  ),
                  DashboardCard(
                    title: 'Water Tank',
                    subtitle: 'Rectangular • Circular RCC',
                    icon: Icons.water_rounded,
                    color: colorScheme.primary,
                    compact: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WaterTankScreen(),
                        ),
                      );
                    },
                  ),
                  DashboardCard(
                    title: 'Steel Weight',
                    subtitle: 'Bar Weight Calculator',
                    icon: Icons.hardware_rounded,
                    color: colorScheme.primary,
                    compact: true,
                    onTap: () {
                      AnalyticsService.logCalculatorOpened('steel_weight');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SteelWeightScreen(),
                        ),
                      );
                    },
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
                    title: 'Volume Calculator',
                    subtitle: '4 Basic Shapes',
                    icon: Icons.view_in_ar_rounded,
                    color: colorScheme.primary,
                    compact: true,
                    onTap: () {
                      AnalyticsService.logCalculatorOpened('volume');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const VolumeCalculatorScreen(),
                        ),
                      );
                    },
                  ),
                  DashboardCard(
                    title: 'Excavation Calculator',
                    subtitle: '3 Excavation Types',
                    icon: Icons.landscape_rounded,
                    color: colorScheme.primary,
                    compact: true,
                    onTap: () {
                      AnalyticsService.logCalculatorOpened('excavation');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ExcavationScreen(),
                        ),
                      );
                    },
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
                      AnalyticsService.logCalculatorOpened('unit_converter');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const UnitConverterScreen(),
                        ),
                      );
                    },
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

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();
  @override Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text('SiteQuant', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
    const SizedBox(height: 3),
    Text('Civil Engineering Calculators', style: Theme.of(context).textTheme.bodyLarge),
  ]);
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
