import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'pulse_dot.dart';

enum AvatarState { idle, speaking, listening, thinking }

/// Controller: TTS + state + jaw simulation. Jaw sent to ModelViewer via JS if available.
class MorpheusAvatarController {
  MorpheusAvatarController() {
    _tts.setCompletionHandler(() {
      state.value = AvatarState.idle;
      jawAmount.value = 0;
      _jawTimer?.cancel();
    });
  }

  final FlutterTts _tts = FlutterTts();
  final ValueNotifier<AvatarState> state = ValueNotifier(AvatarState.idle);
  final ValueNotifier<double> jawAmount = ValueNotifier(0.0);

  Timer? _jawTimer;

  Future<void> init() async {
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    await _tts.setLanguage('en-US');
  }

  Future<void> speak(String text) async {
    state.value = AvatarState.speaking;
    _startJawSimulation();
    await _tts.speak(text);
  }

  void stop() {
    _tts.stop();
    _jawTimer?.cancel();
    jawAmount.value = 0;
    state.value = AvatarState.idle;
  }

  void _startJawSimulation() {
    _jawTimer?.cancel();
    const period = Duration(milliseconds: 16);
    var t = 0.0;
    _jawTimer = Timer.periodic(period, (timer) {
      t += 0.2;
      jawAmount.value = math.sin(t) * 0.4;
    });
  }

  void setState(AvatarState s) {
    state.value = s;
    if (s != AvatarState.speaking) {
      _jawTimer?.cancel();
      jawAmount.value = 0;
    }
  }

  void dispose() {
    _jawTimer?.cancel();
    _tts.stop();
  }
}

/// 3D Avatar widget (model_viewer_plus) + state indicators.
class MorpheusAvatar extends StatefulWidget {
  const MorpheusAvatar({
    super.key,
    required this.controller,
    this.src = 'assets/avatars/avatar.glb',
    this.alt = 'Morpheus Avatar',
  });

  final MorpheusAvatarController controller;
  final String src;
  final String alt;

  @override
  State<MorpheusAvatar> createState() => _MorpheusAvatarState();
}

class _MorpheusAvatarState extends State<MorpheusAvatar> {
  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AvatarState>(
      valueListenable: widget.controller.state,
      builder: (context, state, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRect(
              child: SizedBox(
                height: 280,
                width: double.infinity,
                child: kIsWeb
                    ? _ModelViewerPlaceholder(src: widget.src, alt: widget.alt)
                    : Container(
                        color: AppColors.void_,
                        alignment: Alignment.center,
                        child: Text(
                          'AVATAR',
                          style: AppTypography.tag.copyWith(color: AppColors.smog),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _stateChip('SPEAKING', state == AvatarState.speaking),
                const SizedBox(width: 24),
                _stateChip('LISTENING', state == AvatarState.listening),
                const SizedBox(width: 24),
                _stateChip('THINKING', state == AvatarState.thinking),
              ],
            ),
          ],
        );
      },
    );
  }

  static Widget _stateChip(String label, bool active) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PulseDot(size: 8, active: active),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTypography.label.copyWith(
            color: active ? AppColors.ember : AppColors.smog,
          ),
        ),
      ],
    );
  }
}

/// Web-only: use model_viewer_plus. Stub on other platforms.
class _ModelViewerPlaceholder extends StatelessWidget {
  const _ModelViewerPlaceholder({required this.src, required this.alt});
  final String src;
  final String alt;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Container(
        color: AppColors.void_,
        alignment: Alignment.center,
        child: Text(
          '3D AVATAR',
          style: AppTypography.tag.copyWith(color: AppColors.smog),
        ),
      );
    }
    return Container(
      color: AppColors.void_,
      alignment: Alignment.center,
      child: Text(
        'AVATAR',
        style: AppTypography.tag.copyWith(color: AppColors.smog),
      ),
    );
  }
}
