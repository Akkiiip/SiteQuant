import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:site_quant/models/masonry_result.dart';
import 'package:site_quant/models/shuttering_result.dart';
import 'package:site_quant/models/water_tank_input.dart';
import 'package:site_quant/screens/app_shell.dart';
import 'package:site_quant/screens/concrete_screen.dart';
import 'package:site_quant/screens/excavation_screen.dart';
import 'package:site_quant/screens/masonry_calculator_screen.dart';
import 'package:site_quant/screens/paint_screen.dart';
import 'package:site_quant/screens/plaster_screen.dart';
import 'package:site_quant/screens/shuttering_calculator_screen.dart';
import 'package:site_quant/screens/steel_weight_screen.dart';
import 'package:site_quant/screens/tile_calculator_screen.dart';
import 'package:site_quant/models/tile_result.dart';
import 'package:site_quant/screens/volume_calculator_screen.dart';
import 'package:site_quant/screens/water_tank_calculator_screen.dart';
import 'package:site_quant/services/ad_consent_manager.dart';
import 'package:site_quant/services/admob_config.dart';
import 'package:site_quant/services/measurement_system.dart';
import 'package:site_quant/theme/app_theme.dart';
import 'package:site_quant/widgets/bottom_banner_slot.dart';
import 'package:site_quant/widgets/home_adaptive_banner_slot.dart';
import 'package:site_quant/widgets/sitequant_calculator_icon.dart';

void main() {
  setUp(() {
    AdConsentManager.canRequestAds.value = false;
    MeasurementPreferences.system.value = MeasurementSystem.metric;
  });
  tearDown(() {
    AdConsentManager.canRequestAds.value = false;
    MeasurementPreferences.system.value = null;
  });

  testWidgets(
    'Home has blue branding, compact hero, one bounded ad above eight cards',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.lightTheme, home: const SiteQuantShell()),
      );
      await tester.pump();
      final brand = tester.widget<Text>(find.text('SiteQuant'));
      expect(brand.style?.color, AppTheme.primaryBlue);
      expect(
        find.text('Civil Engineering Tools for the Jobsite'),
        findsOneWidget,
      );
      expect(find.textContaining('Good Morning'), findsNothing);
      expect(find.textContaining('Akash'), findsNothing);
      expect(find.text('Engineer'), findsNothing);
      expect(find.byType(HomeAdaptiveBannerSlot), findsOneWidget);
      expect(find.byType(BottomBannerSlot), findsNothing);
      final ad = find.byKey(const ValueKey('home-ad-slot'));
      expect(ad, findsOneWidget);
      expect(tester.getSize(ad).height, inInclusiveRange(50, 66));
      final hero = find.byWidgetPredicate(
        (w) => w is Image && w.image is AssetImage,
      );
      expect(hero, findsOneWidget);
      expect(tester.getSize(hero).height, inInclusiveRange(130, 145));
      expect(tester.getBottomLeft(hero).dy, lessThan(tester.getTopLeft(ad).dy));
      expect(
        tester.getBottomLeft(ad).dy,
        lessThan(tester.getTopLeft(find.text('Quick Calculators')).dy),
      );
      for (final kind in CalculatorArtwork.values.where(
        (kind) => kind != CalculatorArtwork.steel,
      )) {
        final card = find.byKey(ValueKey('home-calculator-${kind.name}'));
        expect(card, findsOneWidget);
        expect(tester.getSize(card).height, inInclusiveRange(64, 70));
      }
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'inline and anchored slots reserve bounded space with injected preview, no network',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                HomeAdaptiveBannerSlot(previewAd: Text('Inline fake')),
                BottomBannerSlot(previewAd: Text('Anchored fake')),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Inline fake'), findsOneWidget);
      expect(find.text('Anchored fake'), findsOneWidget);
      expect(
        tester.getSize(find.byKey(const ValueKey('home-ad-slot'))).height,
        58,
      );
      expect(
        tester.getSize(find.byKey(const ValueKey('calculator-ad-slot'))).height,
        66,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('ten calculator inputs each own one separated banner placement', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final calculators = <Widget>[
      const ConcreteScreen(),
      const MasonryCalculatorScreen(type: MasonryType.clayBrick),
      const PlasterScreen(),
      const PaintScreen(),
      const ShutteringCalculatorScreen(type: ShutteringType.column),
      const WaterTankCalculatorScreen(type: WaterTankType.rectangular),
      const ExcavationScreen(),
      const SteelWeightScreen(),
      const TileCalculatorScreen(type: TileWorkType.floorTiles),
      const VolumeCalculatorScreen(),
    ];
    for (final calculator in calculators) {
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.lightTheme, home: calculator),
      );
      await tester.pump();
      expect(find.byType(BottomBannerSlot), findsOneWidget);
      expect(find.byType(HomeAdaptiveBannerSlot), findsNothing);
      final banner = find.byKey(const ValueKey('calculator-ad-slot'));
      expect(banner, findsOneWidget);
      expect(tester.getSize(banner).height, inInclusiveRange(50, 90));
      expect(tester.takeException(), isNull);
    }
  });

  test('development banner ID remains the Google Android test unit', () {
    expect(
      AdMobConfig.androidBannerAdUnitId,
      'ca-app-pub-3940256099942544/6300978111',
    );
  });
}
