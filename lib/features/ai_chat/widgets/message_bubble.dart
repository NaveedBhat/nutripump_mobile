import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../services/api/ai_api.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/responsive.dart';
import 'chat_product_card.dart';

class MessageBubble extends StatelessWidget {
  final AiChatMessage message;
  final VoidCallback? onClose;

  const MessageBubble({super.key, required this.message, this.onClose});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';

    return Padding(
      padding: EdgeInsets.only(bottom: R.h(context, 12)),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.85,
            ),
            padding: EdgeInsets.symmetric(horizontal: R.w(context, 14), vertical: R.h(context, 10)),
            decoration: BoxDecoration(
              color: isUser ? AppColors.primary : Colors.white,
              border:
                  isUser ? null : Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(R.w(context, 16)),
                topRight: Radius.circular(R.w(context, 16)),
                bottomLeft: Radius.circular(isUser ? R.w(context, 16) : R.w(context, 4)),
                bottomRight: Radius.circular(isUser ? R.w(context, 4) : R.w(context, 16)),
              ),
            ),
            child: Text(
              message.text,
              style: AppTypography.bodySM(context).copyWith(
                color: AppColors.deepCharcoal,
                fontWeight: isUser ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
          if (!isUser && message.products != null && message.products!.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: R.h(context, 8)),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.85,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...message.products!.take(4).map((product) =>
                        ChatProductCard(product: product, onClose: onClose)),
                    if (message.products!.length > 4)
                      Center(
                        child: TextButton(
                          onPressed: () {
                            if (onClose != null) onClose!();
                            context.push('/shop');
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: R.h(context, 4)),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'View ${message.products!.length - 4} more →',
                            style: AppTypography.label(context).copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: R.sp(context, 11),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: R.h(context, 12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: R.w(context, 16), vertical: R.h(context, 12)),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(R.w(context, 16)),
                topRight: Radius.circular(R.w(context, 16)),
                bottomLeft: Radius.circular(R.w(context, 4)),
                bottomRight: Radius.circular(R.w(context, 16)),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                return AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final delay = index * 0.2;
                    final progress = (_controller.value - delay) % 1.0;
                    final offset = progress < 0 || progress > 0.6
                        ? 0.0
                        : (progress < 0.3 ? -3.0 * (progress / 0.3) : -3.0 * (1 - ((progress - 0.3) / 0.3)));
                    return Transform.translate(
                      offset: Offset(0, offset),
                      child: Container(
                        margin: EdgeInsets.only(right: index < 2 ? R.w(context, 4) : 0),
                        width: R.w(context, 6),
                        height: R.w(context, 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
