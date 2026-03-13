import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart' show Options, ResponseType, ResponseBody;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/noise_background.dart';
import '../../../../core/widgets/morpheus_avatar.dart' show MorpheusAvatarController, AvatarState;
import '../../../../core/widgets/pulse_dot.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/storage_service.dart';

class CareerCounsellorScreen extends StatefulWidget {
  const CareerCounsellorScreen({super.key});

  @override
  State<CareerCounsellorScreen> createState() => _CareerCounsellorScreenState();
}

class _CareerCounsellorScreenState extends State<CareerCounsellorScreen> {
  final _controller = MorpheusAvatarController();
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  final _messages = <_ChatMessage>[];
  String? _conversationId;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _controller.init();
  }

  @override
  void dispose() {
    _controller.dispose();
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _loading) return;
    _inputController.clear();
    final userId = StorageService.userId ?? '';
    if (userId.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(role: 'user', content: text));
      _loading = true;
    });
    _controller.setState(AvatarState.thinking);

    try {
      final res = await ApiService.dio.post(
        ApiEndpoints.careerChatStream,
        data: {
          'user_id': userId,
          'message': text,
          if (_conversationId != null) 'conversation_id': _conversationId,
        },
        options: Options(
          responseType: ResponseType.stream,
          headers: {'Accept': 'text/event-stream'},
        ),
      );
      final stream = res.data as ResponseBody;
      var buffer = '';
      var assistantContent = '';
      await for (final chunk in stream.stream) {
        buffer += String.fromCharCodes(chunk);
        final lines = buffer.split('\n');
        buffer = lines.removeLast();
        for (final line in lines) {
          if (line.startsWith('data: ')) {
            final jsonStr = line.substring(6).trim();
            if (jsonStr == '[DONE]' || jsonStr.isEmpty) continue;
            try {
              final data = jsonDecode(jsonStr) as Map<String, dynamic>;
              final type = data['type'] as String?;
              if (type == 'conversation_id') {
                _conversationId = data['conversation_id'] as String?;
              } else if (type == 'text') {
                final content = (data['content'] ?? '') as String;
                if (content.isNotEmpty) {
                  assistantContent += content;
                  setState(() {
                    if (_messages.isNotEmpty && _messages.last.role == 'assistant') {
                      _messages[_messages.length - 1] = _ChatMessage(role: 'assistant', content: assistantContent);
                    } else {
                      _messages.add(_ChatMessage(role: 'assistant', content: assistantContent));
                    }
                  });
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                    );
                  });
                }
              } else if (type == 'done') {
                break;
              }
            } catch (_) {}
          }
        }
      }
      if (assistantContent.isNotEmpty) {
        HapticFeedback.heavyImpact();
        _controller.speak(assistantContent);
      }
    } catch (e) {
      setState(() {
        _messages.add(_ChatMessage(role: 'assistant', content: 'Error: ${e.toString()}'));
      });
    } finally {
      setState(() => _loading = false);
      _controller.setState(AvatarState.idle);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NoiseBackground(
        opacity: 0.04,
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              _buildStatusBar(),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, i) {
                          final m = _messages[i];
                          return _MessageBubble(role: m.role, content: m.content);
                        },
                      ),
                    ),
                    _buildInput(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.mercury),
            onPressed: () => context.pop(),
          ),
          Text('CAREER COUNSELLOR', style: AppTypography.tag),
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    return ValueListenableBuilder<AvatarState>(
      valueListenable: _controller.state,
      builder: (context, state, _) {
        if (state == AvatarState.idle && !_loading) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: AppColors.obsidian,
          child: Row(
            children: [
              PulseDot(size: 8, active: state == AvatarState.speaking),
              const SizedBox(width: 6),
              Text(
                _loading ? 'THINKING...' : state == AvatarState.speaking ? 'SPEAKING' : 'LISTENING',
                style: AppTypography.label.copyWith(
                  color: state == AvatarState.speaking ? AppColors.ember : AppColors.smog,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInput(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.obsidian),
      child: Row(
        children: [
          Text('> ', style: AppTypography.terminalPrefix),
          Expanded(
            child: TextField(
              controller: _inputController,
              style: AppTypography.bodyMedium,
              decoration: const InputDecoration(
                hintText: 'Ask about your career...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: AppColors.ember),
            onPressed: _loading ? null : _sendMessage,
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  _ChatMessage({required this.role, required this.content});
  final String role;
  final String content;
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.role, required this.content});

  final String role;
  final String content;

  @override
  Widget build(BuildContext context) {
    final isUser = role == 'user';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: isUser ? AppColors.ember : AppColors.gold, width: 2)),
          ),
          child: Text(content, style: AppTypography.bodyMedium),
        ),
      ),
    );
  }
}
