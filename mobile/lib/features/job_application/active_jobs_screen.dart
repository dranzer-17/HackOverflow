import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/feature_scaffold.dart';
import '../../../core/widgets/dashboard_card.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/services/api_service.dart';

class ActiveJobsScreen extends StatefulWidget {
  const ActiveJobsScreen({super.key});

  @override
  State<ActiveJobsScreen> createState() => _ActiveJobsScreenState();
}

class _ActiveJobsScreenState extends State<ActiveJobsScreen> {
  bool _loading = true;
  String? _error;
  List<dynamic> _savedJobs = [];
  List<dynamic> _relevantJobs = [];
  Set<String> _savedJobIds = {};
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() { _loading = true; _error = null; });
    try {
      final savedRes = await ApiService.get(ApiEndpoints.jobsSaved);
      final relevantRes = await ApiService.get(ApiEndpoints.jobsRelevant(50));

      if (!mounted) return;
      final savedData = savedRes.data;
      final relevantData = relevantRes.data;

      final savedList = _extractList(savedData, 'jobs');
      final relevantList = _extractList(relevantData, 'jobs');

      final savedIds = <String>{};
      for (final j in savedList) {
        if (j is Map && j['job_id'] != null) savedIds.add(j['job_id'].toString());
      }

      setState(() {
        _savedJobs = savedList;
        _relevantJobs = relevantList;
        _savedJobIds = savedIds;
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

  List<dynamic> _extractList(dynamic data, String key) {
    if (data is! Map) return [];
    final v = data[key];
    if (v is List) return v;
    return [];
  }

  Map<String, dynamic>? _jobFromItem(dynamic item) {
    if (item is Map) {
      if (item['job'] is Map) return Map<String, dynamic>.from(item['job'] as Map);
      return Map<String, dynamic>.from(item);
    }
    return null;
  }

  double _matchScore(dynamic item) {
    if (item is Map && item['match_score'] != null) {
      final n = item['match_score'];
      if (n is num) return n.toDouble();
    }
    return 0;
  }

  List<String> _matchedSkills(dynamic item) {
    if (item is Map && item['matched_skills'] is List) {
      return (item['matched_skills'] as List).map((e) => e.toString()).toList();
    }
    return [];
  }

  List<String> _missingSkills(dynamic item) {
    if (item is Map && item['missing_skills'] is List) {
      return (item['missing_skills'] as List).map((e) => e.toString()).toList();
    }
    return [];
  }

  Future<void> _saveJob(String jobId, String status) async {
    try {
      await ApiService.post(ApiEndpoints.jobsSave, data: {'job_id': jobId, 'status': status});
      if (!mounted) return;
      setState(() => _savedJobIds = Set.from(_savedJobIds)..add(jobId));
    } catch (_) {}
  }

  Future<void> _openUrl(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _refreshJobs() async {
    setState(() => _refreshing = true);
    try {
      await ApiService.dio.post(ApiEndpoints.jobsTriggerScrape);
      await _load();
    } catch (_) {
      await _load();
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FeatureScaffold(
      title: 'Active Jobs',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_error != null) ...[
            _ErrorBanner(message: _error!),
            TextButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
            const SizedBox(height: 16),
          ],
          if (_loading && _relevantJobs.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_relevantJobs.length} jobs matched to your skills',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.foregroundDim),
                ),
                TextButton.icon(
                  onPressed: _refreshing ? null : _refreshJobs,
                  icon: _refreshing
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.refresh, size: 18),
                  label: Text(_refreshing ? 'Refreshing...' : 'Refresh jobs'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_relevantJobs.isEmpty)
              DashboardCard(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.work_off, size: 48, color: AppColors.foregroundDim),
                        const SizedBox(height: 12),
                        Text(
                          'No jobs found',
                          style: AppTypography.bodyMedium.copyWith(color: AppColors.foreground),
                        ),
                        Text(
                          'Try refreshing or add more skills to your profile.',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.foregroundDim),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              ..._relevantJobs.map((item) {
                final job = _jobFromItem(item);
                if (job == null) return const SizedBox.shrink();
                final jobId = job['job_id']?.toString() ?? '';
                final title = job['title']?.toString() ?? 'Job';
                final company = job['company']?.toString() ?? '';
                final location = job['location']?.toString() ?? '';
                final description = job['description']?.toString() ?? '';
                final url = job['url']?.toString();
                final source = job['source']?.toString() ?? '';
                final jobType = job['job_type']?.toString();
                final salary = job['salary']?.toString();
                final matchScore = _matchScore(item);
                final matchedSkills = _matchedSkills(item);
                final missingSkills = _missingSkills(item);
                final isSaved = _savedJobIds.contains(jobId);

                return _JobCard(
                  jobId: jobId,
                  title: title,
                  company: company,
                  location: location,
                  description: description,
                  url: url,
                  source: source,
                  jobType: jobType,
                  salary: salary,
                  matchScore: matchScore,
                  matchedSkills: matchedSkills,
                  missingSkills: missingSkills,
                  isSaved: isSaved,
                  onSave: () => _saveJob(jobId, 'saved'),
                  onMarkApplied: () => _saveJob(jobId, 'applied'),
                  onViewJob: () => _openUrl(url),
                  onApply: () => context.push(
                    '/cover-letter?job_id=$jobId&title=${Uri.encodeComponent(title)}&company=${Uri.encodeComponent(company)}',
                  ),
                );
              }),
          ],
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Expanded(child: Text(message, style: AppTypography.bodySmall.copyWith(color: Colors.red.shade800))),
        ],
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  const _JobCard({
    required this.jobId,
    required this.title,
    required this.company,
    required this.location,
    required this.description,
    this.url,
    required this.source,
    this.jobType,
    this.salary,
    required this.matchScore,
    required this.matchedSkills,
    required this.missingSkills,
    required this.isSaved,
    required this.onSave,
    required this.onMarkApplied,
    required this.onViewJob,
    required this.onApply,
  });

  final String jobId;
  final String title;
  final String company;
  final String location;
  final String description;
  final String? url;
  final String source;
  final String? jobType;
  final String? salary;
  final double matchScore;
  final List<String> matchedSkills;
  final List<String> missingSkills;
  final bool isSaved;
  final VoidCallback onSave;
  final VoidCallback onMarkApplied;
  final VoidCallback onViewJob;
  final VoidCallback onApply;

  Color _matchColor(double score) {
    if (score >= 80) return Colors.green.shade700;
    if (score >= 60) return Colors.blue.shade700;
    if (score >= 40) return Colors.orange.shade700;
    return AppColors.foregroundDim;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DashboardCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: AppTypography.label.copyWith(
                                color: AppColors.foreground,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryWithOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              source,
                              style: AppTypography.label.copyWith(fontSize: 10, color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        runSpacing: 6,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.business, size: 14, color: AppColors.foregroundDim),
                              const SizedBox(width: 4),
                              Text(company, style: AppTypography.bodySmall.copyWith(color: AppColors.foreground)),
                            ],
                          ),
                          if (location.isNotEmpty)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.location_on, size: 14, color: AppColors.foregroundDim),
                                const SizedBox(width: 4),
                                Text(location, style: AppTypography.bodySmall.copyWith(color: AppColors.foregroundDim)),
                              ],
                            ),
                          if (jobType != null && jobType!.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.purple.shade50,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(jobType!, style: AppTypography.label.copyWith(fontSize: 10, color: Colors.purple.shade700)),
                            ),
                          if (salary != null && salary!.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(salary!, style: AppTypography.label.copyWith(fontSize: 10, color: Colors.green.shade700)),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: _matchColor(matchScore).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _matchColor(matchScore).withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${matchScore.round()}',
                        style: AppTypography.label.copyWith(
                          fontSize: 18,
                          color: _matchColor(matchScore),
                        ),
                      ),
                      Text('Match', style: AppTypography.label.copyWith(fontSize: 9, color: AppColors.foregroundDim)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description.length > 200 ? '${description.substring(0, 200)}...' : description,
              style: AppTypography.bodySmall.copyWith(color: AppColors.foregroundDim),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (matchedSkills.isNotEmpty || missingSkills.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  ...matchedSkills.take(5).map((s) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('✓ $s', style: AppTypography.label.copyWith(fontSize: 10, color: Colors.blue.shade700)),
                      )),
                  ...missingSkills.take(3).map((s) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(s, style: AppTypography.label.copyWith(fontSize: 10, color: AppColors.foregroundDim)),
                      )),
                ],
              ),
            ],
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: onApply,
                  icon: const Icon(Icons.description, size: 16),
                  label: const Text('Apply'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: onViewJob,
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: const Text('View job'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                TextButton.icon(
                  onPressed: isSaved ? null : onSave,
                  icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border, size: 16),
                  label: Text(isSaved ? 'Saved' : 'Save'),
                ),
                TextButton.icon(
                  onPressed: onMarkApplied,
                  icon: const Icon(Icons.check_circle_outline, size: 16),
                  label: const Text('Mark applied'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
