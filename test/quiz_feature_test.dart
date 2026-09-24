import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:site_quant/data/quiz_question_bank.dart';
import 'package:site_quant/screens/construction_practice_screen.dart';
import 'package:site_quant/services/quiz_reminder_service.dart';
import 'package:site_quant/services/quiz_session.dart';

class _FakeReminderPlatform implements QuizReminderPlatform {
  _FakeReminderPlatform({this.permission = true, this.opened = false});
  bool permission;
  bool opened;
  bool scheduled = false;
  int scheduleCalls = 0;
  int cancelCalls = 0;
  VoidCallback? openedHandler;

  @override
  Future<void> cancel() async {
    cancelCalls++;
    scheduled = false;
  }

  @override
  Future<bool> requestPermission() async => permission;

  @override
  Future<void> scheduleWeekly() async {
    scheduleCalls++;
    scheduled = true;
  }

  @override
  void setOpenedHandler(VoidCallback handler) => openedHandler = handler;

  @override
  Future<bool> wasOpenedFromNotification() async => opened;
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    QuizReminderService.navigationRequest.value = 0;
  });

  test(
    'question bank has at least 75 valid questions across all categories',
    () {
      expect(quizQuestionBank.length, greaterThanOrEqualTo(75));
      expect(
        quizQuestionBank.map((q) => q.category).toSet(),
        quizCategories.toSet(),
      );
      expect(
        quizQuestionBank.map((q) => q.id).toSet().length,
        quizQuestionBank.length,
      );
      for (final question in quizQuestionBank) {
        expect(question.question, isNotEmpty);
        expect(question.options, hasLength(4));
        expect(question.correctAnswer, inInclusiveRange(0, 3));
        expect(question.explanation, isNotEmpty);
        expect(question.difficulty, isNotEmpty);
      }
    },
  );

  test('session selects ten randomized questions without duplicates', () {
    final first = QuizSession(random: Random(1));
    final second = QuizSession(random: Random(2));
    expect(first.questions, hasLength(10));
    expect(first.questions.map((q) => q.id).toSet(), hasLength(10));
    expect(
      first.questions.map((q) => q.id).toList(),
      isNot(second.questions.map((q) => q.id).toList()),
    );
  });

  test('scoring counts correct answers once and retry resets the session', () {
    final session = QuizSession(random: Random(3));
    expect(session.answer(session.currentQuestion.correctAnswer), isTrue);
    expect(session.score, 1);
    expect(session.answer(session.currentQuestion.correctAnswer), isFalse);
    expect(session.score, 1);
    session.next();
    session.answer((session.currentQuestion.correctAnswer + 1) % 4);
    expect(session.score, 1);
    session.retry();
    expect(session.score, 0);
    expect(session.currentIndex, 0);
    expect(session.selectedAnswer, isNull);
    expect(session.questions, hasLength(10));
  });

  testWidgets('quiz has no overflow at 360x800 and remains scrollable', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: ConstructionQuizScreen()));
    expect(find.text('Question 1 of 10'), findsOneWidget);
    expect(find.byKey(const Key('quiz-scroll-view')), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.byKey(const Key('quiz-option-0')));
    await tester.pump();
    expect(find.byKey(const Key('quiz-next-button')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test(
    'reminder persists ON/OFF and repeated enable keeps one active reminder',
    () async {
      final platform = _FakeReminderPlatform();
      final service = QuizReminderService(platform: platform);
      expect(await service.setEnabled(true), isTrue);
      expect(await service.isEnabled(), isTrue);
      expect(platform.scheduled, isTrue);
      expect(await service.setEnabled(true), isTrue);
      expect(platform.scheduled, isTrue);
      expect(platform.scheduleCalls, 2);
      expect(await service.setEnabled(false), isFalse);
      expect(await service.isEnabled(), isFalse);
      expect(platform.scheduled, isFalse);
      expect(platform.cancelCalls, 1);
    },
  );

  test('denied permission leaves reminder disabled', () async {
    final service = QuizReminderService(
      platform: _FakeReminderPlatform(permission: false),
    );
    expect(await service.setEnabled(true), isFalse);
    expect(await service.isEnabled(), isFalse);
  });

  test('notification launch requests Learn navigation', () async {
    final service = QuizReminderService(
      platform: _FakeReminderPlatform(opened: true),
    );
    await service.initialize();
    expect(QuizReminderService.navigationRequest.value, 1);
  });
}
