import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/providers.dart';
import '../../../core/constants/app_typography.dart';

class AnnouncementBar extends ConsumerStatefulWidget {
  const AnnouncementBar({super.key});

  @override
  ConsumerState<AnnouncementBar> createState() => _AnnouncementBarState();
}

class _AnnouncementBarState extends ConsumerState<AnnouncementBar> {
  bool _isVisible = true;

  Color _parseColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    final announcementAsync = ref.watch(announcementProvider);

    return announcementAsync.when(
      data: (settings) {
        if (!settings.activeMobile) return const SizedBox.shrink();

        Color bgColor;
        Color textColor;
        try {
          bgColor = _parseColor(settings.bgColor);
          textColor = _parseColor(settings.textColor);
        } catch (_) {
          bgColor = const Color(0xFF1F1F1F);
          textColor = const Color(0xFFEBD177);
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          color: bgColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  settings.text,
                  textAlign: TextAlign.center,
                  style: AppTypography.label.copyWith(
                    color: textColor,
                    fontSize: 10,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                child: GestureDetector(
                  onTap: () => setState(() => _isVisible = false),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.close,
                      size: 14,
                      color: textColor.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
