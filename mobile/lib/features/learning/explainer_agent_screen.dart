import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/noise_background.dart';
import '../../../core/widgets/terminal_loader.dart';
import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/services/api_service.dart';

class ExplainerAgentScreen extends StatefulWidget {
  const ExplainerAgentScreen({super.key});

  @override
  State<ExplainerAgentScreen> createState() => _ExplainerAgentScreenState();
}

class _ExplainerAgentScreenState extends State<ExplainerAgentScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  bool _loading = false;
  String? _error;
  String _output = '';

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _explain() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    if (!mounted) return;
    setState(() { _loading = true; _error = null; _output = ''; });
    try {
      final formData = FormData.fromMap({'text': text, 'complexity': 'medium'});
      final res = await ApiService.postMultipart(ApiEndpoints.explainerGenerate, formData: formData);
      final data = res.data as Map<String, dynamic>?;
      if (!mounted) return;
      setState(() {
        _output = data?['explanation']?.toString() ?? data?.toString() ?? '';
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString().replaceFirst('Exception: ', ''); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NoiseBackground(
        opacity: 0.04,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.mercury), onPressed: () => context.pop()),
                    Text('EXPLAINER AGENT', style: AppTypography.tag),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Text('> ', style: AppTypography.terminalPrefix),
                          Expanded(
                            child: TextField(
                              controller: _inputController,
                              style: AppTypography.bodyMedium,
                              decoration: const InputDecoration(hintText: 'Paste topic or code to explain...'),
                              onSubmitted: (_) => _explain(),
                            ),
                          ),
                          IconButton(icon: Icon(Icons.lightbulb, color: AppColors.ember), onPressed: _loading ? null : _explain),
                        ],
                      ),
                    ),
                    if (_error != null) Padding(padding: const EdgeInsets.all(16), child: Text(_error!, style: AppTypography.bodySmall.copyWith(color: AppColors.ember))),
                    Expanded(
                      child: _loading
                          ? const Center(child: TerminalLoader(message: 'EXPLAINING...', prefix: '> '))
                          : SingleChildScrollView(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(20),
                              child: SelectableText(_output.isEmpty ? 'Output will appear here.' : _output, style: AppTypography.bodyMedium),
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
}
