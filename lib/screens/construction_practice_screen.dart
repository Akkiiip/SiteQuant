import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/quiz_question_bank.dart';
import '../services/analytics_service.dart';
import '../services/quiz_reminder_service.dart';
import '../services/quiz_session.dart';
import '../theme/app_theme.dart';

class ConstructionPracticeScreen extends StatefulWidget {
  const ConstructionPracticeScreen({super.key});

  @override
  State<ConstructionPracticeScreen> createState() =>
      _ConstructionPracticeScreenState();
}

class _ConstructionPracticeScreenState
    extends State<ConstructionPracticeScreen> {
  static const _previousScoreKey = 'quiz_previous_score';
  int? _previousScore;
  bool _reminderEnabled = false;
  bool _updatingReminder = false;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final preferences = await SharedPreferences.getInstance();
    final reminderEnabled = await QuizReminderService.instance.isEnabled();
    if (!mounted) return;
    setState(() {
      _previousScore = preferences.getInt(_previousScoreKey);
      _reminderEnabled = reminderEnabled;
    });
  }

  Future<void> _startQuiz() async {
    AnalyticsService.logQuizStarted();
    final score = await Navigator.push<int>(
      context,
      MaterialPageRoute(builder: (_) => const ConstructionQuizScreen()),
    );
    if (score == null) return;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(_previousScoreKey, score);
    if (mounted) setState(() => _previousScore = score);
  }

  Future<void> _setReminder(bool enabled) async {
    if (_updatingReminder) return;
    setState(() => _updatingReminder = true);
    final actual = await QuizReminderService.instance.setEnabled(enabled);
    if (!mounted) return;
    setState(() {
      _reminderEnabled = actual;
      _updatingReminder = false;
    });
    if (actual) {
      AnalyticsService.logQuizReminderEnabled();
    } else if (!enabled) {
      AnalyticsService.logQuizReminderDisabled();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Notifications are unavailable or permission was denied.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => ListView(
    key: const Key('construction-practice-scroll-view'),
    padding: const EdgeInsets.all(20),
    children: [
      Text(
        'Construction Practice',
        style: Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 14),
      Card(
        color: AppTheme.navy,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quick Civil Engineering Quiz',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 8),
              const Text(
                'Test your civil engineering knowledge with a quick 10-question quiz.',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              FilledButton(
                key: const Key('start-quiz-button'),
                onPressed: _startQuiz,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primaryBlue,
                  minimumSize: const Size(140, 48),
                ),
                child: const Text('Start Quiz'),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 14),
      Row(
        children: [
          Expanded(
            child: _QuizStat(
              label: 'Previous Score',
              value: _previousScore == null ? '—' : '$_previousScore/10',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _QuizStat(
              label: 'Questions Available',
              value: '${quizQuestionBank.length}',
            ),
          ),
        ],
      ),
      const SizedBox(height: 14),
      Card(
        child: SwitchListTile(
          key: const Key('weekly-quiz-reminder-switch'),
          value: _reminderEnabled,
          onChanged: _updatingReminder ? null : _setReminder,
          title: const Text('Weekly Quiz Reminder'),
          subtitle: const Text('One optional reminder each week'),
          secondary: const Icon(Icons.notifications_outlined),
        ),
      ),
      const SizedBox(height: 20),
      Text('Topics covered', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 10),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: quizCategories
            .map((category) => Chip(label: Text(category)))
            .toList(),
      ),
    ],
  );
}

class _QuizStat extends StatelessWidget {
  const _QuizStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    ),
  );
}

class ConstructionQuizScreen extends StatefulWidget {
  const ConstructionQuizScreen({super.key});

  @override
  State<ConstructionQuizScreen> createState() => _ConstructionQuizScreenState();
}

class _ConstructionQuizScreenState extends State<ConstructionQuizScreen> {
  late final QuizSession _session;

  @override
  void initState() {
    super.initState();
    _session = QuizSession();
  }

  void _next() {
    final completing = _session.currentIndex == _session.questions.length - 1;
    setState(_session.next);
    if (completing) {
      AnalyticsService.logQuizCompleted(
        score: _session.score,
        percentage: _session.percentage,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_session.isComplete) return _results(context);
    final question = _session.currentQuestion;
    return Scaffold(
      appBar: AppBar(title: const Text('Construction Practice')),
      body: SafeArea(
        child: ListView(
          key: const Key('quiz-scroll-view'),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            LinearProgressIndicator(
              value: (_session.currentIndex + 1) / _session.questions.length,
            ),
            const SizedBox(height: 14),
            Text(
              'Question ${_session.currentIndex + 1} of 10',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            Text(
              '${question.category} · ${question.difficulty}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            Text(
              question.question,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            ...question.options.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: OutlinedButton(
                  key: Key('quiz-option-${entry.key}'),
                  onPressed: _session.isAnswered
                      ? null
                      : () => setState(() => _session.answer(entry.key)),
                  style: OutlinedButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    minimumSize: const Size.fromHeight(56),
                    side: BorderSide(
                      color: _session.selectedAnswer == entry.key
                          ? (entry.key == question.correctAnswer
                                ? Colors.green
                                : Colors.red)
                          : AppTheme.border,
                    ),
                  ),
                  child: Text(
                    '${String.fromCharCode(65 + entry.key)}  ${entry.value}',
                  ),
                ),
              ),
            ),
            if (_session.isAnswered) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      (_session.selectedAnswer == question.correctAnswer
                              ? Colors.green
                              : Colors.red)
                          .withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _session.selectedAnswer == question.correctAnswer
                      ? 'Correct! ${question.explanation}'
                      : 'Incorrect. Correct answer: ${question.options[question.correctAnswer]}. ${question.explanation}',
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  key: const Key('quiz-next-button'),
                  onPressed: _next,
                  child: Text(
                    _session.currentIndex == 9 ? 'See Results' : 'Next',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _results(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Quiz Results')),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                const Icon(
                  Icons.emoji_events_rounded,
                  size: 64,
                  color: Color(0xFFF4AE00),
                ),
                const SizedBox(height: 14),
                Text(
                  'Quiz complete',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  '${_session.score} / 10',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppTheme.navy,
                  ),
                ),
                Text(
                  '${_session.percentage}%',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Topics covered',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 6,
                  runSpacing: 6,
                  children: _session.categoriesCovered
                      .map((category) => Chip(label: Text(category)))
                      .toList(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    key: const Key('retry-quiz-button'),
                    onPressed: () {
                      AnalyticsService.logQuizStarted();
                      setState(_session.retry);
                    },
                    child: const Text('Retry Quiz'),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, _session.score),
                  child: const Text('Back to Learn'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
