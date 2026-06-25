import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/app_controller.dart';
import '../services/voice_service.dart';
import '../theme.dart';
import 'dart:async';

class VoiceInputScreen extends StatefulWidget {
  const VoiceInputScreen({super.key});

  @override
  State<VoiceInputScreen> createState() => _VoiceInputScreenState();
}

class _VoiceInputScreenState extends State<VoiceInputScreen> with TickerProviderStateMixin {
  final VoiceService _voiceService = VoiceService();
  String _recognizedText = '';
  bool _isListening = false;
  Map<String, dynamic>? _parsedData;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _initVoice();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    _voiceService.stopListening();
    super.dispose();
  }

  Future<void> _initVoice() async {
    bool available = await _voiceService.init(
      onStatus: (status) {
        if (mounted) {
          setState(() => _isListening = status == 'listening');
        }
      },
      onError: (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('பிழை: ${error.errorMsg}')),
          );
          setState(() => _isListening = false);
        }
      },
    );
    if (!available && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('குரல் அங்கீகாரம் கிடைக்கவில்லை')),
      );
    }
  }

  void _toggleListening() {
    if (_isListening) {
      _voiceService.stopListening();
    } else {
      setState(() {
        _recognizedText = '';
        _parsedData = null;
      });
      _voiceService.startListening((result) {
        if (mounted) {
          setState(() {
            _recognizedText = result;
            _parsedData = _voiceService.parseTamilInput(result);
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('குரல் மூலம் செலவு சேர்க்க', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.info_outline_rounded), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Animated Mic
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_isListening)
                    ...[1, 2, 3].map((i) => AnimatedBuilder(
                          animation: _waveController,
                          builder: (context, child) {
                            double progress = (_waveController.value + i / 3) % 1.0;
                            return Container(
                              width: 150 + (100 * progress),
                              height: 150 + (100 * progress),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppTheme.primaryColor.withValues(alpha: 1.0 - progress),
                                  width: 2,
                                ),
                              ),
                            );
                          },
                        )),
                  GestureDetector(
                    onTap: _toggleListening,
                    child: Container(
                      height: 140,
                      width: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(colors: [Color(0xFF4285F4), Color(0xFF92278F)]),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withValues(alpha: 0.4),
                            blurRadius: 25,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                        color: Colors.white,
                        size: 70,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Text(
              _isListening ? 'பேசுங்கள்...' : 'தொடங்குவதற்கு அழுத்தவும்',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              '"500 ரூபாய் மளிகை"',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 50),

            // Recognized text area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('அறியப்பட்ட உரை:', style: TextStyle(fontSize: 16, color: Colors.grey)),
                      if (_recognizedText.isNotEmpty) const Icon(Icons.edit_outlined, size: 20, color: Colors.grey),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(20),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(
                      _recognizedText.isEmpty ? '...' : _recognizedText,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Action Button
            if (_parsedData != null)
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 70,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.read<AppController>().addExpense(
                            _parsedData!['amount'],
                            _parsedData!['category'],
                            DateTime.now(),
                          );
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                    label: const Text('இதைச் சேர்க்க', style: TextStyle(fontSize: 22, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
