import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../services/api/ai_api.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import 'widgets/message_bubble.dart';

class AiChatSheet extends StatefulWidget {
  final VoidCallback onClose;
  final bool isOpen;

  const AiChatSheet({super.key, required this.onClose, required this.isOpen});

  @override
  State<AiChatSheet> createState() => _AiChatSheetState();
}

class _AiChatSheetState extends State<AiChatSheet> {
  final AiApi _api = AiApi();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  // ── Voice input ──────────────────────────────────────────────────────────
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechAvailable = false;
  bool _isListening = false;

  bool _isLoading = false;
  final List<AiChatMessage> _messages = [];

  final List<String> _suggestedQueries = [
    "Best for immunity 🍯",
    "High protein snacks 💪",
    "Natural energy food ⚡",
    "Pumpkin seed butter 🌿",
    "Kashmiri honey 🐝",
  ];

  @override
  void initState() {
    super.initState();
    _messages.add(
      AiChatMessage(
        role: 'assistant',
        text: 'Assalamu Alaikum! 👋 I\'m NutriPump AI, your personal guide to Kashmir\'s finest artisanal products. Ask me anything — try: "best for weight gain" or "which honey is best".',
        timestamp: DateTime.now(),
      ),
    );
  }

  Future<void> _startListening() async {
    if (!_speechAvailable) {
      _speechAvailable = await _speech.initialize(
        onError: (e) => debugPrint('[STT] Error: $e'),
        onStatus: (status) {
          // Auto-stop the UI indicator when the engine goes idle
          if (status == stt.SpeechToText.doneStatus ||
              status == stt.SpeechToText.notListeningStatus) {
            if (mounted) setState(() => _isListening = false);
          }
        },
      );
    }

    if (!_speechAvailable) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Microphone permission required', style: AppTypography.bodySM(context).copyWith(color: Colors.white)),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }
    _focusNode.unfocus();
    setState(() => _isListening = true);
    await _speech.listen(
      onResult: (result) {
        setState(() {
          _textController.text = result.recognizedWords;
          _textController.selection = TextSelection.fromPosition(
            TextPosition(offset: _textController.text.length),
          );
        });
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      localeId: 'en_IN',
      listenOptions: stt.SpeechListenOptions(
        listenMode: stt.ListenMode.dictation,
        cancelOnError: true,
      ),
    );
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);
  }

  @override
  void didUpdateWidget(AiChatSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOpen && !oldWidget.isOpen) {
      // Optional: Auto-focus the input field when the chat opens
      /* 
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && widget.isOpen) {
          _focusNode.requestFocus();
        }
      });
      */
    } else if (!widget.isOpen && oldWidget.isOpen) {
      _focusNode.unfocus();
    }
  }

  @override
  void dispose() {
    _speech.stop();
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendSuggestedQuery(String q) {
    // Strip emojis for the API call (matches web behavior)
    final clean = q.replaceAll(RegExp(r'[^\w\s]'), '').trim();
    _sendMessage(clean);
  }

  Future<void> _sendMessage([String? text]) async {
    final query = text ?? _textController.text;
    if (query.trim().isEmpty || _isLoading) return;

    if (text == null) {
      _textController.clear();
    }

    setState(() {
      _messages.add(
        AiChatMessage(
          role: 'user',
          text: query.trim(),
          timestamp: DateTime.now(),
        ),
      );
      _isLoading = true;
    });

    // Need to ensure the UI updates before scrolling
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    try {
      final response = await _api.sendMessage(query.trim());
      
      setState(() {
        _messages.add(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(
          AiChatMessage(
            role: 'assistant',
            text: "I'm having a moment — please try again shortly. You can also browse our shop directly!",
            timestamp: DateTime.now(),
          ),
        );
        _isLoading = false;
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  Widget build(BuildContext context) {
    // Determine the keyboard height to shift the bottom sheet up
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Container(
      height: screenHeight * 0.6, // Reduced to 60% for a compact, professional look
      margin: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: bottomInset > 0 ? bottomInset + 16 : 90, // Slightly lower float
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15), width: 1.5), // Added sleek border
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15), // Softer shadow
            blurRadius: 40,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22), // slightly smaller to fit inside border
        child: Column(
          children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), // Tighter padding
            decoration: const BoxDecoration(
              color: AppColors.deepCharcoal,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Image.asset(
                          'assets/images/chatbotlogo.webp',
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.support_agent_rounded, size: 20, color: AppColors.deepCharcoal),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('NutriPump AI', style: AppTypography.bodySM(context).copyWith(color: Colors.white, fontWeight: FontWeight.bold, height: 1)),
                        const SizedBox(height: 2),
                        Text('Your Kashmir product guide', style: AppTypography.label(context).copyWith(color: Colors.white.withValues(alpha: 0.5), fontSize: 10)),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  onPressed: widget.onClose,
                  icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          
          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return const TypingIndicator();
                }
                return MessageBubble(
                  message: _messages[index],
                  onClose: widget.onClose,
                );
              },
            ),
          ),

          // Suggested Queries (only show initially)
          if (_messages.length <= 1 && !_isLoading)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
              child: SizedBox(
                width: double.infinity,
                child: Wrap(
                  spacing: 6, // Reduced from 8
                  runSpacing: 6, // Reduced from 8
                  children: _suggestedQueries.map((query) {
                    return ActionChip(
                      label: Text(
                        query,
                        style: AppTypography.label(context).copyWith(
                          color: AppColors.deepCharcoal,
                          fontWeight: FontWeight.w600,
                          fontSize: 10, // Reduced from 11
                        ),
                      ),
                      padding: EdgeInsets.zero,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: -2), // Very tight padding
                      visualDensity: const VisualDensity(horizontal: -4, vertical: -4), // Most compact density
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      side: BorderSide(color: AppColors.primary.withValues(alpha: 0.15), width: 0.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    onPressed: () => _sendSuggestedQuery(query),
                  );
                }).toList(),
              ),
            ),
          ),

          // Input Area
          Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14), // Tighter padding for input
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.primary.withValues(alpha: 0.08))),
            ),
            child: SafeArea(
              top: false,
              bottom: false,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _textController,
                        focusNode: _focusNode,
                        style: AppTypography.bodySM(context),
                        maxLength: 200,
                        maxLines: 1,
                        decoration: InputDecoration(
                          hintText: 'Ask me anything...',
                          hintStyle: AppTypography.bodySM(context).copyWith(color: AppColors.neutralGold.withValues(alpha: 0.5)),
                          border: InputBorder.none,
                          isDense: true,
                          counterText: '', // Hide the character counter UI
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // ── Mic Button ───────────────────────────────────────────
                  GestureDetector(
                    onTap: _isListening ? _stopListening : _startListening,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _isListening
                            ? AppColors.error.withValues(alpha: 0.15)
                            : AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: _isListening
                            ? Border.all(color: AppColors.error.withValues(alpha: 0.4), width: 1.5)
                            : null,
                      ),
                      child: Icon(
                        _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                        color: _isListening ? AppColors.error : AppColors.deepCharcoal,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: (_isLoading || _textController.text.trim().isEmpty)
                      ? null
                      : () => _sendMessage(),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.send_rounded,
                        color: AppColors.deepCharcoal.withValues(alpha: _isLoading ? 0.5 : 1.0),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
