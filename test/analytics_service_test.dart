import 'package:flutter_test/flutter_test.dart';
import 'package:site_quant/services/analytics_service.dart';

class _RecordedEvent {
  const _RecordedEvent(this.name, this.parameters);
  final String name;
  final Map<String, Object>? parameters;
}

class _FakeLogger implements AnalyticsEventLogger {
  _FakeLogger({this.error});
  final Object? error;
  final events = <_RecordedEvent>[];

  @override
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) {
    events.add(_RecordedEvent(name, parameters));
    if (error != null) return Future<void>.error(error!);
    return Future<void>.value();
  }
}

void main() {
  tearDown(AnalyticsService.resetLoggerForTesting);

  test('uses the V1 calculator event names and safe parameters', () async {
    final logger = _FakeLogger();
    AnalyticsService.setLoggerForTesting(logger);

    AnalyticsService.logCalculatorOpened('plaster');
    AnalyticsService.logCalculationCompleted('paint', workType: 'exterior_walls');
    AnalyticsService.logCalculationError('concrete', 'invalid_input');
    AnalyticsService.logUnitSystemChanged(
      fromSystem: 'metric',
      toSystem: 'imperial',
    );
    AnalyticsService.logOpeningAdded('paint');
    await Future<void>.delayed(Duration.zero);

    expect(
      logger.events.map((event) => event.name),
      [
        'calculator_opened',
        'calculation_completed',
        'calculation_error',
        'unit_system_changed',
        'opening_added',
      ],
    );
    expect(logger.events[1].parameters, {
      'calculator': 'paint',
      'work_type': 'exterior_walls',
    });
    expect(logger.events[3].parameters, {
      'from_system': 'metric',
      'to_system': 'imperial',
    });
  });

  test('omits an empty work type and swallows logger failures', () async {
    final logger = _FakeLogger(error: StateError('Analytics unavailable'));
    AnalyticsService.setLoggerForTesting(logger);

    AnalyticsService.logCalculationCompleted('masonry', workType: '');
    await Future<void>.delayed(Duration.zero);

    expect(logger.events.single.parameters, {'calculator': 'masonry'});
  });
}
