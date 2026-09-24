import 'package:flutter_test/flutter_test.dart';
import 'package:site_quant/services/analytics_service.dart';

class _Event {
  const _Event(this.name, this.parameters);
  final String name;
  final Map<String, Object>? parameters;
}

class _Logger implements AnalyticsEventLogger {
  final events = <_Event>[];

  @override
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    events.add(_Event(name, parameters));
  }
}

void main() {
  tearDown(AnalyticsService.resetLoggerForTesting);

  test(
    'quiz analytics uses privacy-safe event names and aggregate score only',
    () async {
      final logger = _Logger();
      AnalyticsService.setLoggerForTesting(logger);
      AnalyticsService.logQuizOpened();
      AnalyticsService.logQuizStarted();
      AnalyticsService.logQuizCompleted(score: 8, percentage: 80);
      AnalyticsService.logQuizReminderEnabled();
      AnalyticsService.logQuizReminderDisabled();
      AnalyticsService.logQuizNotificationOpened();
      await Future<void>.delayed(Duration.zero);

      expect(logger.events.map((event) => event.name), [
        'quiz_opened',
        'quiz_started',
        'quiz_completed',
        'quiz_reminder_enabled',
        'quiz_reminder_disabled',
        'quiz_notification_opened',
      ]);
      expect(logger.events[2].parameters, {'score': 8, 'percentage': 80});
      expect(
        logger.events.expand((event) => event.parameters?.keys ?? const []),
        isNot(contains(anyOf('question', 'answer', 'question_text'))),
      );
    },
  );
}
