import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/noise_background.dart';
import '../../../core/widgets/terminal_loader.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/services/api_service.dart';

class ResumeAtsScreen extends StatefulWidget {
  const ResumeAtsScreen({super.key});

  @override
  State<ResumeAtsScreen> createState() => _ResumeAtsScreenState();
}

class _ResumeAtsScreenState extends State<ResumeAtsScreen> {
  bool _loading = false;
  String? _error;
  Map<String, dynamic>? _result;

  Future<void> _pickAndAnalyze() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any, allowMultiple: false);
    if (result == null || result.files.single.bytes == null) return;
    if (!mounted) return;
    setState(() { _loading = true; _error = null; _result = null; });
    try {
      final file = result.files.single;
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(file.bytes!, filename: file.name),
      });
      final res = await ApiService.dio.post(
        ApiEndpoints.resumeAnalyzerAnalyze,
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );
      if (!mounted) return;
      setState(() { _result = res.data as Map<String, dynamic>?; _loading = false; });
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
                    Text('RESUME ATS SCORE', style: AppTypography.tag),
                  ],
                ),
              ),
              Expanded(
                child: _loading
                    ? const Center(child: TerminalLoader(message: 'ANALYZING...', prefix: '> '))
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            GestureDetector(
                              onTap: _pickAndAnalyze,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 40),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.ember, width: 2, style: BorderStyle.solid),
                                ),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Icon(Icons.upload_file, color: AppColors.ember, size: 48),
                                      const SizedBox(height: 12),
                                      Text('DROP RESUME OR TAP TO UPLOAD', style: AppTypography.label),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            if (_error != null) ...[
                              const SizedBox(height: 16),
                              Text(_error!, style: AppTypography.bodySmall.copyWith(color: AppColors.ember)),
                            ],
                            if (_result != null) ...[
                              const SizedBox(height: 24),
                              Text('SCORE / BREAKDOWN', style: AppTypography.tag),
                              const SizedBox(height: 8),
                              Text(_result.toString(), style: AppTypography.bodySmall),
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
