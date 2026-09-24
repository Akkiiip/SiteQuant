import 'dart:math';

import '../data/quiz_question_bank.dart';
import '../models/quiz_question.dart';

class QuizSession {
  QuizSession({Random? random, String? category})
    : _random = random ?? Random(),
      category = category,
      questions = _selectQuestions(random ?? Random(), category);

  final Random _random;
  final String? category;
  List<QuizQuestion> questions;
  int currentIndex = 0;
  int score = 0;
  int? selectedAnswer;

  bool get isAnswered => selectedAnswer != null;
  bool get isComplete => currentIndex >= questions.length;
  QuizQuestion get currentQuestion => questions[currentIndex];
  int get percentage => ((score / questions.length) * 100).round();
  Set<String> get categoriesCovered => questions.map((q) => q.category).toSet();

  bool answer(int option) {
    if (isAnswered || isComplete) return false;
    selectedAnswer = option;
    if (option == currentQuestion.correctAnswer) score++;
    return true;
  }

  void next() {
    if (!isAnswered || isComplete) return;
    currentIndex++;
    selectedAnswer = null;
  }

  void retry() {
    questions = _selectQuestions(_random, category);
    currentIndex = 0;
    score = 0;
    selectedAnswer = null;
  }

  static List<QuizQuestion> _selectQuestions(Random random, String? category) {
    final pool =
        quizQuestionBank
            .where(
              (question) => category == null || question.category == category,
            )
            .toList()
          ..shuffle(random);
    return pool.take(10).toList(growable: false);
  }
}
