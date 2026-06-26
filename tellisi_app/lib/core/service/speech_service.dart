import 'package:flutter_tts/flutter_tts.dart';

class SpeechService {
  final FlutterTts _tts = FlutterTts();

  bool _isConfigured = false;

  Future<void> _configure() async {
    if (_isConfigured) return;

    await _tts.awaitSpeakCompletion(true);

    // ينطق أسماء الحروف بالعربي.
    await _tts.setLanguage('ar-SA');

    // سرعة هادئة وواضحة للعرض.
    await _tts.setSpeechRate(0.42);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);

    _isConfigured = true;
  }

  Future<void> speakLetter(String arabicLetter) async {
    await _configure();

    // نوقف أي نطق سابق حتى لا تتراكم الأصوات.
    await _tts.stop();

    await _tts.speak(arabicLetter);
  }

  Future<void> stop() {
    return _tts.stop();
  }
}