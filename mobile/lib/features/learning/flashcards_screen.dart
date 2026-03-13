import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/feature_scaffold.dart';
import '../../../core/widgets/dashboard_card.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/services/api_service.dart';

enum InputMode { text, url }

class FlashcardsScreen extends StatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen> {
  String _step = 'input'; // input | settings | study
  InputMode _inputMode = InputMode.text;
  final _textController = TextEditingController();
  final _urlController = TextEditingController();

  int _numCards = 10;
  int _wordsPerCard = 35;

  bool _loading = false;
  bool _loadingHistory = false;
  bool _saving = false;
  String? _error;
  String? _saveMessage;

  List<Map<String, dynamic>> _flashcards = [];
  int _currentIndex = 0;
  bool _showBack = false;
  bool _showGridView = false;

  String _originalContent = '';
  String _contentSource = '';

  List<dynamic> _pastSets = [];
  bool _showPastSets = false;

  final _numCardsController = TextEditingController(text: '10');
  final _wordsPerCardController = TextEditingController(text: '35');

  static const int _minContentLength = 100;

  @override
  void initState() {
    super.initState();
    _numCardsController.text = '$_numCards';
    _wordsPerCardController.text = '$_wordsPerCard';
  }

  @override
  void dispose() {
    _textController.dispose();
    _urlController.dispose();
    _numCardsController.dispose();
    _wordsPerCardController.dispose();
    super.dispose();
  }

  bool get _hasContent {
    if (_inputMode == InputMode.text) return _textController.text.trim().length >= _minContentLength;
    return _urlController.text.trim().isNotEmpty;
  }

  void _goToSettings() {
    if (_inputMode == InputMode.text && _textController.text.trim().length < _minContentLength) {
      setState(() => _error = 'Please enter at least $_minContentLength characters of text.');
      return;
    }
    if (_inputMode == InputMode.url && _urlController.text.trim().isEmpty) {
      setState(() => _error = 'Please enter a URL.');
      return;
    }
    setState(() { _error = null; _step = 'settings'; });
  }

