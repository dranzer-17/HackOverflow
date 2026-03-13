import 'package:flutter_tts/flutter_tts.dart';

/// Flutter TTS for avatar speech.
class TtsService {
  TtsService._();

  static final FlutterTts _tts = FlutterTts();

  static Future<void> init() async {
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    await _tts.setLanguage('en-US');
  }

  static Future<void> speak(String text) => _tts.speak(text);
  static Future<void> stop() => _tts.stop();

  static void setCompletionHandler(void Function() callback) {
    _tts.setCompletionHandler(callback);
  }
}
