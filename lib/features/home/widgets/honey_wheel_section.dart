import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/responsive.dart';

class HoneyWheelSection extends StatefulWidget {
  const HoneyWheelSection({super.key});

  @override
  State<HoneyWheelSection> createState() => _HoneyWheelSectionState();
}

class _HoneyWheelSectionState extends State<HoneyWheelSection>
    with TickerProviderStateMixin {
  int _active = 0;
  late final AnimationController _spinCtrl;
  late final AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  static const _profiles = [
    _HoneyProfile(
        'Floral & Light',
        '🌸',
        Color(0xFFEEBD2B),
        'Chamomile • Vanilla • White Iris',
        'Delicate and airy with a luminous golden hue. Soft, nectar-like sweetness that fades into lingering botanical finishes.'),
    _HoneyProfile(
        'Woody & Aromatic',
        '🌲',
        Color(0xFF9A7020),
        'Pine Resin • Molasses • Leather',
        'Deep amber, harvested from high-elevation forests. Complex, resinous viscosity with malty undertones.'),
    _HoneyProfile(
        'Earthy & Herbaceous',
        '🌿',
        Color(0xFF6B8040),
        'Wild Thyme • Mineral • Sage',
        'A wild, untamed terroir profile. Rich with mineral complexities and a mildly savory edge.'),
  ];

  @override
  void initState() {
    super.initState();
    _spinCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    Future.delayed(const Duration(milliseconds: 4500), () {
      if (!mounted) return;
      _switchTo((_active + 1) % _profiles.length);
      _startAutoPlay();
    });
  }

  void _switchTo(int index) {
    _fadeCtrl.reverse().then((_) {
      if (!mounted) return;
      setState(() => _active = index);
      _fadeCtrl.forward();
    });
  }

  @override
  void dispose() {
    _spinCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profiles[_active];
    final wheelSize = R.w(context, 220);
    final hubSize = R.w(context, 100);

    return Container(
      color: const Color(0xFF1A2820),
      padding: EdgeInsets.all(R.w(context, 20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('EDUCATION',
              style: AppTypography.label(context).copyWith(
                  color: AppColors.primary,
                  fontSize: R.sp(context, 9),
                  letterSpacing: 2.5,
                  fontWeight: FontWeight.w900)),
          SizedBox(height: R.h(context, 5)),
          Text("The Honey Taster's Wheel",
              style: AppTypography.h2(context).copyWith(
                  color: Colors.white,
                  fontSize: R.sp(context, 19),
                  height: 1.1)),
          SizedBox(height: R.h(context, 6)),
          Text(
            'Like fine wine, honey has complex aromatic compounds. Use our guide to identify the nuances in our artisanal selection.',
            style: AppTypography.bodySM(context).copyWith(
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: R.sp(context, 11),
                height: 1.5),
          ),
          SizedBox(height: R.h(context, 20)),
          // Interactive wheel
          Center(
            child: GestureDetector(
              onTap: () => _switchTo((_active + 1) % _profiles.length),
              child: SizedBox(
                width: wheelSize,
                height: wheelSize,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Spinning dashed ring
                    AnimatedBuilder(
                      animation: _spinCtrl,
                      builder: (_, __) => Transform.rotate(
                        angle: _spinCtrl.value * 2 * 3.14159,
                        child: Container(
                          width: wheelSize,
                          height: wheelSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.2),
                                width: 1),
                          ),
                        ),
                      ),
                    ),
                    // Color segmented ring
                    CustomPaint(
                      size: Size(wheelSize * 0.87, wheelSize * 0.87),
                      painter: _WheelPainter(
                          activeIndex: _active, profiles: _profiles),
                    ),
                    // Center hub
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: Container(
                        width: hubSize,
                        height: hubSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF1A2820),
                          border: Border.all(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? AppColors.surfaceDark
                                  : Colors.white.withValues(alpha: 0.15),
                              width: 1.5),
                          boxShadow: [
                            BoxShadow(
                                color: profile.color.withValues(alpha: 0.4),
                                blurRadius: 40,
                                spreadRadius: -5)
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(profile.emoji,
                                style: TextStyle(fontSize: R.sp(context, 22))),
                            SizedBox(height: R.h(context, 4)),
                            ...profile.notes.split(' • ').map((n) => Padding(
                                  padding:
                                      EdgeInsets.only(bottom: R.h(context, 2)),
                                  child: Text(
                                    n.toUpperCase(),
                                    style: TextStyle(
                                        color: profile.color,
                                        fontSize: R.sp(context, 7),
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.5,
                                        height: 1.1),
                                    textAlign: TextAlign.center,
                                  ),
                                )),
                            SizedBox(height: R.h(context, 2)),
                            Text('PROFILE',
                                style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    fontSize: R.sp(context, 6.5),
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 2.0)),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      child: Icon(Icons.keyboard_arrow_down,
                          color: AppColors.primary, size: R.sp(context, 18)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: R.h(context, 20)),
          // Profile selector list
          ...List.generate(_profiles.length, (i) {
            final p = _profiles[i];
            final isActive = _active == i;
            return GestureDetector(
              onTap: () => _switchTo(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: EdgeInsets.only(bottom: R.h(context, 8)),
                padding: EdgeInsets.all(R.w(context, 12)),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(R.w(context, 12)),
                  border: Border.all(
                    color: isActive
                        ? AppColors.primary.withValues(alpha: 0.5)
                        : Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: R.w(context, 9),
                      height: R.w(context, 9),
                      margin: EdgeInsets.only(top: R.h(context, 3)),
                      decoration:
                          BoxDecoration(color: p.color, shape: BoxShape.circle),
                    ),
                    SizedBox(width: R.w(context, 10)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.name,
                              style: AppTypography.label(context).copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: R.sp(context, 11))),
                          if (isActive) ...[
                            SizedBox(height: R.h(context, 3)),
                            Text(p.desc,
                                style: AppTypography.bodySM(context).copyWith(
                                    color: Colors.white.withValues(alpha: 0.55),
                                    fontSize: R.sp(context, 11),
                                    height: 1.4)),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          SizedBox(height: R.h(context, 12)),
          GestureDetector(
            onTap: () => context.push('/journal/honey-tasters-guide'),
            child: Row(
              children: [
                Text('Explore Full Tasting Guide',
                    style: AppTypography.label(context).copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: R.sp(context, 11))),
                SizedBox(width: R.w(context, 6)),
                Icon(Icons.arrow_forward,
                    color: AppColors.primary, size: R.sp(context, 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HoneyProfile {
  final String name;
  final String emoji;
  final Color color;
  final String notes;
  final String desc;
  const _HoneyProfile(this.name, this.emoji, this.color, this.notes, this.desc);
}

class _WheelPainter extends CustomPainter {
  final int activeIndex;
  final List<_HoneyProfile> profiles;

  _WheelPainter({required this.activeIndex, required this.profiles});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerR = size.width / 2;
    const innerR = 52.0; // Center hole radius
    const sweepAngle = 2 * math.pi / 3; // 120 degrees per segment

    for (int i = 0; i < profiles.length; i++) {
      // Start at top (-90 degrees)
      final startAngle = -math.pi / 2 + i * sweepAngle;

      // Draw the colored segment
      final paint = Paint()
        ..color =
            profiles[i].color.withValues(alpha: activeIndex == i ? 1.0 : 0.4)
        ..style = PaintingStyle.fill;

      final path = Path()
        ..moveTo(center.dx + innerR * math.cos(startAngle),
            center.dy + innerR * math.sin(startAngle))
        ..lineTo(center.dx + outerR * math.cos(startAngle),
            center.dy + outerR * math.sin(startAngle))
        ..arcTo(Rect.fromCircle(center: center, radius: outerR), startAngle,
            sweepAngle, false)
        ..lineTo(center.dx + innerR * math.cos(startAngle + sweepAngle),
            center.dy + innerR * math.sin(startAngle + sweepAngle))
        ..arcTo(Rect.fromCircle(center: center, radius: innerR),
            startAngle + sweepAngle, -sweepAngle, false)
        ..close();

      canvas.drawPath(path, paint);

      // Draw the divider line between segments
      final divPaint = Paint()
        ..color = const Color(0xFF1A2820) // Match background color
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        Offset(center.dx + innerR * math.cos(startAngle),
            center.dy + innerR * math.sin(startAngle)),
        Offset(center.dx + outerR * math.cos(startAngle),
            center.dy + outerR * math.sin(startAngle)),
        divPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_WheelPainter old) => old.activeIndex != activeIndex;
}
