import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/feature_scaffold.dart';
import '../../../core/widgets/dashboard_card.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/services/api_service.dart';
import 'portfolio_template_preview.dart';

class PortfolioBuilderScreen extends StatefulWidget {
  const PortfolioBuilderScreen({super.key});

  @override
  State<PortfolioBuilderScreen> createState() => _PortfolioBuilderScreenState();
}

class _PortfolioBuilderScreenState extends State<PortfolioBuilderScreen> {
  String? _error;
  Map<String, dynamic>? _portfolioData;
  String? _selectedDesign; // 'terminal' | 'minimal' | 'professional'
  bool _generating = false;
  bool _deploying = false;
  String? _deployError;
  String? _deployedUrl;

  static const List<Map<String, String>> _designs = [
    {'id': 'terminal', 'title': 'Hacker Terminal', 'subtitle': 'Dark terminal with green text'},
    {'id': 'minimal', 'title': 'Minimal', 'subtitle': 'Clean white space design'},
    {'id': 'professional', 'title': 'Professional', 'subtitle': 'Corporate structured layout'},
  ];

  Future<void> _generatePortfolio() async {
    if (_selectedDesign == null) {
      setState(() => _error = 'Please select a design first');
      return;
    }
    if (!mounted) return;
    setState(() {
      _generating = true;
      _error = null;
    });
    try {
      final res = await ApiService.get(ApiEndpoints.portfolioData);
      if (!mounted) return;
      final data = res.data as Map<String, dynamic>?;
      final skills = data?['skills'] as List<dynamic>? ?? [];
      final experiences = data?['experiences'] as List<dynamic>? ?? [];
      final projects = data?['projects'] as List<dynamic>? ?? [];
      final education = data?['education'] as List<dynamic>? ?? [];

      final hasData = skills.isNotEmpty ||
          experiences.isNotEmpty ||
          projects.isNotEmpty ||
          education.isNotEmpty;

      if (!hasData) {
        setState(() {
          _generating = false;
          _error =
              'Please add your skills, experiences, projects, or education in User Profile before generating portfolio.';
        });
        return;
      }

      setState(() {
        _portfolioData = data;
        _generating = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _generating = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _changeDesign() {
    setState(() {
      _portfolioData = null;
      _selectedDesign = null;
      _error = null;
      _deployedUrl = null;
      _deployError = null;
    });
  }

  Future<void> _deploy() async {
    if (_selectedDesign == null) return;
    if (!mounted) return;
    setState(() {
      _deploying = true;
      _deployError = null;
    });
    try {
      final res = await ApiService.post(
        ApiEndpoints.portfolioDeploy,
        data: {'design_type': _selectedDesign!},
      );
      if (!mounted) return;
      final map = res.data is Map ? res.data as Map<String, dynamic> : null;
      final url = map?['portfolio_url'] as String?;
      setState(() {
        _deploying = false;
        _deployError = url == null ? 'No URL returned' : null;
        _deployedUrl = url;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _deploying = false;
        _deployError = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _copyUrl() {
    final url = _deployedUrl;
    if (url == null) return;
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Portfolio URL copied to clipboard')),
    );
  }

  Future<void> _openUrl() async {
    if (_deployedUrl == null) return;
    final uri = Uri.tryParse(_deployedUrl!);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String get _selectedDesignTitle {
    if (_selectedDesign == null) return '';
    for (final d in _designs) {
      if (d['id'] == _selectedDesign) return d['title'] ?? _selectedDesign!;
    }
    return _selectedDesign!;
  }

  @override
  Widget build(BuildContext context) {
    // Design selection + Generate (when no portfolio generated)
    if (_portfolioData == null) {
      return FeatureScaffold(
        title: 'Portfolio Builder',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Generate and deploy your portfolio from your profile data.',
                style: AppTypography.bodySmall.copyWith(color: AppColors.foregroundDim),
              ),
            ),
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
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
            Text(
              'Choose Your Portfolio Design',
              style: AppTypography.displaySmall.copyWith(
                color: AppColors.foreground,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),
            ..._designs.map((d) => _designCard(
                  id: d['id']!,
                  title: d['title']!,
                  subtitle: d['subtitle']!,
                  selected: _selectedDesign == d['id'],
                  onTap: () => setState(() {
                    _selectedDesign = d['id'];
                    _error = null;
                  }),
                )),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: (_generating || _selectedDesign == null) ? null : _generatePortfolio,
                child: _generating
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Generate Portfolio'),
              ),
            ),
            if (_selectedDesign == null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Center(
                  child: Text(
                    'Please select a design above to continue',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.foregroundDim),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    // Preview + Deploy (portfolio generated)
    return FeatureScaffold(
      title: 'Portfolio Builder',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Preview header bar (like website)
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
                    'Portfolio Preview — $_selectedDesignTitle',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.background,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton(
                  onPressed: _changeDesign,
                  child: Text('Change Design', style: AppTypography.bodySmall.copyWith(color: AppColors.background)),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _deploying ? null : _deploy,
                  icon: _deploying
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.rocket_launch, size: 18),
                  label: Text(_deploying ? 'Deploying...' : 'Deploy'),
                  style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Preview content (scrollable template)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.55,
              child: PortfolioTemplatePreview(
                data: _portfolioData!,
                designType: _selectedDesign ?? 'terminal',
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Deployed URL section (like website success toast)
          if (_deployError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                _deployError!,
                style: AppTypography.bodySmall.copyWith(color: Colors.red.shade700),
              ),
            ),
          if (_deployedUrl != null)
            DashboardCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green.shade600, size: 24),
                      const SizedBox(width: 10),
                      Text(
                        'Portfolio deployed successfully',
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Share the link below or open it in a browser.',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.foregroundDim),
                  ),
                  const SizedBox(height: 12),
                  SelectableText(
                    _deployedUrl!,
                    style: AppTypography.bodySmall.copyWith(color: AppColors.primary),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      FilledButton.icon(
                        onPressed: _copyUrl,
                        icon: const Icon(Icons.copy, size: 18),
                        label: const Text('Copy'),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: _openUrl,
                        icon: const Icon(Icons.open_in_new, size: 18),
                        label: const Text('Open'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _designCard({
    required String id,
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    Color borderColor = selected ? AppColors.primary : AppColors.cardBorder;
    if (id == 'terminal') borderColor = selected ? const Color(0xFF22C55E) : const Color(0xFF22C55E).withValues(alpha: 0.5);
    if (id == 'minimal') borderColor = selected ? const Color(0xFF60A5FA) : const Color(0xFF60A5FA).withValues(alpha: 0.5);
    if (id == 'professional') borderColor = selected ? const Color(0xFFA78BFA) : const Color(0xFFA78BFA).withValues(alpha: 0.5);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: selected ? 2 : 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: id == 'terminal'
                        ? const Color(0xFF000000)
                        : id == 'minimal'
                            ? const Color(0xFF1E1B4B)
                            : const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    id == 'terminal' ? Icons.terminal : id == 'minimal' ? Icons.palette_outlined : Icons.business_center_outlined,
                    color: id == 'terminal' ? const Color(0xFF22C55E) : id == 'minimal' ? const Color(0xFFA78BFA) : const Color(0xFFB45309),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title.toUpperCase(),
                        style: AppTypography.tag.copyWith(fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppTypography.bodySmall.copyWith(color: AppColors.foregroundDim),
                      ),
                    ],
                  ),
                ),
                if (selected) Icon(Icons.check_circle, color: borderColor, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
