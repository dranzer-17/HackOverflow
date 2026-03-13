import 'resume_template_preview.dart';

/// Builds ResumeTemplateData from API responses (AI resume data or profile + user).
class ResumeDataTransform {
  /// From GET /ai-resume-builder/resume-data (body.data).
  static ResumeTemplateData? fromAiResumeData(Map<String, dynamic>? data) {
    if (data == null) return null;

    final personalInfo = data['personal_info'] is Map ? data['personal_info'] as Map<String, dynamic> : null;
    final name = personalInfo?['name']?.toString() ?? 'Your Name';
    final email = personalInfo?['email']?.toString() ?? '';
    final phone = personalInfo?['phone']?.toString() ?? '';
    final location = personalInfo?['location']?.toString() ?? '';
    final linkedin = personalInfo?['linkedin']?.toString();
    final github = personalInfo?['github']?.toString();
    final website = personalInfo?['portfolio']?.toString() ?? personalInfo?['website']?.toString();

    final personal = <String, String>{
      'name': name,
      'title': '',
      'email': email,
      'phone': phone,
      'location': location,
    };
    if (linkedin != null && linkedin.isNotEmpty) personal['linkedin'] = linkedin;
    if (github != null && github.isNotEmpty) personal['github'] = github;
    if (website != null && website.isNotEmpty) personal['website'] = website;

    final summary = data['summary']?.toString() ?? '';

    // Skills: either [{ category, skills: [] }] or [{ name }]
    final skillsRaw = data['skills'];
    List<String> allSkillsList = [];
    if (skillsRaw is List) {
      for (final s in skillsRaw) {
        if (s is Map<String, dynamic>) {
          if (s['skills'] is List) {
            for (final x in s['skills'] as List) {
              allSkillsList.add(x is String ? x : x['name']?.toString() ?? x.toString());
            }
          } else if (s['name'] != null) {
            allSkillsList.add(s['name'].toString());
          } else if (s['category'] == null && (s as Map).isNotEmpty) {
            allSkillsList.add(s.values.first?.toString() ?? '');
          }
        } else if (s is String) {
          allSkillsList.add(s);
        }
      }
    }
    final skillCount = allSkillsList.length;
    final n = skillCount >= 3 ? (skillCount / 3).ceil() : skillCount;
    final skills = <String, List<String>>{
      'languages': allSkillsList.take(n).toList(),
      'frameworks': allSkillsList.skip(n).take(n).toList(),
      'tools': allSkillsList.skip(n * 2).toList(),
    };

    // Experience
    final expRaw = data['experience'] is List ? data['experience'] as List : [];
    final experience = <Map<String, dynamic>>[];
    for (final e in expRaw) {
      if (e is! Map<String, dynamic>) continue;
      final desc = e['description'];
      final descStr = desc is List
          ? (desc.isNotEmpty ? desc.first?.toString() ?? '' : '')
          : desc?.toString() ?? '';
      experience.add({
        'title': e['title']?.toString() ?? '',
        'company': e['company']?.toString() ?? '',
        'location': e['location']?.toString() ?? '',
        'startDate': e['start_date']?.toString() ?? e['startDate']?.toString() ?? '',
        'endDate': e['end_date']?.toString() ?? e['endDate']?.toString() ?? 'Present',
        'description': descStr,
      });
    }

    // Education
    final eduRaw = data['education'] is List ? data['education'] as List : [];
    final education = <Map<String, dynamic>>[];
    for (final e in eduRaw) {
      if (e is! Map<String, dynamic>) continue;
      education.add({
        'degree': e['degree']?.toString() ?? '',
        'school': e['institution']?.toString() ?? '',
        'location': e['location']?.toString() ?? '',
        'graduationDate': e['graduation_date']?.toString() ?? e['year']?.toString() ?? e['date']?.toString() ?? '',
      });
    }

    // Projects
    final projRaw = data['projects'] is List ? data['projects'] as List : [];
    final projects = <Map<String, dynamic>>[];
    for (final p in projRaw) {
      if (p is! Map<String, dynamic>) continue;
      final tech = p['technologies'];
      final techList = tech is List
          ? tech.map((t) => t.toString()).toList()
          : (tech is String ? tech.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList() : <String>[]);
      projects.add({
        'name': p['name']?.toString() ?? '',
        'description': p['description']?.toString() ?? '',
        'technologies': techList,
        'link': p['link']?.toString(),
      });
    }

    return ResumeTemplateData(
      personal: personal,
      summary: summary,
      experience: experience,
      education: education,
      skills: skills,
      projects: projects,
    );
  }

