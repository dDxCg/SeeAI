import 'package:flutter_tts/flutter_tts.dart';

class TTSHelper {
  static final FlutterTts _flutterTts = FlutterTts();

  Future<void> initialize() async {
    await _flutterTts.setLanguage('vi-VN');  
    await _flutterTts.setPitch(1.0);  
    await _flutterTts.setSpeechRate(0.5);  
  }

  Future<void> speak(String text) async {
    if (text.isNotEmpty) {
      await _flutterTts.speak(text);
    }
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }

  Future<void> pause() async {
    await _flutterTts.pause();
  }
}