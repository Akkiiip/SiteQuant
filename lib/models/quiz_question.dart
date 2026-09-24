class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.category,
    required this.difficulty,
  });

  final String id;
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String explanation;
  final String category;
  final String difficulty;
}
