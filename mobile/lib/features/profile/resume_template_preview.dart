import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Unified resume data shape for all 5 templates (matches web ModernTemplate etc).
class ResumeTemplateData {
  ResumeTemplateData({
    required this.personal,
    required this.summary,
    required this.experience,
    required this.education,
    required this.skills,
    this.projects = const [],
  });

  final Map<String, String> personal;
  final String summary;
  final List<Map<String, dynamic>> experience;
  final List<Map<String, dynamic>> education;
  final Map<String, List<String>> skills;
  final List<Map<String, dynamic>> projects;

  List<String> get allSkills {
    final l = skills['languages'] ?? [];
    final f = skills['frameworks'] ?? [];
    final t = skills['tools'] ?? [];
    return [...l, ...f, ...t];
  }
}

/// Renders resume preview in one of 5 styles: modern, classic, creative, minimal, professional.
class ResumeTemplatePreview extends StatelessWidget {
  const ResumeTemplatePreview({
    super.key,
    required this.data,
    required this.templateId,
  });

  final ResumeTemplateData data;
  final String templateId;

  @override
  Widget build(BuildContext context) {
    switch (templateId) {
      case 'classic':
        return _ClassicResume(data: data);
      case 'creative':
        return _CreativeResume(data: data);
      case 'minimal':
        return _MinimalResume(data: data);
      case 'professional':
        return _ProfessionalResume(data: data);
      default:
        return _ModernResume(data: data);
    }
  }
}

// --- Helpers ---
String _s(dynamic v) => v?.toString() ?? '';
String _name(ResumeTemplateData d) => d.personal['name'] ?? 'Your Name';
String _email(ResumeTemplateData d) => d.personal['email'] ?? '';

// --- Modern: blue sidebar + main content ---
class _ModernResume extends StatelessWidget {
  const _ModernResume({required this.data});
  final ResumeTemplateData data;

  static const Color _sidebarBlue = Color(0xFF1E3A8A);
  static const Color _accentBlue = Color(0xFF3B82F6);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 140,
            padding: const EdgeInsets.all(20),
            color: _sidebarBlue,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  _name(data),
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                if (_email(data).isNotEmpty)
                  Text(
                    _email(data),
                    style: GoogleFonts.inter(fontSize: 10, color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                if (data.personal['location']?.isNotEmpty == true) ...[
                  const SizedBox(height: 8),
                  Text(
                    data.personal['location']!,
                    style: GoogleFonts.inter(fontSize: 10, color: Colors.white70),
                  ),
                ],
                const SizedBox(height: 16),
                Text(
                  'SKILLS',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _accentBlue,
                  ),
                ),
                const SizedBox(height: 6),
                ...data.allSkills.take(12).map(
                      (s) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          s,
                          style: GoogleFonts.inter(fontSize: 9, color: Colors.white),
                        ),
                      ),
                    ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (data.summary.isNotEmpty) ...[
                    Text(
                      'SUMMARY',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _sidebarBlue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.summary,
                      style: GoogleFonts.inter(fontSize: 10, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                  ],
                  _sectionTitle('EXPERIENCE'),
                  ...data.experience.take(4).map((e) => _modernExp(e)),
                  _sectionTitle('EDUCATION'),
                  ...data.education.take(3).map((e) => _modernEdu(e)),
                  if (data.projects.isNotEmpty) ...[
                    _sectionTitle('PROJECTS'),
                    ...data.projects.take(2).map((e) => _modernProj(e)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) => Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 6),
        child: Text(
          t,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: _sidebarBlue,
          ),
        ),
      );
  Widget _modernExp(Map<String, dynamic> e) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _s(e['title']),
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
            ),
            Text(
              '${_s(e['company'])} • ${_s(e['startDate'])} – ${_s(e['endDate'])}',
              style: GoogleFonts.inter(fontSize: 9, color: Colors.grey.shade700),
            ),
            if (_s(e['description']).isNotEmpty)
              Text(
                _s(e['description']),
                style: GoogleFonts.inter(fontSize: 9, height: 1.3),
              ),
          ],
        ),
      );
  Widget _modernEdu(Map<String, dynamic> e) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _s(e['degree']),
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
            ),
            Text(
              '${_s(e['school'])} • ${_s(e['graduationDate'])}',
              style: GoogleFonts.inter(fontSize: 9, color: Colors.grey.shade700),
            ),
          ],
        ),
      );
  Widget _modernProj(Map<String, dynamic> e) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _s(e['name']),
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
            ),
            if (_s(e['description']).isNotEmpty)
              Text(
                _s(e['description']),
                style: GoogleFonts.inter(fontSize: 9, height: 1.3),
              ),
          ],
        ),
      );
}

