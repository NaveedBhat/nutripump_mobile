import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/responsive.dart';

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
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.surfaceDark
            : Colors.white,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(R.w(context, 24))),
      ),
      padding: EdgeInsets.symmetric(
          horizontal: R.w(context, 24), vertical: R.h(context, 20)),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(Icons.close,
                    color: (Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(context).colorScheme.onSurface
                        : AppColors.deepCharcoal)),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            SizedBox(height: R.h(context, 8)),
            if (_isListening)
              Container(
                padding: EdgeInsets.all(R.w(context, 24)),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.mic,
                        size: R.sp(context, 48), color: AppColors.primary)
                    .animate(
                        onPlay: (controller) =>
                            controller.repeat(reverse: true))
                    .scaleXY(
                        begin: 1.0,
                        end: 1.2,
                        duration: 800.ms,
                        curve: Curves.easeInOut),
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
                  padding: EdgeInsets.all(R.w(context, 24)),
                  decoration: BoxDecoration(
                    color: AppColors.borderLight.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.mic_none,
                      size: R.sp(context, 48),
                      color: (Theme.of(context).brightness == Brightness.dark
                          ? Theme.of(context).colorScheme.onSurface
                          : AppColors.deepCharcoal)),
                ),
              ),
            SizedBox(height: R.h(context, 24)),
            Text(
              _isListening ? 'Listening...' : 'Shop faster with voice',
              style: AppTypography.h2(context)
                  .copyWith(fontSize: R.sp(context, 22)),
            ),
            SizedBox(height: R.h(context, 8)),
            if (_text.isNotEmpty && _isListening)
              Text(
                '"$_text"',
                style: AppTypography.body(context).copyWith(
                    fontStyle: FontStyle.italic, color: AppColors.neutralGold),
                textAlign: TextAlign.center,
              )
            else if (_hasSpeechError)
              Text(
                'Could not understand. Tap microphone to try again.',
                style: AppTypography.bodySM(context)
                    .copyWith(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
            SizedBox(height: R.h(context, 32)),
            if (!_permissionStatus.isGranted)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _requestPermission,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: R.h(context, 16)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(R.w(context, 12))),
                    elevation: 0,
                  ),
                  child: Text(
                    _permissionStatus.isPermanentlyDenied
                        ? 'Open Settings'
                        : 'Turn on microphone',
                    style: AppTypography.label(context).copyWith(
                        color: (Theme.of(context).brightness == Brightness.dark
                            ? Theme.of(context).colorScheme.onSurface
                            : AppColors.deepCharcoal),
                        fontWeight: FontWeight.w800,
                        fontSize: R.sp(context, 14)),
                  ),
                ),
              ),
            if (!_permissionStatus.isGranted)
              SizedBox(height: R.h(context, 24)),
            Text(
              'You can always turn it off in permissions settings.\n\nYour audio is transcribed in the cloud then automatically deleted. We store and use the transcripts as described in our Privacy Notice.',
              textAlign: TextAlign.center,
              style: AppTypography.label(context).copyWith(
                color: AppColors.neutralGold.withValues(alpha: 0.7),
                fontSize: R.sp(context, 10),
                height: 1.5,
              ),
            ),
            SizedBox(height: R.h(context, 12)),
          ],
        ),
      ),
    );
  }
}
