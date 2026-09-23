import 'package:flutter/material.dart';

import '../models/tile_result.dart';
import '../theme/app_theme.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/calculator_ui.dart';
import '../widgets/sitequant_calculator_icon.dart';
import 'tile_calculator_screen.dart';

class TileScreen extends StatelessWidget {
  const TileScreen({super.key});

  @override
  Widget build(BuildContext context) => AppScaffold(
    title: 'Tiles & Flooring',
    bodyBuilder: (context, padding) => ListView(
      padding: padding,
      children: [
        const CalculatorHeader(
          title: 'Tiles & Flooring',
          subtitle: 'Choose a surface to estimate',
        ),
        for (final type in TileWorkType.values)
          Card(
            child: ListTile(
              leading: const SiteQuantCalculatorIcon(
                kind: CalculatorArtwork.tiles,
              ),
              title: Text(type.label),
              subtitle: Text(switch (type) {
                TileWorkType.floorTiles => 'Floor area and tile layout',
                TileWorkType.wallTiles => 'Wall elevation and openings',
                TileWorkType.skirting => 'Perimeter and skirting height',
              }),
              trailing: const Icon(
                Icons.chevron_right,
                color: AppTheme.primaryBlue,
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TileCalculatorScreen(type: type),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}
