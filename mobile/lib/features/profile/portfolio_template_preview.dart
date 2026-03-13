import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Renders portfolio preview matching website templates: terminal, minimal, professional.
class PortfolioTemplatePreview extends StatelessWidget {
  const PortfolioTemplatePreview({
    super.key,
    required this.data,
    required this.designType,
  });

  final Map<String, dynamic> data;
  final String designType;

  static const Color _terminalGreen = Color(0xFF22C55E);
  static const Color _terminalBg = Color(0xFF000000);
  static const Color _terminalCard = Color(0x8032322A); // zinc-900/50
  static const Color _terminalBorder = Color(0xFF3F3F46); // zinc-800
  static const Color _minimalPurple = Color(0xFFA78BFA);
  static const Color _professionalAmber = Color(0xFFB45309);

  @override
  Widget build(BuildContext context) {
    switch (designType) {
      case 'minimal':
        return _MinimalPreview(data: data);
      case 'professional':
        return _ProfessionalPreview(data: data);
      default:
        return _TerminalPreview(data: data);
    }
  }
}

// --- Helpers used by all templates ---

String _str(dynamic v) => v?.toString() ?? '';
String _name(Map<String, dynamic> d) => _str(d['name']).isEmpty ? 'User' : _str(d['name']);
String _bio(Map<String, dynamic> d) => _str(d['bio']);
String _location(Map<String, dynamic> d) => _str(d['location']);
String _email(Map<String, dynamic> d) => _str(d['email']);
List<dynamic> _links(Map<String, dynamic> d) => d['links'] is List ? d['links'] as List<dynamic> : [];
List<dynamic> _skills(Map<String, dynamic> d) => d['skills'] is List ? d['skills'] as List<dynamic> : [];
List<dynamic> _experiences(Map<String, dynamic> d) => d['experiences'] is List ? d['experiences'] as List<dynamic> : [];
List<dynamic> _projects(Map<String, dynamic> d) => d['projects'] is List ? d['projects'] as List<dynamic> : [];
List<dynamic> _education(Map<String, dynamic> d) => d['education'] is List ? d['education'] as List<dynamic> : [];

String _linkValue(dynamic e) {
  if (e is! Map<String, dynamic>) return '';
  return _str(e['value']).isEmpty ? _str(e['url']) : _str(e['value']);
}

List<String> _projectTechs(dynamic e) {
  if (e is! Map<String, dynamic>) return [];
  final t = e['technologies'];
  if (t is String) return t.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  if (t is List) return t.map((s) => s.toString().trim()).where((s) => s.isNotEmpty).toList();
  return [];
}

// --- Terminal (Hacker) design ---

