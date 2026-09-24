import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

/// Narrow boundary around Firebase Analytics so product code never depends on
/// an Analytics request succeeding.
abstract interface class AnalyticsEventLogger {
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  });
}

class FirebaseAnalyticsEventLogger implements AnalyticsEventLogger {
  FirebaseAnalyticsEventLogger(this._analytics);

  final FirebaseAnalytics _analytics;

  @override
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) => _analytics.logEvent(name: name, parameters: parameters);
}

/// Fire-and-forget, privacy-safe product-usage events.
///
/// Calls are intentionally not awaited by UI code. Any platform, Firebase, or
/// network failure is swallowed, so Analytics can never interrupt a calculation
/// or navigation.
class AnalyticsService {
  AnalyticsService._();

  // Lazy construction prevents Analytics from becoming a startup dependency.
  static AnalyticsEventLogger? _logger;
  static VoidCallback? calculationCompletedHandler;

  static void logCalculatorOpened(String calculator) =>
      _send('calculator_opened', {'calculator': calculator});

  static void logCalculationCompleted(String calculator, {String? workType}) {
    _send('calculation_completed', {
      'calculator': calculator,
      if (workType != null && workType.isNotEmpty) 'work_type': workType,
    });
    calculationCompletedHandler?.call();
  }

  static void logCalculationError(String calculator, String errorType) => _send(
    'calculation_error',
    {'calculator': calculator, 'error_type': errorType},
  );

  static void logUnitSystemChanged({
    required String fromSystem,
    required String toSystem,
  }) => _send('unit_system_changed', {
    'from_system': fromSystem,
    'to_system': toSystem,
  });

  static void logOpeningAdded(String calculator) =>
      _send('opening_added', {'calculator': calculator});

  static void logQuizOpened() => _send('quiz_opened', {});
  static void logQuizStarted() => _send('quiz_started', {});
  static void logQuizCompleted({required int score, required int percentage}) =>
      _send('quiz_completed', {'score': score, 'percentage': percentage});
  static void logQuizReminderEnabled() => _send('quiz_reminder_enabled', {});
  static void logQuizReminderDisabled() => _send('quiz_reminder_disabled', {});
  static void logQuizNotificationOpened() =>
      _send('quiz_notification_opened', {});

  static void logInterstitialLoadAttempted() =>
      _send('interstitial_load_attempted', {});
  static void logInterstitialLoaded() => _send('interstitial_loaded', {});
  static void logInterstitialLoadFailed() =>
      _send('interstitial_load_failed', {});
  static void logInterstitialShowAttempted() =>
      _send('interstitial_show_attempted', {});
  static void logInterstitialShown() => _send('interstitial_shown', {});
  static void logInterstitialFailed() => _send('interstitial_failed', {});
  static void logInterstitialDismissed() => _send('interstitial_dismissed', {});
  static void _send(String name, Map<String, Object> parameters) {
    try {
      final logger = _logger ??= FirebaseAnalyticsEventLogger(
        FirebaseAnalytics.instance,
      );
      unawaited(
        logger.logEvent(name: name, parameters: parameters).catchError((_) {}),
      );
    } catch (_) {
      // Analytics is deliberately non-critical when Firebase is unavailable.
    }
  }

  /// Test seam; production code always uses [FirebaseAnalytics].
  static void setLoggerForTesting(AnalyticsEventLogger logger) {
    _logger = logger;
  }

  static void resetLoggerForTesting() {
    _logger = null;
  }
}
