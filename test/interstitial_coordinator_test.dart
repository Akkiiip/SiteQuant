import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:site_quant/services/ad_consent_manager.dart';
import 'package:site_quant/services/analytics_service.dart';
import 'package:site_quant/services/interstitial_ad_service.dart';

class _FakeLogger implements AnalyticsEventLogger {
  final events = <String>[];
  @override
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    events.add(name);
  }
}

class _FakeHandle implements InterstitialHandle {
  int shows = 0;
  int disposals = 0;
  VoidCallback? shown;
  VoidCallback? dismissed;
  VoidCallback? failed;
  @override
  void setCallbacks({
    required VoidCallback onShown,
    required VoidCallback onDismissed,
    required VoidCallback onFailedToShow,
  }) {
    shown = onShown;
    dismissed = onDismissed;
    failed = onFailedToShow;
  }

  @override
  void show() {
    shows++;
    shown?.call();
  }

  @override
  void dispose() => disposals++;
}

class _FakeLoader implements InterstitialLoader {
  final handles = <_FakeHandle>[];
  @override
  Future<InterstitialHandle> load() async {
    final handle = _FakeHandle();
    handles.add(handle);
    return handle;
  }
}

class _UnavailableLoader implements InterstitialLoader {
  int attempts = 0;
  @override
  Future<InterstitialHandle> load() async {
    attempts++;
    throw StateError('No ad available');
  }
}

void main() {
  setUp(() => AdConsentManager.canRequestAds.value = true);
  tearDown(() {
    AnalyticsService.calculationCompletedHandler = null;
    AnalyticsService.resetLoggerForTesting();
    AdConsentManager.canRequestAds.value = false;
  });

  testWidgets(
    'only every third completion is eligible, with one show and normal dismissal',
    (tester) async {
      final logger = _FakeLogger();
      AnalyticsService.setLoggerForTesting(logger);
      final loader = _FakeLoader();
      final coordinator = InterstitialAdService.forTesting(loader);
      AnalyticsService.calculationCompletedHandler =
          coordinator.onCalculationCompleted;
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Text('Calculator'))),
      );
      await coordinator.preload();
      expect(loader.handles.first.shows, 0);

      AnalyticsService.logCalculatorOpened('concrete');
      AnalyticsService.logCalculationError('concrete', 'invalid_input');
      tester.binding.scheduleFrame();
      await tester.pump();
      expect(coordinator.completedCalculations, 0);

      AnalyticsService.logCalculationCompleted('concrete');
      AnalyticsService.logCalculationCompleted('concrete');
      tester.binding.scheduleFrame();
      await tester.pump();
      expect(loader.handles.first.shows, 0);
      expect(coordinator.completedCalculations, 2);

      AnalyticsService.logCalculationCompleted('concrete');
      tester.binding.scheduleFrame();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
      expect(
        logger.events,
        contains('interstitial_show_attempted'),
        reason: logger.events.toString(),
      );
      expect(loader.handles.first.shows, 1);
      expect(coordinator.completedCalculations, 0);
      await coordinator.showIfReady();
      await tester.pump(const Duration(milliseconds: 16));
      expect(
        logger.events,
        contains('interstitial_show_attempted'),
        reason: logger.events.toString(),
      );
      expect(loader.handles.first.shows, 1);
      loader.handles.first.dismissed!();
      await tester.pump();
      expect(loader.handles.first.disposals, 1);
      expect(
        logger.events,
        containsAll([
          'interstitial_load_attempted',
          'interstitial_loaded',
          'interstitial_show_attempted',
          'interstitial_shown',
          'interstitial_dismissed',
        ]),
      );
    },
  );

  testWidgets(
    'unavailable interstitial does not block calculation-result navigation',
    (tester) async {
      final logger = _FakeLogger();
      AnalyticsService.setLoggerForTesting(logger);
      final loader = _UnavailableLoader();
      final coordinator = InterstitialAdService.forTesting(loader);
      AnalyticsService.calculationCompletedHandler =
          coordinator.onCalculationCompleted;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: FilledButton(
                onPressed: () {
                  AnalyticsService.logCalculationCompleted('volume');
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const Scaffold(body: Text('Result')),
                    ),
                  );
                },
                child: const Text('Calculate'),
              ),
            ),
          ),
        ),
      );
      await coordinator.preload();
      await tester.tap(find.text('Calculate'));
      await tester.pumpAndSettle();
      expect(find.text('Result'), findsOneWidget);
      expect(coordinator.completedCalculations, 1);
      expect(loader.attempts, greaterThanOrEqualTo(1));
      expect(logger.events, contains('interstitial_load_failed'));
    },
  );
}
