import 'package:speech_to_text/speech_to_text.dart';
import 'dart:async';

class VoiceService {
  final SpeechToText _speech = SpeechToText();
  
  Future<bool> init({Function(String)? onStatus, Function(dynamic)? onError}) async {
    return await _speech.initialize(
      onStatus: onStatus,
      onError: onError,
      finalTimeout: const Duration(milliseconds: 5000),
    );
  }

  void startListening(Function(String) onResult) {
    if (_speech.isListening) return;
    _speech.listen(
      onResult: (result) => onResult(result.recognizedWords),
      listenOptions: SpeechListenOptions(
        localeId: 'ta_IN',
        partialResults: true,
        listenMode: ListenMode.confirmation,
      ),
    );
  }

  void stopListening() {
    _speech.stop();
  }

  bool get isListening => _speech.isListening;
  bool get isAvailable => _speech.isAvailable;

  Map<String, dynamic>? parseTamilInput(String text) {
    if (text.isEmpty) return null;
    
    // Improved regex to extract numbers (including Tamil digits if any, but mostly standard digits)
    final RegExp amountRegExp = RegExp(r'(\d+)');
    final match = amountRegExp.firstMatch(text);
    
    double? amount;
    if (match != null) {
      amount = double.tryParse(match.group(1)!);
    }
    
    String category = 'மற்றவை';

    // Tamil keywords mapping (Elderly friendly)
    if (text.contains('மளிகை') || text.contains('கடை')) {
      category = 'மளிகை';
    } else if (text.contains('மருந்து') || text.contains('மாத்திரை') || text.contains('டாக்டர்')) {
      category = 'மருந்து';
    } else if (text.contains('மின்சாரம்') || text.contains('பில்') || text.contains('கட்டணம்')) {
      category = 'பில்';
    } else if (text.contains('பேருந்து') || text.contains('வண்டி') || text.contains('ஆட்டோ') || text.contains('போக்குவரத்து')) {
      category = 'போக்குவரத்து';
    } else if (text.contains('சாப்பாடு') || text.contains('உணவு') || text.contains('ஹோட்டல்')) {
      category = 'உணவு';
    }

    if (amount == null) return null;

    return {
      'amount': amount,
      'category': category,
    };
  }
}
