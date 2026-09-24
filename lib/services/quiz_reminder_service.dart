import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class QuizReminderPlatform {
  Future<bool> requestPermission();
  Future<void> scheduleWeekly();
  Future<void> cancel();
  Future<bool> wasOpenedFromNotification();
  void setOpenedHandler(VoidCallback handler);
}

class AndroidQuizReminderPlatform implements QuizReminderPlatform {
  static const _channel = MethodChannel('com.sitequant.app/quiz_reminder');

  @override
  Future<bool> requestPermission() async =>
      await _channel.invokeMethod<bool>('requestPermission') ?? false;

  @override
  Future<void> scheduleWeekly() => _channel.invokeMethod('scheduleWeekly');

  @override
  Future<void> cancel() => _channel.invokeMethod('cancel');

  @override
  Future<bool> wasOpenedFromNotification() async =>
      await _channel.invokeMethod<bool>('wasOpenedFromNotification') ?? false;

  @override
  void setOpenedHandler(VoidCallback handler) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'notificationOpened') handler();
    });
  }
}

class QuizReminderService {
  QuizReminderService({QuizReminderPlatform? platform})
    : _platform = platform ?? AndroidQuizReminderPlatform();

  static const preferenceKey = 'weekly_quiz_reminder_enabled';
  static final navigationRequest = ValueNotifier<int>(0);
  static QuizReminderService instance = QuizReminderService();

  final QuizReminderPlatform _platform;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    try {
      _platform.setOpenedHandler(_requestLearnNavigation);
      if (await _platform.wasOpenedFromNotification()) {
        _requestLearnNavigation();
      }
    } catch (_) {
      // Notifications are optional and must never block app startup.
    }
  }

  Future<bool> isEnabled() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(preferenceKey) ?? false;
  }

  Future<bool> setEnabled(bool enabled) async {
    final preferences = await SharedPreferences.getInstance();
    if (!enabled) {
      try {
        await _platform.cancel();
      } catch (_) {}
      await preferences.setBool(preferenceKey, false);
      return false;
    }

    try {
      if (!await _platform.requestPermission()) {
        await preferences.setBool(preferenceKey, false);
        return false;
      }
      // The native side cancels the stable PendingIntent before scheduling it.
      await _platform.scheduleWeekly();
      await preferences.setBool(preferenceKey, true);
      return true;
    } catch (_) {
      await preferences.setBool(preferenceKey, false);
      return false;
    }
  }

  static void _requestLearnNavigation() => navigationRequest.value++;
}
