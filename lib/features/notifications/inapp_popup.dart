// lib/features/notifications/inapp_popup.dart
// ─────────────────────────────────────────────────────────────────────────────
// Beautiful animated in-app popup banner.
// Shown as a bottom-sheet style overlay with a spring slide-in animation,
// backdrop blur, rich image, title, body, and a CTA deep-link button.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/responsive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class InAppPopup extends StatefulWidget {
  final String title;
  final String body;
  final String? imageUrl;
  final String? ctaLabel;
  final String? deepLink;
  final String? bgColor;
  final VoidCallback onDismiss;

  const InAppPopup({
    super.key,
    required this.title,
    required this.body,
    this.imageUrl,
    this.ctaLabel,
    this.deepLink,
    this.bgColor,
    required this.onDismiss,
  });

  @override
  State<InAppPopup> createState() => _InAppPopupState();
}

class _InAppPopupState extends State<InAppPopup>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scaleAnim = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _controller.forward();

    // Record that we showed a popup today
    try {
      final box = Hive.box('nutripump_settings');
      box.put('last_impression_date', DateTime.now().toIso8601String());
    } catch (_) {}
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  Color _parseBgColor() {
    final hex = widget.bgColor;
    if (hex == null || hex.isEmpty) return AppColors.deepCharcoal;
    try {
      return Color(int.parse(hex.replaceAll('#', '0xFF')));
    } catch (_) {
      return AppColors.deepCharcoal;
    }
  }

  Widget _buildContent(Color textCol, Color subTextCol) {
    return Padding(
      padding: EdgeInsets.all(R.w(context, 24)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // NutriPump branding pill
          Container(
            margin: EdgeInsets.only(bottom: R.h(context, 12)),
            padding: EdgeInsets.symmetric(
                horizontal: R.w(context, 10), vertical: R.h(context, 4)),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(R.w(context, 20)),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.4),
                width: 0.8,
              ),
            ),
            child: Text(
              'NutriPump',
              style: TextStyle(
                fontFamily: 'Georgia',
                color: AppColors.primary,
                fontSize: R.sp(context, 10),
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),

          Text(
            widget.title,
            style:
                AppTypography.h1(context).copyWith(color: textCol, height: 1.2),
          ),
          SizedBox(height: R.h(context, 8)),
          Text(
            widget.body,
            style: AppTypography.bodySM(context).copyWith(color: subTextCol),
          ),

          // ── CTA Button ──────────────────────────────────
          if (widget.ctaLabel != null && widget.ctaLabel!.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: R.h(context, 20)),
              child: GestureDetector(
                onTap: () {
                  _dismiss();
                  if (widget.deepLink != null && widget.deepLink!.isNotEmpty) {
                    context.push(widget.deepLink!);
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                      vertical: R.h(context, 10), horizontal: R.w(context, 20)),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(R.w(context, 10)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    widget.ctaLabel!,
                    style: AppTypography.label(context).copyWith(
                      color: AppColors.deepCharcoal,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bg = _parseBgColor();
    final isLight = bg.computeLuminance() > 0.4;
    final textCol = isLight ? AppColors.deepCharcoal : Colors.white;
    final subTextCol = isLight
        ? AppColors.deepCharcoal.withValues(alpha: 0.7)
        : Colors.white.withValues(alpha: 0.75);

    return FadeTransition(
      opacity: _fadeAnim,
      child: Material(
        color: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // ── Scrim ─────────────────────────────────────────────────────
            GestureDetector(
              onTap: _dismiss,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.45),
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),

            // ── Card ──────────────────────────────────────────────────────
            ScaleTransition(
              scale: _scaleAnim,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: R.w(context, 28)),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AspectRatio(
                      aspectRatio:
                          0.85, // Enforces a beautiful proportionate height
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(R.w(context, 24)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.35),
                              blurRadius: 40,
                              offset: const Offset(0, 16),
                            ),
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: widget.imageUrl != null &&
                                widget.imageUrl!.isNotEmpty
                            ? Stack(
                                children: [
                                  Positioned.fill(
                                    child: Image.network(
                                      widget.imageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.1),
                                      ),
                                    ),
                                  ),
                                  Positioned.fill(
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                          colors: [
                                            bg,
                                            bg.withValues(alpha: 0.95),
                                            bg.withValues(alpha: 0.6),
                                            Colors.transparent,
                                          ],
                                          stops: const [0.0, 0.35, 0.6, 1.0],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    bottom: 0,
                                    child: _buildContent(textCol, subTextCol),
                                  ),
                                ],
                              )
                            : Align(
                                alignment: Alignment.bottomLeft,
                                child: _buildContent(textCol, subTextCol),
                              ),
                      ),
                    ),

                    // ── Close Button (Half Outside) ─────────────────────────
                    Positioned(
                      top: R.h(context, -16),
                      right: R.w(context, -16),
                      child: GestureDetector(
                        onTap: _dismiss,
                        child: Container(
                          width: R.w(context, 36),
                          height: R.w(context, 36),
                          decoration: BoxDecoration(
                            color: AppColors.deepCharcoal,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: bg,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.close,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? AppColors.surfaceDark
                                    : Colors.white,
                            size: R.sp(context, 18),
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
      ),
    );
  }
}
