import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/dashboard_card.dart';
import '../../../core/widgets/feature_scaffold.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/services/api_service.dart';
import 'resume_data_transform.dart';
import 'resume_template_preview.dart';

class ResumeBuilderScreen extends StatefulWidget {
  const ResumeBuilderScreen({super.key});

  @override
  State<ResumeBuilderScreen> createState() => _ResumeBuilderScreenState();
}

class _ResumeBuilderScreenState extends State<ResumeBuilderScreen> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _aiResumeData;
  Map<String, dynamic>? _profile;
  Map<String, dynamic>? _user;

  /// Selected template id: modern, classic, creative, minimal, professional
  String? _selectedTemplate;
  /// After "Generate preview", show preview with this template
  ResumeTemplateData? _previewData;

  static const List<Map<String, String>> _templates = [
    {'id': 'modern', 'title': 'Modern', 'subtitle': 'Blue sidebar layout'},
    {'id': 'classic', 'title': 'Classic', 'subtitle': 'Serif, centered'},
    {'id': 'creative', 'title': 'Creative', 'subtitle': 'Warm amber accent'},
    {'id': 'minimal', 'title': 'Minimal', 'subtitle': 'Clean and simple'},
    {'id': 'professional', 'title': 'Professional', 'subtitle': 'Corporate style'},
  ];

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
      _previewData = null;
      _selectedTemplate = null;
    });
    try {
      Map<String, dynamic>? aiData;
      Map<String, dynamic>? profile;
      Map<String, dynamic>? user;
      try {
        final res = await ApiService.get(ApiEndpoints.resumeData);
        final body = res.data as Map<String, dynamic>?;
        final success = body?['success'] == true;
        if (success && body?['data'] != null) {
          aiData = body!['data'] as Map<String, dynamic>?;
        }
      } catch (_) {}
      try {
        final res = await ApiService.get(ApiEndpoints.profile);
        profile = res.data as Map<String, dynamic>?;
      } catch (_) {}
      try {
        final res = await ApiService.get(ApiEndpoints.me);
        user = res.data as Map<String, dynamic>?;
      } catch (_) {}
      if (!mounted) return;
      setState(() {
        _aiResumeData = aiData;
        _profile = profile;
        _user = user;
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

  @override
  void initState() {
    super.initState();
    _load();
  }

  bool get _hasAiData => _aiResumeData != null && _aiResumeData!.isNotEmpty;
  bool get _hasProfileResume => _profile?['has_resume'] == true;
  List<dynamic> get _profileSkills => _profile?['skills'] is List ? _profile!['skills'] as List<dynamic> : [];
  List<dynamic> get _profileExperiences => _profile?['experiences'] is List ? _profile!['experiences'] as List<dynamic> : [];
  List<dynamic> get _profileProjects => _profile?['projects'] is List ? _profile!['projects'] as List<dynamic> : [];
  List<dynamic> get _profileEducation => _profile?['education'] is List ? _profile!['education'] as List<dynamic> : [];

  bool get _hasPreviewData =>
      _hasAiData ||
      _hasProfileResume ||
      _profileSkills.isNotEmpty ||
      _profileExperiences.isNotEmpty ||
      _profileProjects.isNotEmpty ||
      _profileEducation.isNotEmpty;

  ResumeTemplateData? get _resumeTemplateData {
    if (_hasAiData) {
      return ResumeDataTransform.fromAiResumeData(_aiResumeData);
    }
    return ResumeDataTransform.fromProfileAndUser(_profile, _user);
  }

  void _generatePreview() {
    final data = _resumeTemplateData;
    if (data == null || _selectedTemplate == null) return;
    setState(() => _previewData = data);
  }

  void _changeTemplate() {
    setState(() {
      _previewData = null;
      _selectedTemplate = null;
    });
  }

  String get _selectedTemplateTitle {
    if (_selectedTemplate == null) return '';
    for (final t in _templates) {
      if (t['id'] == _selectedTemplate) return t['title'] ?? _selectedTemplate!;
    }
    return _selectedTemplate!;
  }

  @override
  Widget build(BuildContext context) {
    // Loading
    if (_loading) {
      return FeatureScaffold(
        title: 'Resume Builder',
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
      );
    }

    // Error
    if (_error != null) {
      return FeatureScaffold(
        title: 'Resume Builder',
        child: DashboardCard(
          title: 'Resume',
          titleIcon: Icons.description,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _errorBanner(_error!),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _load,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Retry'),
                  style: _primaryButtonStyle(),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Preview generated: show template preview + Change template
    if (_previewData != null && _selectedTemplate != null) {
      return FeatureScaffold(
        title: 'Resume Builder',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.foreground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Resume Preview — $_selectedTemplateTitle',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.background,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: _changeTemplate,
                    child: Text(
                      'Change Template',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.background),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.52,
                child: SingleChildScrollView(
                  child: ResumeTemplatePreview(
                    data: _previewData!,
                    templateId: _selectedTemplate!,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Export PDF and full editing are available on the web app.',
              style: AppTypography.bodySmall.copyWith(color: AppColors.foregroundDim),
            ),
          ],
        ),
      );
    }

    // No data at all
    if (!_hasPreviewData) {
      return FeatureScaffold(
        title: 'Resume Builder',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Build your CV',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.foregroundFaded),
            ),
            const SizedBox(height: 24),
            DashboardCard(
              title: 'Resume',
              titleIcon: Icons.description,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _noDataBanner('No resume data yet'),
                  const SizedBox(height: 16),
                  Text(
                    'Upload a resume in User Profile (Upload PDF / Extract skills) or generate an AI resume on the web app, then return here to pick a template.',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.foregroundFaded),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _load,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Refresh'),
                      style: _primaryButtonStyle(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Has data: show template selection + Generate preview (like portfolio)
    final templateData = _resumeTemplateData;
    return FeatureScaffold(
      title: 'Resume Builder',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Build your CV',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.foregroundFaded),
          ),
          if (_hasProfileResume || _profileSkills.isNotEmpty) ...[
            const SizedBox(height: 12),
            if (_hasProfileResume)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.primaryWithOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primaryWithOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Resume on file',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
              ),
          ],
          const SizedBox(height: 16),
          Text(
            'Choose a template',
            style: AppTypography.displaySmall.copyWith(
              color: AppColors.foreground,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          ..._templates.map((t) => _templateCard(
                id: t['id']!,
                title: t['title']!,
                subtitle: t['subtitle']!,
                selected: _selectedTemplate == t['id'],
                onTap: () => setState(() => _selectedTemplate = t['id']),
              )),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: (templateData == null || _selectedTemplate == null)
                  ? null
                  : _generatePreview,
              child: const Text('Generate preview'),
            ),
          ),
          if (_selectedTemplate == null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Center(
                child: Text(
                  'Select a template above to continue',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.foregroundDim),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _errorBanner(String message) => Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.primaryWithOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primaryWithOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, size: 20, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: AppTypography.bodySmall.copyWith(color: AppColors.foregroundMuted),
              ),
            ),
          ],
        ),
      );

  Widget _noDataBanner(String message) => Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.primaryWithOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primaryWithOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.folder_off_outlined, size: 20, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: AppTypography.bodySmall.copyWith(color: AppColors.foregroundMuted),
              ),
            ),
          ],
        ),
      );

  ButtonStyle _primaryButtonStyle() => FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      );

  Widget _templateCard({
    required String id,
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    Color borderColor = selected ? AppColors.primary : AppColors.cardBorder;
    IconData icon = Icons.description;
    if (id == 'modern') icon = Icons.dashboard;
    if (id == 'classic') icon = Icons.menu_book;
    if (id == 'creative') icon = Icons.palette;
    if (id == 'minimal') icon = Icons.filter_b_and_w;
    if (id == 'professional') icon = Icons.business_center;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: selected ? 2 : 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primaryWithOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.foreground,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: AppTypography.bodySmall.copyWith(color: AppColors.foregroundDim),
                      ),
                    ],
                  ),
                ),
                if (selected) Icon(Icons.check_circle, color: AppColors.primary, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
