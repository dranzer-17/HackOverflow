import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/dashboard_card.dart';
import '../../../core/widgets/feature_scaffold.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/auth_service.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _me;
  Map<String, dynamic>? _profile;
  bool _editing = false;
  late TextEditingController _locationController;
  late TextEditingController _skillInputController;
  List<Map<String, String>> _skills = [];
  bool _saving = false;
  bool _uploading = false;
  bool _extracting = false;

  @override
  void initState() {
    super.initState();
    _locationController = TextEditingController();
    _skillInputController = TextEditingController();
    _load();
  }

  @override
  void dispose() {
    _locationController.dispose();
    _skillInputController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() { _loading = true; _error = null; });
    try {
      final me = await AuthService.meProfile();
      final profileRes = await ApiService.get(ApiEndpoints.profile);
      final profile = profileRes.data as Map<String, dynamic>? ?? {};
      if (!mounted) return;
      setState(() {
        _me = me;
        _profile = profile;
        _loading = false;
        _locationController.text = profile['location']?.toString() ?? '';
        final raw = profile['skills'];
        if (raw is List) {
          _skills = [
            for (final s in raw)
              {
                'id': (s is Map ? s['id'] : null)?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
                'name': (s is Map ? s['name'] : null)?.toString() ?? s.toString(),
              },
          ];
        } else {
          _skills = [];
        }
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
    if (!mounted) return;
    setState(() { _saving = true; _error = null; });
    try {
      await ApiService.put(ApiEndpoints.profile, data: {
        'location': _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
        'skills': [
          for (final s in _skills) {'id': s['id'], 'name': s['name']!},
        ],
      });
      if (!mounted) return;
      setState(() {
        _editing = false;
        _saving = false;
      });
      _load();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _saving = false;
      });
    }
  }

  void _addSkill() {
    final name = _skillInputController.text.trim();
    if (name.isEmpty) return;
    setState(() {
      _skills.add({'id': DateTime.now().millisecondsSinceEpoch.toString(), 'name': name});
      _skillInputController.clear();
    });
  }

  void _removeSkill(int index) {
    setState(() => _skills.removeAt(index));
  }

  Future<MultipartFile> _toMultipartFile(PlatformFile file) async {
    if (file.bytes != null) {
      return MultipartFile.fromBytes(file.bytes!, filename: file.name);
    }
    if (file.path != null) {
      return await MultipartFile.fromFile(file.path!, filename: file.name);
    }
    throw Exception('Could not read the selected file.');
  }

  Future<void> _pickAndUploadResume() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: kIsWeb,
    );
    if (result == null) return;
    if (!mounted) return;
    setState(() { _uploading = true; _error = null; });
    try {
      final file = result.files.single;
      final formData = FormData.fromMap({
        'file': await _toMultipartFile(file),
      });
      await ApiService.dio.post(
        ApiEndpoints.profileResumeUpload,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      if (!mounted) return;
      setState(() => _uploading = false);
      _load();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _uploading = false;
      });
    }
  }

  Future<void> _pickAndExtractSkills() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: kIsWeb,
    );
    if (result == null) return;
    if (!mounted) return;
    setState(() { _extracting = true; _error = null; });
    try {
      final file = result.files.single;
      final formData = FormData.fromMap({
        'file': await _toMultipartFile(file),
      });
      await ApiService.dio.post(
        ApiEndpoints.profileExtractResume,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      if (!mounted) return;
      setState(() => _extracting = false);
      _load();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _extracting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FeatureScaffold(
      title: 'User Profile',
      child: _loading
          ? const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator(color: AppColors.primary)))
          : _error != null && _me == null
              ? DashboardCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_error!, style: AppTypography.bodySmall.copyWith(color: AppColors.primary)),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(onPressed: _load, child: const Text('Retry')),
                      ),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Manage your professional profile',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.foregroundFaded),
                    ),
                    const SizedBox(height: 20),
                    DashboardCard(
                      title: 'Resume',
                      titleIcon: Icons.upload_file,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Upload a PDF resume to store it, or extract skills to auto-fill your profile.',
                            style: AppTypography.bodySmall.copyWith(color: AppColors.foregroundFaded),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: _uploading ? null : _pickAndUploadResume,
                                  icon: _uploading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.upload_file, size: 18),
                                  label: Text(_uploading ? 'Uploading...' : 'Upload PDF'),
                                  style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _extracting ? null : _pickAndExtractSkills,
                                  icon: _extracting ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.auto_awesome, size: 18),
                                  label: Text(_extracting ? 'Extracting...' : 'Extract skills'),
                                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary, side: const BorderSide(color: AppColors.primary), padding: const EdgeInsets.symmetric(vertical: 12)),
                                ),
                              ),
                            ],
                          ),
                          if (_profile?['has_resume'] == true)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text('Resume on file', style: AppTypography.bodySmall.copyWith(color: AppColors.primary)),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    DashboardCard(
                      title: 'Profile',
                      titleIcon: Icons.person,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _row('Full name', _me?['full_name']?.toString() ?? '—'),
                          const SizedBox(height: 12),
                          _row('Email', _me?['email']?.toString() ?? '—'),
                          const SizedBox(height: 12),
                          if (_editing) ...[
                            Text('LOCATION', style: AppTypography.label.copyWith(color: AppColors.foregroundFaded)),
                            const SizedBox(height: 4),
                            TextField(
                              controller: _locationController,
                              style: AppTypography.bodyMedium,
                              decoration: InputDecoration(
                                hintText: 'City, Country',
                                hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.foregroundDim),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.cardBorder), borderRadius: BorderRadius.circular(8)),
                                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.primary), borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _skillInputController,
                                    style: AppTypography.bodyMedium,
                                    decoration: InputDecoration(
                                      hintText: 'Add skill',
                                      hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.foregroundDim),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.cardBorder), borderRadius: BorderRadius.circular(8)),
                                    ),
                                    onSubmitted: (_) => _addSkill(),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton.filled(
                                  onPressed: _addSkill,
                                  icon: const Icon(Icons.add),
                                  style: IconButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.foreground),
                                ),
                              ],
                            ),
                            if (_skills.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  for (int i = 0; i < _skills.length; i++)
                                    Chip(
                                      label: Text(_skills[i]['name']!),
                                      deleteIcon: const Icon(Icons.close, size: 18),
                                      onDeleted: () => _removeSkill(i),
                                      backgroundColor: AppColors.primaryWithOpacity(0.15),
                                      side: BorderSide(color: AppColors.primaryWithOpacity(0.4)),
                                    ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: FilledButton(
                                    onPressed: _saving ? null : _save,
                                    child: _saving ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Save'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                OutlinedButton(
                                  onPressed: _saving ? null : () => setState(() { _editing = false; _load(); }),
                                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.foreground, side: BorderSide(color: AppColors.cardBorder)),
                                  child: const Text('Cancel'),
                                ),
                              ],
                            ),
                          ] else ...[
                            _row('Location', _profile?['location']?.toString() ?? '—'),
                            const SizedBox(height: 12),
                            _row('Skills', _skills.isEmpty ? '—' : _skills.map((s) => s['name']).join(', ')),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () => setState(() => _editing = true),
                                icon: const Icon(Icons.edit, size: 18),
                                label: const Text('Edit profile'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  side: BorderSide(color: AppColors.primary),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _row(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: AppTypography.label.copyWith(color: AppColors.foregroundFaded)),
        const SizedBox(height: 4),
        Text(value, style: AppTypography.bodyMedium),
      ],
    );
  }
}
