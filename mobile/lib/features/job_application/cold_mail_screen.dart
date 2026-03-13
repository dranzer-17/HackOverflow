import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/noise_background.dart';
import '../../../core/widgets/terminal_loader.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/services/api_service.dart';

class ColdMailScreen extends StatefulWidget {
  const ColdMailScreen({super.key});

  @override
  State<ColdMailScreen> createState() => _ColdMailScreenState();
}

class _ColdMailScreenState extends State<ColdMailScreen> {
  final _companyController = TextEditingController();
  final _roleController = TextEditingController();
  bool _loading = false;
  String? _error;
  String? _subject;
  String? _body;

  @override
  void dispose() {
    _companyController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  Future<void> _generateTemplate() async {
    final company = _companyController.text.trim();
    if (company.isEmpty) return;
    if (!mounted) return;
    setState(() { _loading = true; _error = null; _subject = null; _body = null; });
    try {
      final res = await ApiService.post(ApiEndpoints.coldMailGenerateTemplate, data: {
        'company_name': company,
        'user_name': 'Applicant',
        'user_email': 'applicant@example.com',
      });
      final data = res.data as Map<String, dynamic>?;
      if (!mounted) return;
      setState(() {
        _subject = data?['subject']?.toString();
        final bodyRaw = data?['body']?.toString();
        _body = bodyRaw?.replaceAll(r'\n', '\n');
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
                    Text('COLD MAIL SENDER', style: AppTypography.tag),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('> COMPANY', style: AppTypography.terminalPrefix),
                      TextField(controller: _companyController, style: AppTypography.bodyMedium, decoration: const InputDecoration(hintText: 'Company name')),
                      const SizedBox(height: 12),
                      Text('> ROLE / CONTACT', style: AppTypography.terminalPrefix),
                      TextField(controller: _roleController, style: AppTypography.bodyMedium, decoration: const InputDecoration(hintText: 'e.g. Recruiter')),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _generateTemplate,
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.ember, foregroundColor: AppColors.mercury, shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
                          child: _loading ? const TerminalLoader(message: 'GENERATING...', prefix: '> ') : Text('GENERATE TEMPLATE', style: AppTypography.label),
                        ),
                      ),
                      if (_error != null) Text(_error!, style: AppTypography.bodySmall.copyWith(color: AppColors.ember)),
                      if (_subject != null || _body != null) ...[
                        const SizedBox(height: 24),
                        Text('SUBJECT', style: AppTypography.tag),
                        const SizedBox(height: 4),
                        SelectableText(_subject ?? '', style: AppTypography.bodyMedium),
                        const SizedBox(height: 12),
                        Text('BODY', style: AppTypography.tag),
                        const SizedBox(height: 4),
                        SelectableText(_body ?? '', style: AppTypography.bodySmall),
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
