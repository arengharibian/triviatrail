import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../app.dart';
import '../data/models.dart';
import '../data/db_helper.dart';
import '../data/api_service.dart';

class LevelDetailScreen extends StatefulWidget {
  final Level level;

  const LevelDetailScreen({super.key, required this.level});

  @override
  State<LevelDetailScreen> createState() => _LevelDetailScreenState();
}

class _LevelDetailScreenState extends State<LevelDetailScreen> {
  final _player = AudioPlayer();
  final _api = TriviaApiService();

  late List<Question> _questions;
  int _currentIndex = 0;
  int _score = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    // For demo: API bonus questions only.
    final bonus = await _api.fetchBonusQuestions(widget.level.id);
    setState(() {
      _questions = bonus;
      _loading = false;
    });
  }

  Future<void> _handleAnswer(int selectedIndex) async {
    final q = _questions[_currentIndex];
    final correct = selectedIndex == q.correctIndex;

    if (correct) {
      _score += 10;
      _player.play(AssetSource('sounds/correct.mp3'));
    } else {
      _player.play(AssetSource('sounds/wrong.mp3'));
    }

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(correct ? 'Nice!' : 'Oops'),
        content: Text(
          correct ? 'You earned 10 points.' : 'Better luck on the next one.',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );

    if (_currentIndex < _questions.length - 1) {
      setState(() => _currentIndex++);
    } else {
      await DBHelper.instance
          .upsertProgress(widget.level.id, true, _score);

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: widget.level.title,
      body: Hero(
        tag: 'level-${widget.level.id}',
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Score: $_score',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'Q ${_currentIndex + 1}/${_questions.length}',
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _buildQuestionCard(context),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildQuestionCard(BuildContext context) {
    final q = _questions[_currentIndex];
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 6,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                q.text,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              ...List.generate(
                q.options.length,
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    onPressed: () => _handleAnswer(index),
                    child: Text(q.options[index]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
