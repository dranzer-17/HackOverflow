import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/feature_scaffold.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/services/api_service.dart';

class RoadmapGeneratorScreen extends StatefulWidget {
  const RoadmapGeneratorScreen({super.key});

  @override
  State<RoadmapGeneratorScreen> createState() => _RoadmapGeneratorScreenState();
}

class _RoadmapGeneratorScreenState extends State<RoadmapGeneratorScreen> {
  final _topicController = TextEditingController();
  bool _loading = false;
  String? _error;
  String _topic = '';
  String _mermaidCode = '';
  List<dynamic> _nodes = [];
  bool _saving = false;

  bool get _hasRoadmap => _nodes.isNotEmpty;

  Future<void> _generate() async {
    final topic = _topicController.text.trim();
    if (topic.isEmpty) return;
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
      _nodes = [];
      _mermaidCode = '';
      _topic = topic;
    });
    try {
      final res = await ApiService.post(
        ApiEndpoints.roadmapGenerate,
        data: {'topic': topic},
        receiveTimeout: const Duration(minutes: 5),
      );
      if (!mounted) return;
      final data = res.data is Map ? res.data as Map<String, dynamic> : null;
      final nodes = data?['nodes'];
      final list = nodes is List ? nodes : [];
      final mermaid = data?['mermaid_code']?.toString() ?? '';
      setState(() {
        _nodes = list;
        _mermaidCode = mermaid;
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

  Future<void> _save() async {
    if (_mermaidCode.isEmpty || _nodes.isEmpty) return;
    if (!mounted) return;
    setState(() => _saving = true);
    try {
      await ApiService.post(
        ApiEndpoints.saveRoadmap,
        data: {
          'topic': _topic,
          'mermaid_code': _mermaidCode,
          'nodes': _nodes,
          'notes': null,
        },
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Roadmap saved successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _newTopic() {
    setState(() {
      _topic = '';
      _nodes = [];
      _mermaidCode = '';
      _error = null;
    });
    _topicController.clear();
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Roadmap generated: show nodes + resources (like website)
    if (_hasRoadmap && !_loading) {
      return FeatureScaffold(
        title: 'Roadmap Generator',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$_topic Learning Roadmap',
                    style: AppTypography.displaySmall.copyWith(
                      color: AppColors.foreground,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap a resource to open it. Save to access later from the web app.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.foregroundDim,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      FilledButton.icon(
                        onPressed: _saving ? null : _save,
                        icon: _saving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save, size: 18),
                        label: Text(_saving ? 'Saving...' : 'Save'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: _newTopic,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('New topic'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _FlowchartStrip(
              topics: _nodes
                  .map((n) => n is Map ? (n['topic']?.toString() ?? '') : '')
                  .where((s) => s.isNotEmpty)
                  .toList(),
            ),
            const SizedBox(height: 20),
            ...List.generate(_nodes.length, (index) {
              final node = _nodes[index];
              if (node is! Map<String, dynamic>) return const SizedBox.shrink();
              final topic = node['topic']?.toString() ?? 'Topic';
              final resources = node['resources'] is List
                  ? node['resources'] as List<dynamic>
                  : <dynamic>[];
              return _NodeCard(
                topic: topic,
                resources: resources,
                onOpenUrl: _openUrl,
              );
            }),
          ],
        ),
      );
    }

    // Input step (like website)
    return FeatureScaffold(
      title: 'Roadmap Generator',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Generate a personalized learning path with curated courses and videos.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.foregroundDim,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What do you want to learn?',
                  style: AppTypography.label.copyWith(
                    color: AppColors.foreground,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _topicController,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Machine Learning, React, Python...',
                    border: OutlineInputBorder(),
                    filled: true,
                  ),
                  onSubmitted: (_) => _generate(),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: (_loading || _topicController.text.trim().isEmpty)
                        ? null
                        : _generate,
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
                        : const Text('Generate learning path'),
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
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.red.shade800,
                      ),
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

/// Simple flowchart: vertical list of topic nodes with arrows between.
class _FlowchartStrip extends StatelessWidget {
  const _FlowchartStrip({required this.topics});

  final List<String> topics;

  static const List<Color> _nodeColors = [
    Color(0xFF0EA5E9),
    Color(0xFF6366F1),
    Color(0xFF22C55E),
    Color(0xFFF97316),
    Color(0xFFEC4899),
    Color(0xFF8B5CF6),
  ];

  @override
  Widget build(BuildContext context) {
    if (topics.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Learning path',
            style: AppTypography.label.copyWith(
              color: AppColors.foregroundDim,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(topics.length * 2 - 1, (index) {
            if (index.isOdd) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_downward, size: 20, color: AppColors.foregroundDim),
                  ],
                ),
              );
            }
            final i = index ~/ 2;
            final topic = topics[i];
            final color = _nodeColors[i % _nodeColors.length];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        topic,
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.foreground,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _NodeCard extends StatelessWidget {
  const _NodeCard({
    required this.topic,
    required this.resources,
    required this.onOpenUrl,
  });

  final String topic;
  final List<dynamic> resources;
  final Future<void> Function(String url) onOpenUrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primaryWithOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.primaryWithOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.school_outlined,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    topic,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.foreground,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ...resources.map((r) {
            if (r is! Map<String, dynamic>) return const SizedBox.shrink();
            return _ResourceCard(
              title: r['title']?.toString() ?? '',
              url: r['url']?.toString() ?? '',
              platform: r['platform']?.toString() ?? '',
              duration: r['duration']?.toString(),
              isFree: r['is_free'] == true,
              instructor: r['instructor']?.toString(),
              thumbnail: r['thumbnail']?.toString(),
              onOpen: () => onOpenUrl(r['url']?.toString() ?? ''),
            );
          }),
        ],
      ),
    );
  }
}

class _ResourceCard extends StatelessWidget {
  const _ResourceCard({
    required this.title,
    required this.url,
    required this.platform,
    this.duration,
    required this.isFree,
    this.instructor,
    this.thumbnail,
    required this.onOpen,
  });

  final String title;
  final String url;
  final String platform;
  final String? duration;
  final bool isFree;
  final String? instructor;
  final String? thumbnail;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: url.isNotEmpty ? onOpen : null,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (thumbnail != null && thumbnail!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      thumbnail!,
                      width: 100,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox(
                        width: 100,
                        height: 56,
                        child: ColoredBox(
                          color: AppColors.surface,
                          child: Icon(Icons.video_library_outlined),
                        ),
                      ),
                    ),
                  ),
                if (thumbnail != null && thumbnail!.isNotEmpty)
                  const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.foreground,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.link,
                                size: 12,
                                color: AppColors.foregroundDim,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                platform.isNotEmpty ? platform : 'Resource',
                                style: AppTypography.bodySmall.copyWith(
                                  fontSize: 11,
                                  color: AppColors.foregroundDim,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          if (duration != null && duration!.isNotEmpty)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.schedule,
                                  size: 12,
                                  color: AppColors.foregroundDim,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  duration!,
                                  style: AppTypography.bodySmall.copyWith(
                                    fontSize: 11,
                                    color: AppColors.foregroundDim,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isFree
                                  ? Colors.green.shade50
                                  : Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isFree ? 'Free' : 'Paid',
                              style: AppTypography.bodySmall.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isFree
                                    ? Colors.green.shade700
                                    : Colors.amber.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (instructor != null && instructor!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          instructor!,
                          style: AppTypography.bodySmall.copyWith(
                            fontSize: 10,
                            color: AppColors.foregroundDim,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (url.isNotEmpty)
                  IconButton(
                    onPressed: onOpen,
                    icon: const Icon(Icons.open_in_new, size: 20),
                    tooltip: 'Open',
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primaryWithOpacity(0.15),
                      foregroundColor: AppColors.primary,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
