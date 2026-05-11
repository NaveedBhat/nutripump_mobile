import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/responsive.dart';

class TrustStrip extends StatefulWidget {
  const TrustStrip({super.key});

  @override
  State<TrustStrip> createState() => _TrustStripState();
}

class _TrustStripState extends State<TrustStrip>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final ScrollController _scrollController = ScrollController();
  Duration _lastElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      final delta = (elapsed - _lastElapsed).inMilliseconds;
      _lastElapsed = elapsed;
      if (_scrollController.hasClients && delta > 0) {
        // Adjust 35.0 to control speed (pixels per second)
        _scrollController
            .jumpTo(_scrollController.offset + (35.0 * delta / 1000.0));
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _ticker.start();
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.local_shipping_outlined, 'Free Ship ₹499+'),
      (Icons.eco_outlined, '100% Natural'),
      (Icons.location_on_outlined, 'From Kashmir'),
      (Icons.verified_outlined, 'Lab Tested'),
    ];

    return Container(
      color: Theme.of(context).brightness == Brightness.dark
          ? AppColors.surfaceDark
          : Colors.white,
      height: R.h(context, 38),
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final item = items[index % items.length];
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: R.w(context, 14)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(item.$1,
                    size: R.sp(context, 13), color: AppColors.primary),
                SizedBox(width: R.w(context, 6)),
                Text(
                  item.$2,
                  style: AppTypography.label(context).copyWith(
                    fontSize: R.sp(context, 10),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                SizedBox(width: R.w(context, 28)),
                Container(
                    width: 1,
                    height: R.h(context, 11),
                    color: AppColors.borderLight),
              ],
            ),
          );
        },
      ),
    );
  }
}
