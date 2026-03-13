import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/noise_background.dart';
import '../../../../core/widgets/morpheus_avatar.dart' show MorpheusAvatarController, AvatarState;
import '../../../../core/widgets/terminal_loader.dart';

class MockInterviewScreen extends StatefulWidget {
  const MockInterviewScreen({super.key});

  @override
  State<MockInterviewScreen> createState() => _MockInterviewScreenState();
}

class _MockInterviewScreenState extends State<MockInterviewScreen> {
  final _controller = MorpheusAvatarController();
  final _answerController = TextEditingController();
  String _currentQuestion = 'When you\'re ready, tap Start to begin the interview.';
  int _questionIndex = 0;
  bool _started = false;
  bool _loading = false;
  final int _seconds = 0;

  @override
  void initState() {
    super.initState();
    _controller.init();
  }

  @override
  void dispose() {
    _controller.dispose();
    _answerController.dispose();
    super.dispose();
  }

  void _startInterview() {
    HapticFeedback.heavyImpact();
    setState(() {
      _started = true;
      _currentQuestion = 'Tell me about yourself and your background.';
      _questionIndex = 1;
      _controller.setState(AvatarState.speaking);
    });
    _controller.speak(_currentQuestion);
  }

  void _submitAnswer() {
    final answer = _answerController.text.trim();
    if (answer.isEmpty) return;
    _answerController.clear();
    setState(() {
      _loading = true;
      _controller.setState(AvatarState.thinking);
    });
    // Simulate next question
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      final next = _getNextQuestion();
      setState(() {
        _currentQuestion = next;
        _questionIndex++;
        _loading = false;
        _controller.setState(AvatarState.speaking);
      });
      _controller.speak(next);
    });
  }

  String _getNextQuestion() {
    const questions = [
      'What are your greatest strengths?',
      'Describe a challenging project you worked on.',
      'Where do you see yourself in 5 years?',
      'Do you have any questions for us?',
    ];
    final i = (_questionIndex - 1) % questions.length;
    return questions[i.clamp(0, questions.length - 1)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NoiseBackground(
        opacity: 0.04,
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'INTERVIEWER',
                        style: AppTypography.tag,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        _currentQuestion,
                        style: AppTypography.displaySmall.copyWith(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (_loading)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TerminalLoader(message: 'THINKING...', prefix: '> '),
                      )
                    else if (_started) ...[
                      Text(
                        '${_seconds ~/ 60}:${(_seconds % 60).toString().padLeft(2, '0')}',
                        style: AppTypography.bodyLarge.copyWith(color: AppColors.smog),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _answerController,
                                style: AppTypography.bodyMedium,
                                decoration: const InputDecoration(
                                  hintText: 'Type your answer or use mic...',
                                  border: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.ember)),
                                ),
                                onSubmitted: (_) => _submitAnswer(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: Icon(Icons.mic, color: AppColors.ember, size: 32),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: Icon(Icons.send, color: AppColors.ember),
                              onPressed: _submitAnswer,
                            ),
                          ],
                        ),
                      ),
                    ] else
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _startInterview,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.ember,
                              foregroundColor: AppColors.mercury,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                            ),
                            child: Text('START INTERVIEW', style: AppTypography.tag.copyWith(color: AppColors.mercury)),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.mercury),
            onPressed: () => context.pop(),
          ),
          Text('AI MOCK INTERVIEW', style: AppTypography.tag),
        ],
      ),
    );
  }
}