  /// From GET /profile + GET /auth/me (when no AI resume data).
  static ResumeTemplateData? fromProfileAndUser(
    Map<String, dynamic>? profile,
    Map<String, dynamic>? user,
  ) {
    if (profile == null) return null;

    final name = user?['full_name']?.toString() ?? 'Your Name';
    final email = user?['email']?.toString() ?? '';
    final location = profile['location']?.toString() ?? '';
    final links = profile['links'] is List ? profile['links'] as List : [];
    String? phone, linkedin, github, website;
    for (final l in links) {
      if (l is! Map<String, dynamic>) continue;
      final type = (l['type'] ?? '').toString().toLowerCase();
      final value = l['value']?.toString() ?? l['url']?.toString() ?? '';
      if (type == 'phone') {
        phone = value;
      } else if (type == 'linkedin') {
        linkedin = value;
      } else if (type == 'github') {
        github = value;
      } else if (type == 'website' || type == 'portfolio') {
        website = value;
      }
    }
    final personal = <String, String>{
      'name': name,
      'title': '',
      'email': email,
      'phone': phone ?? '',
      'location': location,
    };
    if (linkedin != null && linkedin.isNotEmpty) personal['linkedin'] = linkedin;
    if (github != null && github.isNotEmpty) personal['github'] = github;
    if (website != null && website.isNotEmpty) personal['website'] = website;

    final skillsRaw = profile['skills'] is List ? profile['skills'] as List : [];
    final allSkillsList = <String>[];
    for (final s in skillsRaw) {
      if (s is Map) {
        allSkillsList.add(s['name']?.toString() ?? s.toString());
      } else {
        allSkillsList.add(s.toString());
      }
    }
    final skillCount = allSkillsList.length;
    final n = skillCount >= 3 ? (skillCount / 3).ceil() : skillCount;
    final skills = <String, List<String>>{
      'languages': allSkillsList.take(n).toList(),
      'frameworks': allSkillsList.skip(n).take(n).toList(),
      'tools': allSkillsList.skip(n * 2).toList(),
    };

    final expRaw = profile['experiences'] is List ? profile['experiences'] as List : [];
    final experience = <Map<String, dynamic>>[];
    for (final e in expRaw) {
      if (e is! Map<String, dynamic>) continue;
      experience.add({
        'title': e['title']?.toString() ?? '',
        'company': e['company']?.toString() ?? '',
        'location': '',
        'startDate': e['startDate']?.toString() ?? '',
        'endDate': e['currentlyWorking'] == true ? 'Present' : (e['endDate']?.toString() ?? ''),
        'description': e['description']?.toString() ?? '',
      });
    }

    final eduRaw = profile['education'] is List ? profile['education'] as List : [];
    final education = <Map<String, dynamic>>[];
    for (final e in eduRaw) {
      if (e is! Map<String, dynamic>) continue;
      education.add({
        'degree': e['degree']?.toString() ?? '',
        'school': e['institution']?.toString() ?? '',
        'location': '',
        'graduationDate': e['year']?.toString() ?? '',
      });
    }

    final projRaw = profile['projects'] is List ? profile['projects'] as List : [];
    final projects = <Map<String, dynamic>>[];
    for (final p in projRaw) {
      if (p is! Map<String, dynamic>) continue;
      final tech = p['technologies'];
      final techList = tech is List
          ? tech.map((t) => t.toString()).toList()
          : (tech is String ? tech.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList() : <String>[]);
      projects.add({
        'name': p['name']?.toString() ?? '',
        'description': p['description']?.toString() ?? '',
        'technologies': techList,
        'link': p['link']?.toString(),
      });
    }

    return ResumeTemplateData(
      personal: personal,
      summary: '',
      experience: experience,
      education: education,
      skills: skills,
      projects: projects,
    );
  }
}