// --- Classic: serif, centered header, black border ---
class _ClassicResume extends StatelessWidget {
  const _ClassicResume({required this.data});
  final ResumeTemplateData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            _name(data),
            style: GoogleFonts.merriweather(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            height: 2,
            width: 80,
            color: Colors.black,
          ),
          if (_email(data).isNotEmpty)
            Text(
              _email(data),
              style: GoogleFonts.merriweather(fontSize: 10, color: Colors.black87),
            ),
          if (data.summary.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              data.summary,
              style: GoogleFonts.merriweather(fontSize: 10, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 16),
          _classicSection('EXPERIENCE'),
          ...data.experience.take(4).map((e) => _classicExp(e)),
          _classicSection('EDUCATION'),
          ...data.education.take(3).map((e) => _classicEdu(e)),
          _classicSection('SKILLS'),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: data.allSkills.take(15).map((s) => Text(s, style: GoogleFonts.merriweather(fontSize: 9))).toList(),
          ),
        ],
      ),
    );
  }

  Widget _classicSection(String t) => Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 6),
        child: Text(
          t,
          style: GoogleFonts.merriweather(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      );
  Widget _classicExp(Map<String, dynamic> e) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_s(e['title']), style: GoogleFonts.merriweather(fontSize: 11, fontWeight: FontWeight.w600)),
            Text('${_s(e['company'])} • ${_s(e['startDate'])} – ${_s(e['endDate'])}', style: GoogleFonts.merriweather(fontSize: 9)),
            if (_s(e['description']).isNotEmpty)
              Text(_s(e['description']), style: GoogleFonts.merriweather(fontSize: 9, height: 1.3)),
          ],
        ),
      );
  Widget _classicEdu(Map<String, dynamic> e) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_s(e['degree']), style: GoogleFonts.merriweather(fontSize: 11, fontWeight: FontWeight.w600)),
            Text('${_s(e['school'])} • ${_s(e['graduationDate'])}', style: GoogleFonts.merriweather(fontSize: 9)),
          ],
        ),
      );
}

// --- Creative: warm background, amber accent ---
class _CreativeResume extends StatelessWidget {
  const _CreativeResume({required this.data});
  final ResumeTemplateData data;

  static const Color _amber = Color(0xFFB45309);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFAF8F5),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _name(data),
            style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: _amber),
          ),
          if (_email(data).isNotEmpty)
            Text(_email(data), style: GoogleFonts.inter(fontSize: 10, color: Colors.black54)),
          if (data.summary.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(data.summary, style: GoogleFonts.inter(fontSize: 10, height: 1.4)),
          ],
          _creativeSection('Experience'),
          ...data.experience.take(4).map((e) => _creativeExp(e)),
          _creativeSection('Education'),
          ...data.education.take(3).map((e) => _creativeEdu(e)),
          _creativeSection('Skills'),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: data.allSkills.take(12).map((s) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(s, style: GoogleFonts.inter(fontSize: 9, color: _amber)),
                )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _creativeSection(String t) => Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 6),
        child: Text(
          t,
          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: _amber),
        ),
      );
  Widget _creativeExp(Map<String, dynamic> e) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_s(e['title']), style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600)),
            Text('${_s(e['company'])} • ${_s(e['startDate'])} – ${_s(e['endDate'])}', style: GoogleFonts.inter(fontSize: 9, color: Colors.black54)),
            if (_s(e['description']).isNotEmpty)
              Text(_s(e['description']), style: GoogleFonts.inter(fontSize: 9, height: 1.3)),
          ],
        ),
      );
  Widget _creativeEdu(Map<String, dynamic> e) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_s(e['degree']), style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600)),
            Text('${_s(e['school'])} • ${_s(e['graduationDate'])}', style: GoogleFonts.inter(fontSize: 9, color: Colors.black54)),
          ],
        ),
      );
}

