import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';

class VoiceSearchBottomSheet extends StatefulWidget {
  const VoiceSearchBottomSheet({super.key});

  @override
  State<VoiceSearchBottomSheet> createState() => _VoiceSearchBottomSheetState();
}

class _VoiceSearchBottomSheetState extends State<VoiceSearchBottomSheet> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _text = '';
  PermissionStatus _permissionStatus = PermissionStatus.denied;
  bool _hasSpeechError = false;

  @override
  void initState() {
    super.initState();
    _checkPermissionAndInit();
  }

  Future<void> _checkPermissionAndInit() async {
    final status = await Permission.microphone.status;
    setState(() => _permissionStatus = status);
    if (status.isGranted) {
      _startListening();
    }
  }

  Future<void> _requestPermission() async {
    final status = await Permission.microphone.request();
    setState(() => _permissionStatus = status);
    if (status.isGranted) {
      _startListening();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  Future<void> _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
           if (mounted && _isListening) {
             setState(() => _isListening = false);
             if (_text.isNotEmpty) {
               Navigator.pop(context, _text);
             }
           }
        }
      },
      onError: (errorNotification) {
        if (mounted) {
          setState(() {
            _hasSpeechError = true;
            _isListening = false;
          });
        }
      },
    );

    if (available) {
      setState(() {
        _isListening = true;
        _hasSpeechError = false;
        _text = '';
      });
      _speech.listen(
        onResult: (result) {
          if (mounted) {
            setState(() => _text = result.recognizedWords);
            if (result.finalResult) {
              _isListening = false;
              Navigator.pop(context, _text);
            }
          }
        },
      );
    }
  }

  @override
  void dispose() {
    _speech.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.close, color: AppColors.deepCharcoal),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(height: 8),
            if (_isListening)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mic, size: 48, color: AppColors.primary)
                    .animate(onPlay: (controller) => controller.repeat(reverse: true))
                    .scaleXY(begin: 1.0, end: 1.2, duration: 800.ms, curve: Curves.easeInOut),
              )
            else
              GestureDetector(
                onTap: () {
                  if (_permissionStatus.isGranted) {
                    _startListening();
                  } else {
                    _requestPermission();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.borderLight.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.mic_none, size: 48, color: AppColors.deepCharcoal),
                ),
              ),
            const SizedBox(height: 24),
            Text(
              _isListening ? 'Listening...' : 'Shop faster with voice',
              style: AppTypography.h2.copyWith(fontSize: 22),
            ),
            const SizedBox(height: 8),
            if (_text.isNotEmpty && _isListening)
              Text(
                '"$_text"',
                style: AppTypography.body.copyWith(fontStyle: FontStyle.italic, color: AppColors.neutralGold),
                textAlign: TextAlign.center,
              )
            else if (_hasSpeechError)
              Text(
                'Could not understand. Tap microphone to try again.',
                style: AppTypography.bodySM.copyWith(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 32),
            if (!_permissionStatus.isGranted)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _requestPermission,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text(
                    _permissionStatus.isPermanentlyDenied ? 'Open Settings' : 'Turn on microphone',
                    style: AppTypography.label.copyWith(color: AppColors.deepCharcoal, fontWeight: FontWeight.w800, fontSize: 14),
                  ),
                ),
              ),
            if (!_permissionStatus.isGranted) const SizedBox(height: 24),
            Text(
              'You can always turn it off in permissions settings.\n\nYour audio is transcribed in the cloud then automatically deleted. We store and use the transcripts as described in our Privacy Notice.',
              textAlign: TextAlign.center,
              style: AppTypography.label.copyWith(
                color: AppColors.neutralGold.withValues(alpha: 0.7),
                fontSize: 10,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