class _TerminalPreview extends StatelessWidget {
  const _TerminalPreview({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final name = _name(data);
    final bio = _bio(data);
    final location = _location(data);
    final email = _email(data);
    final links = _links(data);
    final skills = _skills(data);
    final experiences = _experiences(data);
    final projects = _projects(data);
    final education = _education(data);

    return Container(
      color: PortfolioTemplatePreview._terminalBg,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          // Hero / whoami block
          _terminalBlock(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _dot(const Color(0xFFEF4444)),
                    const SizedBox(width: 6),
                    _dot(const Color(0xFFEAB308)),
                    const SizedBox(width: 6),
                    _dot(PortfolioTemplatePreview._terminalGreen),
                    const SizedBox(width: 12),
                    Text('~/portfolio', style: GoogleFonts.jetBrainsMono(fontSize: 12, color: const Color(0xFF71717A))),
                  ],
                ),
                const SizedBox(height: 12),
                Text('\$ whoami', style: GoogleFonts.jetBrainsMono(fontSize: 12, color: const Color(0xFF71717A))),
                const SizedBox(height: 6),
                Text('> $name', style: GoogleFonts.jetBrainsMono(fontSize: 12, color: Colors.white)),
                if (bio.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text('\$ cat bio.txt', style: GoogleFonts.jetBrainsMono(fontSize: 12, color: const Color(0xFF71717A))),
                  const SizedBox(height: 6),
                  Text('> $bio', style: GoogleFonts.jetBrainsMono(fontSize: 12, color: const Color(0xFFD4D4D8))),
                ],
                if (location.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text('\$ locate', style: GoogleFonts.jetBrainsMono(fontSize: 12, color: const Color(0xFF71717A))),
                  const SizedBox(height: 6),
                  Text('> $location', style: GoogleFonts.jetBrainsMono(fontSize: 12, color: const Color(0xFFD4D4D8))),
                ],
                const SizedBox(height: 8),
                const _Cursor(),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Name
          Text(
            name,
            style: GoogleFonts.syne(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white),
          ),
          const SizedBox(height: 16),
          // Email + links
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (email.isNotEmpty)
                _terminalChip(icon: Icons.email, label: email),
              for (final e in links)
                if (e is Map<String, dynamic> && _linkValue(e).isNotEmpty)
                  _terminalChip(
                    icon: Icons.link,
                    label: (_str(e['type']).isEmpty ? 'Link' : _str(e['type'])),
                  ),
            ],
          ),
          _sectionHead('About'),
          _terminalCard(
            child: Text(
              bio.isEmpty ? 'Add a bio in your profile.' : bio,
              style: GoogleFonts.jetBrainsMono(fontSize: 13, color: const Color(0xFFD4D4D8), height: 1.5),
            ),
          ),
          if (skills.isNotEmpty) ...[
            _sectionHead('Skills'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final s in skills)
                  if (s is Map<String, dynamic>)
                    _terminalSkillChip(_str(s['name'])),
              ],
            ),
          ],
          if (experiences.isNotEmpty) ...[
            _sectionHead('Experience'),
            ...experiences.whereType<Map<String, dynamic>>().map((e) => _terminalExpCard(e)),
          ],
          if (projects.isNotEmpty) ...[
            _sectionHead('Projects'),
            ...projects.whereType<Map<String, dynamic>>().map((e) => _terminalProjectCard(e)),
          ],
          if (education.isNotEmpty) ...[
            _sectionHead('Education'),
            ...education.whereType<Map<String, dynamic>>().map((e) => _terminalEduCard(e)),
          ],
          _sectionHead('Contact'),
          _terminalCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Let's collaborate. Open to new opportunities.",
                  style: GoogleFonts.jetBrainsMono(fontSize: 13, color: const Color(0xFFD4D4D8)),
                ),
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text('mailto:$email', style: GoogleFonts.jetBrainsMono(fontSize: 12, color: PortfolioTemplatePreview._terminalGreen)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              '© ${DateTime.now().year} $name',
              style: GoogleFonts.jetBrainsMono(fontSize: 11, color: const Color(0xFF71717A)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(Color c) => Container(width: 12, height: 12, decoration: BoxDecoration(color: c, shape: BoxShape.circle));
  Widget _sectionHead(String title) => Padding(
        padding: const EdgeInsets.only(top: 28, bottom: 12),
        child: Row(
          children: [
            Text('<', style: GoogleFonts.jetBrainsMono(fontSize: 18, fontWeight: FontWeight.w700, color: PortfolioTemplatePreview._terminalGreen)),
            Text(title, style: GoogleFonts.jetBrainsMono(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
            Text('/>', style: GoogleFonts.jetBrainsMono(fontSize: 18, fontWeight: FontWeight.w700, color: PortfolioTemplatePreview._terminalGreen)),
          ],
        ),
      );
  Widget _terminalBlock({required Widget child}) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: PortfolioTemplatePreview._terminalCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: PortfolioTemplatePreview._terminalBorder),
        ),
        child: child,
      );
  Widget _terminalCard({required Widget child}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: PortfolioTemplatePreview._terminalCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: PortfolioTemplatePreview._terminalBorder),
        ),
        child: child,
      );
  Widget _terminalChip({required IconData icon, required String label}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: PortfolioTemplatePreview._terminalCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: PortfolioTemplatePreview._terminalBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: const Color(0xFF71717A)),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.jetBrainsMono(fontSize: 12, color: const Color(0xFFD4D4D8))),
          ],
        ),
      );
  Widget _terminalSkillChip(String name) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: PortfolioTemplatePreview._terminalCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: PortfolioTemplatePreview._terminalBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.code, size: 16, color: PortfolioTemplatePreview._terminalGreen),
            const SizedBox(width: 8),
            Text(name, style: GoogleFonts.jetBrainsMono(fontSize: 12, color: Colors.white)),
          ],
        ),
      );
  Widget _terminalExpCard(Map<String, dynamic> e) {
    final title = _str(e['title']);
    final company = _str(e['company']);
    final start = _str(e['startDate']);
    final end = e['currentlyWorking'] == true ? 'Present' : _str(e['endDate']);
    final desc = _str(e['description']);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _terminalCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.work_outline, size: 18, color: PortfolioTemplatePreview._terminalGreen),
                const SizedBox(width: 8),
                Text(title, style: GoogleFonts.jetBrainsMono(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
              ],
            ),
            const SizedBox(height: 4),
            Text(company, style: GoogleFonts.jetBrainsMono(fontSize: 12, color: PortfolioTemplatePreview._terminalGreen)),
            Text('$start → $end', style: GoogleFonts.jetBrainsMono(fontSize: 11, color: const Color(0xFF71717A))),
            if (desc.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(desc, style: GoogleFonts.jetBrainsMono(fontSize: 12, color: const Color(0xFFD4D4D8), height: 1.4)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _terminalProjectCard(Map<String, dynamic> e) {
    final name = _str(e['name']);
    final desc = _str(e['description']);
    final techs = _projectTechs(e);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _terminalCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: GoogleFonts.jetBrainsMono(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
            if (desc.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(desc, style: GoogleFonts.jetBrainsMono(fontSize: 12, color: const Color(0xFFD4D4D8), height: 1.4)),
            ],
            if (techs.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  for (final t in techs)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: PortfolioTemplatePreview._terminalGreen.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: PortfolioTemplatePreview._terminalGreen.withValues(alpha: 0.3)),
                      ),
                      child: Text(t, style: GoogleFonts.jetBrainsMono(fontSize: 10, color: PortfolioTemplatePreview._terminalGreen)),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _terminalEduCard(Map<String, dynamic> e) {
    final degree = _str(e['degree']);
    final institution = _str(e['institution']);
    final year = _str(e['year']);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _terminalCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.school_outlined, size: 20, color: PortfolioTemplatePreview._terminalGreen),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(degree, style: GoogleFonts.jetBrainsMono(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                  Text(institution, style: GoogleFonts.jetBrainsMono(fontSize: 12, color: PortfolioTemplatePreview._terminalGreen)),
                  Text(year, style: GoogleFonts.jetBrainsMono(fontSize: 11, color: const Color(0xFF71717A))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Cursor extends StatefulWidget {
  const _Cursor();

  @override
  State<_Cursor> createState() => _CursorState();
}

class _CursorState extends State<_Cursor> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 530))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 8,
        height: 16,
        margin: const EdgeInsets.only(left: 2),
        decoration: BoxDecoration(
          color: PortfolioTemplatePreview._terminalGreen,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}

// --- Minimal design (purple gradient) ---

class _MinimalPreview extends StatelessWidget {
  const _MinimalPreview({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final name = _name(data);
    final bio = _bio(data);
    final location = _location(data);
    final email = _email(data);
    final links = _links(data);
    final skills = _skills(data);
    final experiences = _experiences(data);
    final projects = _projects(data);
    final education = _education(data);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F172A), Color(0xFF1E1B4B), Color(0xFF0F172A)],
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
        children: [
          Text(
            name,
            style: GoogleFonts.syne(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          if (bio.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              bio,
              style: GoogleFonts.jetBrainsMono(fontSize: 14, color: const Color(0xFFD1D5DB), height: 1.5),
            ),
          ],
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (location.isNotEmpty) _minimalPill(Icons.location_on, location),
              if (email.isNotEmpty) _minimalPill(Icons.email, email),
              for (final e in links)
                if (e is Map<String, dynamic> && _linkValue(e).isNotEmpty)
                  _minimalPill(Icons.link, _str(e['type']).isEmpty ? 'Link' : _str(e['type'])),
            ],
          ),
          _minimalSectionTitle('About'),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: PortfolioTemplatePreview._minimalPurple.withValues(alpha: 0.2)),
            ),
            child: Text(
              bio.isEmpty ? 'Add a bio in your profile.' : bio,
              style: GoogleFonts.jetBrainsMono(fontSize: 13, color: const Color(0xFFE5E7EB), height: 1.5),
            ),
          ),
          if (skills.isNotEmpty) ...[
            _minimalSectionTitle('Skills'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final s in skills)
                  if (s is Map<String, dynamic>)
                    _minimalChip(_str(s['name'])),
              ],
            ),
          ],
          if (experiences.isNotEmpty) ...[
            _minimalSectionTitle('Experience'),
            ...experiences.whereType<Map<String, dynamic>>().map((e) => _minimalExpCard(e)),
          ],
          if (projects.isNotEmpty) ...[
            _minimalSectionTitle('Projects'),
            ...projects.whereType<Map<String, dynamic>>().map((e) => _minimalProjectCard(e)),
          ],
          if (education.isNotEmpty) ...[
            _minimalSectionTitle('Education'),
            ...education.whereType<Map<String, dynamic>>().map((e) => _minimalEduCard(e)),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _minimalPill(IconData icon, String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: PortfolioTemplatePreview._minimalPurple),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.jetBrainsMono(fontSize: 12, color: const Color(0xFFD1D5DB))),
          ],
        ),
      );
  Widget _minimalSectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(top: 28, bottom: 12),
        child: Text(
          title,
          style: GoogleFonts.jetBrainsMono(fontSize: 18, fontWeight: FontWeight.w700, color: PortfolioTemplatePreview._minimalPurple),
        ),
      );
  Widget _minimalChip(String name) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: PortfolioTemplatePreview._minimalPurple.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: PortfolioTemplatePreview._minimalPurple.withValues(alpha: 0.3)),
        ),
        child: Text(name, style: GoogleFonts.jetBrainsMono(fontSize: 12, color: Colors.white)),
      );
  Widget _minimalExpCard(Map<String, dynamic> e) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: PortfolioTemplatePreview._minimalPurple.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_str(e['title']), style: GoogleFonts.jetBrainsMono(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
              Text(_str(e['company']), style: GoogleFonts.jetBrainsMono(fontSize: 12, color: PortfolioTemplatePreview._minimalPurple)),
              if (_str(e['description']).isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(_str(e['description']), style: GoogleFonts.jetBrainsMono(fontSize: 12, color: const Color(0xFFD1D5DB), height: 1.4)),
                ),
            ],
          ),
        ),
      );
  Widget _minimalProjectCard(Map<String, dynamic> e) {
    final techs = _projectTechs(e);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: PortfolioTemplatePreview._minimalPurple.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_str(e['name']), style: GoogleFonts.jetBrainsMono(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
            if (_str(e['description']).isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(_str(e['description']), style: GoogleFonts.jetBrainsMono(fontSize: 12, color: const Color(0xFFD1D5DB), height: 1.4)),
              ),
            if (techs.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [for (final t in techs) _minimalChip(t)],
                ),
              ),
          ],
        ),
      ),
    );
  }
  Widget _minimalEduCard(Map<String, dynamic> e) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: PortfolioTemplatePreview._minimalPurple.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_str(e['degree']), style: GoogleFonts.jetBrainsMono(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
              Text(_str(e['institution']), style: GoogleFonts.jetBrainsMono(fontSize: 12, color: PortfolioTemplatePreview._minimalPurple)),
              Text(_str(e['year']), style: GoogleFonts.jetBrainsMono(fontSize: 11, color: const Color(0xFF9CA3AF))),
            ],
          ),
        ),
      );
}