// --- Minimal: clean, lots of white ---
class _MinimalResume extends StatelessWidget {
  const _MinimalResume({required this.data});
  final ResumeTemplateData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _name(data),
            style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black),
          ),
          if (_email(data).isNotEmpty)
            Text(_email(data), style: GoogleFonts.inter(fontSize: 10, color: Colors.black54)),
          if (data.summary.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(data.summary, style: GoogleFonts.inter(fontSize: 10, height: 1.5, color: Colors.black87)),
          ],
          const SizedBox(height: 16),
          _minimalSection('EXPERIENCE'),
          ...data.experience.take(4).map((e) => _minimalExp(e)),
          _minimalSection('EDUCATION'),
          ...data.education.take(3).map((e) => _minimalEdu(e)),
          _minimalSection('SKILLS'),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: data.allSkills.take(15).map((s) => Text(s, style: GoogleFonts.inter(fontSize: 10, color: Colors.black87))).toList(),
          ),
        ],
      ),
    );
  }

  Widget _minimalSection(String t) => Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 8),
        child: Text(
          t,
          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54, letterSpacing: 1.2),
        ),
      );
  Widget _minimalExp(Map<String, dynamic> e) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_s(e['title']), style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600)),
            Text('${_s(e['company'])} • ${_s(e['startDate'])} – ${_s(e['endDate'])}', style: GoogleFonts.inter(fontSize: 9, color: Colors.black54)),
            if (_s(e['description']).isNotEmpty)
              Text(_s(e['description']), style: GoogleFonts.inter(fontSize: 9, height: 1.3)),
          ],
        ),
      );
  Widget _minimalEdu(Map<String, dynamic> e) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_s(e['degree']), style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600)),
            Text('${_s(e['school'])} • ${_s(e['graduationDate'])}', style: GoogleFonts.inter(fontSize: 9, color: Colors.black54)),
          ],
        ),
      );
}

// --- Professional: corporate, gray header ---
class _ProfessionalResume extends StatelessWidget {
  const _ProfessionalResume({required this.data});
  final ResumeTemplateData data;

  static const Color _gray = Color(0xFF374151);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            color: _gray,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _name(data),
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                if (_email(data).isNotEmpty)
                  Text(_email(data), style: GoogleFonts.inter(fontSize: 10, color: Colors.white70)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (data.summary.isNotEmpty) ...[
                  Text(data.summary, style: GoogleFonts.inter(fontSize: 10, height: 1.4)),
                  const SizedBox(height: 16),
                ],
                _proSection('EXPERIENCE'),
                ...data.experience.take(4).map((e) => _proExp(e)),
                _proSection('EDUCATION'),
                ...data.education.take(3).map((e) => _proEdu(e)),
                _proSection('SKILLS'),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: data.allSkills.take(15).map((s) => Text(s, style: GoogleFonts.inter(fontSize: 10, color: _gray))).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _proSection(String t) => Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 6),
        child: Text(
          t,
          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: _gray),
        ),
      );
  Widget _proExp(Map<String, dynamic> e) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_s(e['title']), style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600)),
            Text('${_s(e['company'])} • ${_s(e['startDate'])} – ${_s(e['endDate'])}', style: GoogleFonts.inter(fontSize: 9, color: _gray)),
            if (_s(e['description']).isNotEmpty)
              Text(_s(e['description']), style: GoogleFonts.inter(fontSize: 9, height: 1.3)),
          ],
        ),
      );
  Widget _proEdu(Map<String, dynamic> e) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_s(e['degree']), style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600)),
            Text('${_s(e['school'])} • ${_s(e['graduationDate'])}', style: GoogleFonts.inter(fontSize: 9, color: _gray)),
          ],
        ),
      );
}
