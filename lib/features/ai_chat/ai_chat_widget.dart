import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive.dart';
import 'ai_chat_sheet.dart';

class AiChatWidget extends StatefulWidget {
  const AiChatWidget({super.key});

  @override
  State<AiChatWidget> createState() => _AiChatWidgetState();
}

class _AiChatWidgetState extends State<AiChatWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _ringController;
  late AnimationController _spinController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _ringAnimation;
  late Animation<double> _ringOpacity;
  late Animation<double> _spinAnimation;

  bool _isOpen = false;
  bool _showRings = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Orbital ring: fires every 8s
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _ringAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _ringController, curve: Curves.easeOut),
    );
    _ringOpacity = Tween<double>(begin: 0.7, end: 0.0).animate(
      CurvedAnimation(parent: _ringController, curve: Curves.easeOut),
    );

    // Logo spin: fires every 12s
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _spinAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _spinController, curve: Curves.easeInOut),
    );

    // Schedule the attention animations
    _scheduleAttentionAnimations();
  }

  void _scheduleAttentionAnimations() {
    Future.delayed(const Duration(seconds: 3), _playRings);
    Future.delayed(const Duration(seconds: 6), _spinLogo);
  }

  Future<void> _playRings() async {
    if (_isOpen || !mounted) return;
    setState(() => _showRings = true);
    await _ringController.forward(from: 0);
    if (mounted) setState(() => _showRings = false);
    // Repeat every 8s
    Future.delayed(const Duration(seconds: 8), _playRings);
  }

  Future<void> _spinLogo() async {
    if (_isOpen || !mounted) return;
    await _spinController.forward(from: 0);
    // Repeat every 12s
    Future.delayed(const Duration(seconds: 12), _spinLogo);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _ringController.dispose();
    _spinController.dispose();
    super.dispose();
  }

  void _toggleChat() {
    setState(() {
      _isOpen = !_isOpen;
      _showRings = false;
      if (_isOpen) {
        _pulseController.stop();
      } else {
        _pulseController.repeat(reverse: true);
        _scheduleAttentionAnimations();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Hide FAB when keyboard is open and chat is closed (matches web behavior)
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Stack(
      children: [
        // Backdrop
        if (_isOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggleChat,
              behavior: HitTestBehavior.opaque,
              child: Container(color: Colors.transparent),
            ),
          ),

        // Chat Sheet
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          bottom: _isOpen ? 0 : -20,
          left: 0,
          right: 0,
          child: IgnorePointer(
            ignoring: !_isOpen,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _isOpen ? 1.0 : 0.0,
              child: AiChatSheet(
                onClose: _toggleChat,
                isOpen: _isOpen,
              ),
            ),
          ),
        ),

        // Floating Action Button
        Positioned(
          right: R.w(context, 16),
          bottom: R.h(context, 16),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: (keyboardOpen && !_isOpen) ? 0.0 : 1.0,
            child: IgnorePointer(
              ignoring: keyboardOpen && !_isOpen,
              child: SizedBox(
                width: R.w(context, 56),
                height: R.w(context, 56),
                child: AnimatedBuilder(
                  animation: Listenable.merge(
                      [_scaleAnimation, _ringAnimation, _spinAnimation]),
                  builder: (context, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        // Orbital ring 1 (large pulse)
                        if (_showRings)
                          Transform.scale(
                            scale: _ringAnimation.value,
                            child: Opacity(
                              opacity: _ringOpacity.value,
                              child: Container(
                                width: R.w(context, 56),
                                height: R.w(context, 56),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: AppColors.primary, width: 2),
                                ),
                              ),
                            ),
                          ),
                        // Orbital ring 2 (smaller, staggered)
                        if (_showRings)
                          Transform.scale(
                            scale: _ringAnimation.value * 0.85,
                            child: Opacity(
                              opacity: _ringOpacity.value * 0.5,
                              child: Container(
                                width: R.w(context, 56),
                                height: R.w(context, 56),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.5),
                                    width: 1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        // FAB button
                        Transform.scale(
                          scale: _isOpen ? 1.0 : _scaleAnimation.value,
                          child: GestureDetector(
                            onTap: _toggleChat,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: R.w(context, 56),
                              height: R.w(context, 56),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: AppColors.primary, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(
                                        alpha: _isOpen ? 0.15 : 0.45),
                                    blurRadius: _isOpen ? 10 : 20,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                transitionBuilder: (Widget child,
                                    Animation<double> animation) {
                                  return RotationTransition(
                                    turns: child.key == const ValueKey('icon')
                                        ? Tween<double>(begin: 0.5, end: 1.0)
                                            .animate(animation)
                                        : Tween<double>(begin: 0.0, end: 0.5)
                                            .animate(animation),
                                    child: FadeTransition(
                                        opacity: animation, child: child),
                                  );
                                },
                                child: _isOpen
                                    ? Icon(
                                        Icons.keyboard_arrow_up_rounded,
                                        key: const ValueKey('icon'),
                                        color: AppColors.primary,
                                        size: R.sp(context, 28),
                                      )
                                    : Padding(
                                        key: const ValueKey('image'),
                                        padding:
                                            EdgeInsets.all(R.w(context, 8)),
                                        child: Transform.rotate(
                                          angle: 3.14159 + _spinAnimation.value,
                                          child: Image.asset(
                                            'assets/images/chatbotlogo.webp',
                                            gaplessPlayback: true,
                                            errorBuilder: (context, error,
                                                    stackTrace) =>
                                                const Icon(
                                                    Icons.support_agent_rounded,
                                                    color: AppColors.primary),
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