// --- Professional design (amber / corporate) ---

class _ProfessionalPreview extends StatelessWidget {
  const _ProfessionalPreview({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final name = _name(data);
    final bio = _bio(data);
    final email = _email(data);
    final location = _location(data);
    final skills = _skills(data);
    final experiences = _experiences(data);
    final projects = _projects(data);
    final education = _education(data);

    const amberBg = Color(0xFFFEF3C7);
    const amberSidebar = Color(0xFF451A03);
    const amberBorder = Color(0xFF92400E);

    return LayoutBuilder(
      builder: (context, constraints) {
        final useSidebar = constraints.maxWidth >= 320;
        return Container(
          color: amberBg,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sidebar (hide on very narrow)
              if (useSidebar)
                Container(
                  width: 240,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: amberSidebar,
              border: Border(right: BorderSide(color: amberBorder, width: 4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: const Color(0xFFB45309),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'U',
                    style: GoogleFonts.syne(fontSize: 36, fontWeight: FontWeight.w800, color: const Color(0xFFFEF3C7)),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  name,
                  style: GoogleFonts.syne(fontSize: 20, fontWeight: FontWeight.w700, color: const Color(0xFFFEF3C7)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  bio.isEmpty ? 'Add a bio in your profile.' : bio,
                  style: GoogleFonts.jetBrainsMono(fontSize: 11, color: const Color(0xFFFDE68A), height: 1.4),
                  textAlign: TextAlign.center,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.email, size: 16, color: Color(0xFFFDE68A)),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(email, style: GoogleFonts.jetBrainsMono(fontSize: 11, color: const Color(0xFFFDE68A)), overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ],
                if (location.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Color(0xFFFDE68A)),
                      const SizedBox(width: 8),
                      Text(location, style: GoogleFonts.jetBrainsMono(fontSize: 11, color: const Color(0xFFFDE68A))),
                    ],
                  ),
                ],
              ],
            ),
          ),
              // Main content
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    if (!useSidebar) ...[
                      Center(
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: const Color(0xFFB45309),
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : 'U',
                            style: GoogleFonts.syne(fontSize: 28, fontWeight: FontWeight.w800, color: const Color(0xFFFEF3C7)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          name,
                          style: GoogleFonts.syne(fontSize: 18, fontWeight: FontWeight.w700, color: PortfolioTemplatePreview._professionalAmber),
                        ),
                      ),
                      if (bio.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(bio, style: GoogleFonts.jetBrainsMono(fontSize: 11, color: const Color(0xFF57534E), height: 1.4)),
                        ),
                    ],
                    _proSectionTitle('Experience'),
                    ...experiences.whereType<Map<String, dynamic>>().map((e) => _proExpCard(e)),
                    _proSectionTitle('Projects'),
                    ...projects.whereType<Map<String, dynamic>>().map((e) => _proProjectCard(e)),
                    _proSectionTitle('Education'),
                    ...education.whereType<Map<String, dynamic>>().map((e) => _proEduCard(e)),
                    if (skills.isNotEmpty) ...[
                      _proSectionTitle('Skills'),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final s in skills)
                            if (s is Map<String, dynamic>)
                              _proSkillChip(_str(s['name'])),
                        ],
                      ),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _proSectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 12),
        child: Text(
          title,
          style: GoogleFonts.syne(fontSize: 18, fontWeight: FontWeight.w700, color: PortfolioTemplatePreview._professionalAmber),
        ),
      );
  Widget _proExpCard(Map<String, dynamic> e) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: PortfolioTemplatePreview._professionalAmber.withValues(alpha: 0.3)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_str(e['title']), style: GoogleFonts.syne(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF1C1917))),
              Text(_str(e['company']), style: GoogleFonts.jetBrainsMono(fontSize: 12, color: PortfolioTemplatePreview._professionalAmber)),
              if (_str(e['description']).isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(_str(e['description']), style: GoogleFonts.jetBrainsMono(fontSize: 12, color: const Color(0xFF57534E), height: 1.4)),
                ),
            ],
          ),
        ),
      );
  Widget _proProjectCard(Map<String, dynamic> e) {
    final techs = _projectTechs(e);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: PortfolioTemplatePreview._professionalAmber.withValues(alpha: 0.3)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_str(e['name']), style: GoogleFonts.syne(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF1C1917))),
            if (_str(e['description']).isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(_str(e['description']), style: GoogleFonts.jetBrainsMono(fontSize: 12, color: const Color(0xFF57534E), height: 1.4)),
              ),
            if (techs.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    for (final t in techs)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: PortfolioTemplatePreview._professionalAmber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(t, style: GoogleFonts.jetBrainsMono(fontSize: 10, color: PortfolioTemplatePreview._professionalAmber)),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
  Widget _proEduCard(Map<String, dynamic> e) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: PortfolioTemplatePreview._professionalAmber.withValues(alpha: 0.3)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_str(e['degree']), style: GoogleFonts.syne(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF1C1917))),
              Text(_str(e['institution']), style: GoogleFonts.jetBrainsMono(fontSize: 12, color: PortfolioTemplatePreview._professionalAmber)),
              Text(_str(e['year']), style: GoogleFonts.jetBrainsMono(fontSize: 11, color: const Color(0xFF78716C))),
            ],
          ),
        ),
      );
  Widget _proSkillChip(String name) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: PortfolioTemplatePreview._professionalAmber.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: PortfolioTemplatePreview._professionalAmber.withValues(alpha: 0.3)),
        ),
        child: Text(name, style: GoogleFonts.jetBrainsMono(fontSize: 11, color: const Color(0xFF78350F))),
      );
}
