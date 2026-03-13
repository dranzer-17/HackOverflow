import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/feature_scaffold.dart';
import '../../../core/widgets/dashboard_card.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/services/api_service.dart';
import 'ppt_download_stub.dart' if (dart.library.html) 'ppt_download_web.dart' as ppt_download;

class PptMakerScreen extends StatefulWidget {
  const PptMakerScreen({super.key});

  @override
  State<PptMakerScreen> createState() => _PptMakerScreenState();
}

class _PptMakerScreenState extends State<PptMakerScreen> {
  final _topicController = TextEditingController();
  bool _loading = false;
  String? _error;
  String? _title;
  List<dynamic> _slides = [];
  bool _downloading = false;

  bool get _hasResult => _slides.isNotEmpty;

  Future<void> _generate() async {
    final topic = _topicController.text.trim();
    if (topic.isEmpty) return;
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
      _title = null;
      _slides = [];
    });
    try {
      final outlineRes = await ApiService.post(
        ApiEndpoints.presentationOutline,
        data: {
          'prompt': topic,
          'num_slides': 5,
          'language': 'en-US',
        },
      );
      final outlineData = outlineRes.data as Map<String, dynamic>?;
      final title = outlineData?['title'] as String? ?? 'Presentation';
      final outline = (outlineData?['outline'] as List<dynamic>?)?.cast<String>() ?? <String>[];
      if (outline.isEmpty) {
        if (mounted) setState(() { _error = 'No outline generated'; _loading = false; });
        return;
      }
      final res = await ApiService.post(
        ApiEndpoints.presentationGenerate,
        data: {
          'title': title,
          'prompt': topic,
          'outline': outline,
          'language': 'en-US',
          'tone': 'professional',
          'theme': 'default',
        },
      );
      if (!mounted) return;
      final data = res.data as Map<String, dynamic>?;
      final slides = data?['slides'] is List ? data!['slides'] as List<dynamic> : <dynamic>[];
      setState(() {
        _title = data?['title'] as String? ?? title;
        _slides = slides;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  void _startOver() {
    setState(() {
      _title = null;
      _slides = [];
      _error = null;
    });
    _topicController.clear();
  }

  Future<void> _downloadPptx() async {
    if (_title == null || _slides.isEmpty) return;
    if (!mounted) return;
    setState(() => _downloading = true);
    try {
      final res = await ApiService.dio.post<List<int>>(
        ApiEndpoints.presentationDownload,
        data: {
          'title': _title,
          'slides': _slides,
          'theme': 'default',
          'font': 'Inter',
        },
        options: Options(responseType: ResponseType.bytes),
      );
      if (!mounted) return;
      final bytes = res.data;
      if (bytes != null && bytes.isNotEmpty) {
        await ppt_download.savePptxBytes(
          bytes,
          '${_title!.replaceAll(RegExp(r'[^\w\s-]'), '_')}.pptx',
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PPTX download started')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasResult && !_loading) {
      return FeatureScaffold(
        title: 'PPT Maker',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade700, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Presentation generated successfully',
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade900,
                          ),
                        ),
                        Text(
                          '${_slides.length} slides • Theme: default',
                          style: AppTypography.bodySmall.copyWith(color: Colors.green.shade800),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                FilledButton.icon(
                  onPressed: _downloading ? null : _downloadPptx,
                  icon: _downloading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.download, size: 18),
                  label: Text(_downloading ? 'Preparing...' : 'Download PPTX'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _startOver,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Start over'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              _title ?? 'Presentation',
              style: AppTypography.displaySmall.copyWith(
                color: AppColors.foreground,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(_slides.length, (index) {
              final slide = _slides[index];
              if (slide is! Map<String, dynamic>) return const SizedBox.shrink();
              final content = slide['content'] is Map ? slide['content'] as Map<String, dynamic> : null;
              final heading = content?['heading']?.toString() ?? 'Slide ${index + 1}';
              final items = content?['items'] is List ? content!['items'] as List<dynamic> : <dynamic>[];
              return _SlideCard(
                slideIndex: index + 1,
                heading: heading,
                items: items,
              );
            }),
          ],
        ),
      );
    }

    return FeatureScaffold(
      title: 'PPT Maker',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Turn a topic into polished, downloadable slides powered by AI.',
            style: AppTypography.bodySmall.copyWith(color: AppColors.foregroundDim),
          ),
          const SizedBox(height: 24),
          DashboardCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "What's your presentation about?",
                  style: AppTypography.label.copyWith(
                    color: AppColors.foreground,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _topicController,
                  decoration: const InputDecoration(
                    hintText: 'E.g. Machine learning vs deep learning',
                    border: OutlineInputBorder(),
                    filled: true,
                  ),
                  maxLines: 2,
                  onSubmitted: (_) => _generate(),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _loading ? null : _generate,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Generate PPT'),
                  ),
                ),
              ],
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, size: 20, color: Colors.red.shade700),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _error!,
                      style: AppTypography.bodySmall.copyWith(color: Colors.red.shade800),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SlideCard extends StatelessWidget {
  const _SlideCard({
    required this.slideIndex,
    required this.heading,
    required this.items,
  });

  final int slideIndex;
  final String heading;
  final List<dynamic> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DashboardCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primaryWithOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$slideIndex',
                    style: AppTypography.label.copyWith(
                      color: AppColors.primary,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    heading,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.foreground,
                    ),
                  ),
                ),
              ],
            ),
            if (items.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...items.map((item) {
                final text = item is Map ? (item['text']?.toString() ?? '') : item.toString();
                final subtext = item is Map ? item['subtext']?.toString() : null;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              text,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.foreground,
                              ),
                            ),
                            if (subtext != null && subtext.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  subtext,
                                  style: AppTypography.bodySmall.copyWith(
                                    fontSize: 11,
                                    color: AppColors.foregroundDim,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}
