import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:site_quant/screens/app_shell.dart';
import 'package:site_quant/screens/concrete_screen.dart';
import 'package:site_quant/screens/excavation_screen.dart';
import 'package:site_quant/screens/volume_calculator_screen.dart';
import 'package:site_quant/widgets/geometry_diagram.dart';
import 'package:site_quant/widgets/calculator_ui.dart';
import 'package:site_quant/widgets/home_adaptive_banner_slot.dart';
import 'package:site_quant/widgets/sitequant_calculator_icon.dart';
import 'package:site_quant/widgets/masonry_diagram.dart';
import 'package:site_quant/widgets/shuttering_diagram.dart';
import 'package:site_quant/widgets/water_tank_diagram.dart';
import 'package:site_quant/models/masonry_result.dart';
import 'package:site_quant/models/shuttering_result.dart';
import 'package:site_quant/models/water_tank_input.dart';

void main() {
  testWidgets('Home is compact and impersonal at 360x800', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: SiteQuantShell()));
    expect(find.text('SiteQuant'), findsOneWidget);
    expect(
      find.text('Civil Engineering Tools for the Jobsite'),
      findsOneWidget,
    );
    expect(find.textContaining('Good Morning'), findsNothing);
    expect(find.text('Engineer'), findsNothing);
    expect(
      find.text('From Drawings\nto Quantities\nin Seconds.'),
      findsOneWidget,
    );
    expect(find.byType(HomeAdaptiveBannerSlot), findsOneWidget);
    expect(find.text('Quick Calculators'), findsOneWidget);
    expect(find.byType(SiteQuantCalculatorIcon), findsWidgets);
    for (final kind in CalculatorArtwork.values.where(
      (kind) => kind != CalculatorArtwork.steel,
    )) {
      final card = find.byKey(ValueKey('home-calculator-${kind.name}'));
      expect(card, findsOneWidget);
      expect(tester.getSize(card).height, lessThanOrEqualTo(70));
    }
    expect(
      tester
          .getSize(find.text('From Drawings\nto Quantities\nin Seconds.'))
          .height,
      lessThan(80),
    );
    expect(tester.takeException(), isNull);
  });

  test('the eight calculator icons have distinct centralized mappings', () {
    final titles = [
      'Concrete Calculator',
      'Masonry Calculator',
      'Plaster Calculator',
      'Paint Calculator',
      'Shuttering Calculator',
      'Tiles & Flooring',
      'Excavation Calculator',
      'RCC Water Tank',
    ];
    expect(titles.map(SiteQuantCalculatorIcon.kindFor).toSet().length, 8);
  });

  testWidgets('Volume shape selection changes diagram semantics at 360x800', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: VolumeCalculatorScreen()));
    expect(
      find.byWidgetPredicate((w) => w is GeometryDiagram && w.kind == 'Cuboid'),
      findsOneWidget,
    );
    await tester.ensureVisible(find.text('Cone'));
    await tester.tap(find.text('Cone'));
    await tester.pumpAndSettle();
    expect(
      find.byWidgetPredicate((w) => w is GeometryDiagram && w.kind == 'Cone'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Excavation type changes its geometry', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ExcavationScreen()));
    expect(
      find.byWidgetPredicate(
        (w) => w is GeometryDiagram && w.kind == 'Rectangular',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Trench').first);
    await tester.pumpAndSettle();
    expect(
      find.byWidgetPredicate((w) => w is GeometryDiagram && w.kind == 'Trench'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('each supported geometry owns its shape semantics', (
    tester,
  ) async {
    for (final shape in [
      'Cuboid',
      'Cylinder',
      'Cone',
      'Sphere',
      'Rectangular',
      'Trench',
      'Circular Pit',
    ]) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: GeometryDiagram(kind: shape)),
        ),
      );
      expect(
        find.bySemanticsLabel('$shape engineering diagram'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('Concrete selection changes structure diagram', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ConcreteScreen()));
    await tester.tap(find.text('Slab').first);
    await tester.pumpAndSettle();
    expect(
      find.byWidgetPredicate(
        (w) => w is EngineeringDiagramCard && w.label == 'Slab',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Beam').first);
    await tester.pumpAndSettle();
    expect(
      find.byWidgetPredicate(
        (w) => w is EngineeringDiagramCard && w.label == 'Beam',
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'material, formwork and tank diagrams have type-specific semantics',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: [
                for (final material in MasonryType.values)
                  MasonryDiagram(type: material),
                for (final type in ShutteringType.values)
                  ShutteringDiagram(type: type),
                for (final type in WaterTankType.values)
                  WaterTankDiagram(type: type),
              ],
            ),
          ),
        ),
      );
      for (final material in MasonryType.values) {
        expect(
          find.bySemanticsLabel('Masonry ${material.name} dimensions L H T'),
          findsOneWidget,
        );
      }
      for (final type in WaterTankType.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: WaterTankDiagram(type: type)),
          ),
        );
        expect(
          find.byWidgetPredicate(
            (w) => w is WaterTankDiagram && w.type == type,
          ),
          findsOneWidget,
        );
      }

      expect(tester.takeException(), isNull);
    },
  );
}