  Future<void> _generate() async {
    final numCards = () {
      final n = int.tryParse(_numCardsController.text);
      return n != null && n >= 5 && n <= 50 ? n : _numCards;
    }();
    final wordsPerCard = () {
      final n = int.tryParse(_wordsPerCardController.text);
      return n != null && n >= 20 && n <= 50 ? n : _wordsPerCard;
    }();
    setState(() { _loading = true; _error = null; _numCards = numCards; _wordsPerCard = wordsPerCard; });
    try {
      final formData = FormData.fromMap({
        'num_cards': numCards.toString(),
        'words_per_card': wordsPerCard.toString(),
      });
      if (_inputMode == InputMode.text) {
        formData.fields.add(MapEntry('text', _textController.text.trim()));
      } else {
        formData.fields.add(MapEntry('url', _urlController.text.trim()));
      }

      final res = await ApiService.dio.post(
        ApiEndpoints.flashcardsGenerate,
        data: formData,
      );
      final data = res.data as Map<String, dynamic>?;
      final list = data?['flashcards'];
      if (list is! List || list.isEmpty) {
        throw Exception(data?['detail'] ?? 'No flashcards returned');
      }
      final cards = list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      if (!mounted) return;
      setState(() {
        _flashcards = cards;
        _originalContent = (data?['original_content'] as String?) ?? '';
        _contentSource = (data?['content_source'] as String?) ?? _inputMode.name;
        _currentIndex = 0;
        _showBack = false;
        _showGridView = false;
        _step = 'study';
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      final msg = e is DioException && e.response?.data != null
          ? (e.response!.data is Map ? (e.response!.data as Map)['detail']?.toString() : null) ?? e.message
          : e.toString();
      setState(() {
        _error = (msg ?? e.toString()).replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  Future<void> _fetchHistory() async {
    setState(() { _loadingHistory = true; _error = null; });
    try {
      final res = await ApiService.get(ApiEndpoints.flashcardsHistory);
      final data = res.data as Map<String, dynamic>?;
      final sets = data?['flashcard_sets'] as List<dynamic>? ?? [];
      if (!mounted) return;
      setState(() { _pastSets = sets; _showPastSets = true; _loadingHistory = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loadingHistory = false;
      });
    }
  }

  Future<void> _loadPastSet(int flashcardId) async {
    try {
      final res = await ApiService.get(ApiEndpoints.flashcardsHistoryById(flashcardId));
      final data = res.data as Map<String, dynamic>?;
      final set = data?['flashcard_set'] as Map<String, dynamic>?;
      final list = set?['flashcards'] as List<dynamic>?;
      if (list == null || list.isEmpty) throw Exception('No cards in set');
      final cards = list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      if (!mounted) return;
      setState(() {
        _flashcards = cards;
        _currentIndex = 0;
        _showBack = false;
        _showGridView = false;
        _step = 'study';
        _showPastSets = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _saveSet() async {
    if (_flashcards.isEmpty) return;
    setState(() { _saving = true; _saveMessage = null; _error = null; });
    try {
      await ApiService.post(ApiEndpoints.flashcardsSave, data: {
        'flashcards': _flashcards,
        'original_content': _originalContent,
        'content_source': _contentSource,
        'num_cards': _numCards,
        'words_per_card': _wordsPerCard,
      });
      if (!mounted) return;
      setState(() { _saveMessage = 'Flashcard set saved successfully!'; _saving = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _saving = false;
      });
    }
  }

  void _reset() {
    setState(() {
      _step = 'input';
      _flashcards = [];
      _currentIndex = 0;
      _showBack = false;
      _showGridView = false;
      _originalContent = '';
      _contentSource = '';
      _saveMessage = null;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FeatureScaffold(
          title: 'Flashcards',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Upload a PDF, paste a URL, or enter text to generate flashcards.',
                style: AppTypography.bodySmall.copyWith(color: AppColors.foregroundDim),
              ),
              const SizedBox(height: 20),
              if (_error != null) ...[
                _ErrorBanner(message: _error!),
                const SizedBox(height: 16),
              ],
              if (_step == 'input') _buildInput(),
              if (_step == 'settings') _buildSettings(),
              if (_step == 'study') _buildStudy(),
            ],
          ),
        ),
        if (_showPastSets) Positioned.fill(child: _buildHistoryModal()),
      ],
    );
  }

  Widget _buildInput() {
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _modeChip(InputMode.text, Icons.text_fields, 'Text'),
              const SizedBox(width: 8),
              _modeChip(InputMode.url, Icons.link, 'URL'),
            ],
          ),
          const SizedBox(height: 16),
          if (_inputMode == InputMode.text) ...[
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                hintText: 'Paste your study material here (min. 100 characters)...',
                border: OutlineInputBorder(),
                filled: true,
                alignLabelWithHint: true,
              ),
              maxLines: 6,
              onChanged: (_) => setState(() {}),
            ),
            if (_textController.text.trim().isNotEmpty && _textController.text.trim().length < _minContentLength)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '${_textController.text.trim().length}/$_minContentLength characters',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.foregroundDim),
                ),
              ),
          ] else
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                hintText: 'https://example.com/article',
                border: OutlineInputBorder(),
                filled: true,
              ),
              keyboardType: TextInputType.url,
              onChanged: (_) => setState(() {}),
            ),
          const SizedBox(height: 20),
          Row(
            children: [
              TextButton.icon(
                onPressed: _loadingHistory ? null : _fetchHistory,
                icon: _loadingHistory
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.history, size: 18),
                label: Text(_loadingHistory ? 'Loading...' : 'View history'),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: _hasContent ? _goToSettings : null,
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: const Text('Next: Settings'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _modeChip(InputMode mode, IconData icon, String label) {
    final selected = _inputMode == mode;
    return Expanded(
      child: Material(
        color: selected ? AppColors.primaryWithOpacity(0.15) : AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: () => setState(() => _inputMode = mode),
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 20, color: selected ? AppColors.primary : AppColors.foregroundDim),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: AppTypography.label.copyWith(
                    color: selected ? AppColors.primary : AppColors.foreground,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettings() {
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Number of flashcards (5–50)',
            style: AppTypography.label.copyWith(color: AppColors.foreground),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _numCardsController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              filled: true,
            ),
            onChanged: (v) {
              final n = int.tryParse(v);
              if (n != null && n >= 5 && n <= 50) setState(() => _numCards = n);
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Max words per side (20–50)',
            style: AppTypography.label.copyWith(color: AppColors.foreground),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _wordsPerCardController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              filled: true,
            ),
            onChanged: (v) {
              final n = int.tryParse(v);
              if (n != null && n >= 20 && n <= 50) setState(() => _wordsPerCard = n);
            },
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () => setState(() => _step = 'input'),
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text('Back to content'),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: _loading ? null : _generate,
                icon: _loading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.style, size: 18),
                label: Text(_loading ? 'Generating...' : 'Generate flashcards'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStudy() {
    if (_flashcards.isEmpty) {
      return DashboardCard(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              'No flashcards yet. Generate a set first.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.foregroundDim),
            ),
          ),
        ),
      );
    }

    final card = _flashcards[_currentIndex];
    final front = card['front']?.toString() ?? '';
    final back = card['back']?.toString() ?? '';
    final difficulty = card['difficulty']?.toString() ?? 'medium';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              'Study mode',
              style: AppTypography.label.copyWith(
                color: AppColors.foreground,
                fontSize: 16,
              ),
            ),
            const Spacer(),
            Text(
              'Card ${_currentIndex + 1} of ${_flashcards.length}',
              style: AppTypography.bodySmall.copyWith(color: AppColors.foregroundDim),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            FilledButton.icon(
              onPressed: _saving ? null : _saveSet,
              icon: _saving
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.check_circle_outline, size: 18),
              label: Text(_saving ? 'Saving...' : 'Save set'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton(onPressed: _reset, child: const Text('Reset')),
          ],
        ),
        if (_saveMessage != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Text(_saveMessage!, style: AppTypography.bodySmall.copyWith(color: Colors.green.shade800)),
          ),
        ],
        const SizedBox(height: 16),
        DashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () => setState(() => _showGridView = !_showGridView),
                    icon: const Icon(Icons.grid_view, size: 18),
                    label: Text(_showGridView ? 'Card view' : 'View all'),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryWithOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      difficulty.toUpperCase(),
                      style: AppTypography.label.copyWith(
                        fontSize: 10,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_showGridView)
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _flashcards.map((c) {
                        return SizedBox(
                          width: (constraints.maxWidth - 12) / 2,
                          child: _MiniCard(
                            front: c['front']?.toString() ?? '',
                            back: c['back']?.toString() ?? '',
                            difficulty: c['difficulty']?.toString() ?? 'medium',
                          ),
                        );
                      }).toList(),
                    );
                  },
                )
              else
                _FlipCard(
                  front: front,
                  back: back,
                  showBack: _showBack,
                  onTap: () => setState(() => _showBack = !_showBack),
                ),
            ],
          ),
        ),
        if (!_showGridView) ...[
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filled(
                onPressed: _currentIndex > 0 ? () => setState(() { _currentIndex--; _showBack = false; }) : null,
                icon: const Icon(Icons.chevron_left),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  foregroundColor: AppColors.foreground,
                ),
              ),
              const SizedBox(width: 24),
              IconButton.filled(
                onPressed: _currentIndex < _flashcards.length - 1
                    ? () => setState(() { _currentIndex++; _showBack = false; })
                    : null,
                icon: const Icon(Icons.chevron_right),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildHistoryModal() {
    if (!_showPastSets) return const SizedBox.shrink();
    return Container(
      color: Colors.black54,
      child: Center(
        child: DashboardCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text('Flashcard history', style: AppTypography.label.copyWith(color: AppColors.foreground)),
                  const Spacer(),
                  TextButton(
                    onPressed: () => setState(() => _showPastSets = false),
                    child: const Text('Close'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 300,
                child: _pastSets.isEmpty
                    ? Center(child: Text('No saved sets.', style: AppTypography.bodySmall.copyWith(color: AppColors.foregroundDim)))
                    : ListView.builder(
                        itemCount: _pastSets.length,
                        itemBuilder: (context, i) {
                          final s = _pastSets[i] as Map<String, dynamic>;
                          final id = s['flashcard_id'];
                          final total = s['total_cards'] ?? 0;
                          final words = s['words_per_card'] ?? 0;
                          final created = s['created_at']?.toString() ?? '';
                          return ListTile(
                            title: Text('Set #$id'),
                            subtitle: Text('$total cards • $words words/side'),
                            trailing: Text(created.length > 10 ? created.substring(0, 10) : created),
                            onTap: () => _loadPastSet(id as int),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
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

class _FlipCard extends StatelessWidget {
  const _FlipCard({
    required this.front,
    required this.back,
    required this.showBack,
    required this.onTap,
  });

  final String front;
  final String back;
  final bool showBack;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: Container(
          key: ValueKey(showBack),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                showBack ? 'Answer' : 'Question',
                style: AppTypography.label.copyWith(
                  color: AppColors.foregroundDim,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                showBack ? back : front,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.foreground,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniCard extends StatelessWidget {
  const _MiniCard({required this.front, required this.back, required this.difficulty});

  final String front;
  final String back;
  final String difficulty;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryWithOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(difficulty, style: AppTypography.label.copyWith(fontSize: 10, color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('Q: $front', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w500), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text('A: $back', style: AppTypography.bodySmall.copyWith(color: AppColors.foregroundDim), maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
