import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/noise_background.dart';
import '../../../core/widgets/terminal_loader.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/services/api_service.dart';

class CoverLetterScreen extends StatefulWidget {
  const CoverLetterScreen({super.key});

  @override
  State<CoverLetterScreen> createState() => _CoverLetterScreenState();
}

class _CoverLetterScreenState extends State<CoverLetterScreen> {
  final _jdController = TextEditingController();
  final _titleController = TextEditingController();
  final _companyController = TextEditingController();
  bool _loading = false;
  String? _error;
  String? _coverLetter;
  String? _tailoredResume;

  @override
  void dispose() {
    _jdController.dispose();
    _titleController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final jd = _jdController.text.trim();
    final title = _titleController.text.trim();
    final company = _companyController.text.trim();
    if (jd.isEmpty) return;
    if (!mounted) return;
    setState(() { _loading = true; _error = null; _coverLetter = null; _tailoredResume = null; });
    try {
      final res = await ApiService.post(ApiEndpoints.jobApplicationGenerate, data: {
        'job_description': jd,
        'job_title': title.isEmpty ? 'Role' : title,
        'company': company.isEmpty ? 'Company' : company,
      });
      final data = res.data as Map<String, dynamic>?;
      if (!mounted) return;
      setState(() {
        _coverLetter = data?['cover_letter'] ?? data?['tailored_resume']?.toString();
        _tailoredResume = data?['tailored_resume']?.toString();
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
                    Text('COVER LETTER', style: AppTypography.tag),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('> JOB TITLE', style: AppTypography.terminalPrefix),
                      TextField(controller: _titleController, style: AppTypography.bodyMedium, decoration: const InputDecoration(hintText: 'Job title')),
                      const SizedBox(height: 12),
                      Text('> COMPANY', style: AppTypography.terminalPrefix),
                      TextField(controller: _companyController, style: AppTypography.bodyMedium, decoration: const InputDecoration(hintText: 'Company name')),
                      const SizedBox(height: 12),
                      Text('> JOB DESCRIPTION', style: AppTypography.terminalPrefix),
                      TextField(controller: _jdController, style: AppTypography.bodyMedium, maxLines: 5, decoration: const InputDecoration(hintText: 'Paste job description')),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _generate,
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.ember, foregroundColor: AppColors.mercury, shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
                          child: _loading ? const TerminalLoader(message: 'GENERATING...', prefix: '> ') : Text('GENERATE', style: AppTypography.label),
                        ),
                      ),
                      if (_error != null) Text(_error!, style: AppTypography.bodySmall.copyWith(color: AppColors.ember)),
                      if (_coverLetter != null) ...[
                        const SizedBox(height: 24),
                        Text('COVER LETTER', style: AppTypography.tag),
                        const SizedBox(height: 8),
                        SelectableText(_coverLetter!, style: AppTypography.bodyMedium),
                      ],
                      if (_tailoredResume != null) ...[
                        const SizedBox(height: 24),
                        Text('TAILORED RESUME', style: AppTypography.tag),
                        const SizedBox(height: 8),
                        SelectableText(_tailoredResume!, style: AppTypography.bodyMedium),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
