import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/utils/responsive.dart';
import '../../services/legal_service.dart';

const Map<String, IconData> legalIconMap = {
  'shield': Icons.shield_outlined,
  'eye': Icons.visibility_outlined,
  'share': Icons.share_outlined,
  'lock': Icons.lock_outline_rounded,
  'cookie': Icons.cookie_outlined,
  'tune': Icons.tune_outlined,
  'child': Icons.child_care_outlined,
  'update': Icons.update_outlined,
  'handshake': Icons.handshake_outlined,
  'person': Icons.person_outline_rounded,
  'cart': Icons.shopping_cart_outlined,
  'truck': Icons.local_shipping_outlined,
  'undo': Icons.undo_rounded,
  'copyright': Icons.copyright_outlined,
  'warning': Icons.warning_amber_outlined,
  'block': Icons.block_outlined,
  'balance': Icons.balance_outlined,
  'link': Icons.link_outlined,
};

/// Shared widget for legal screens (Privacy Policy & Terms).
class LegalSectionWidget extends StatelessWidget {
  final LegalSection section;
  final int index;
  const LegalSectionWidget(
      {super.key, required this.section, required this.index});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(R.w(context, 16), 0, R.w(context, 16), R.h(context, 20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Container(
                width: R.w(context, 36),
                height: R.w(context, 36),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(R.w(context, 10)),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.15)),
                ),
                child:
                    Icon(legalIconMap[section.icon] ?? Icons.shield_outlined, color: AppColors.primary, size: R.sp(context, 17)),
              ),
              SizedBox(width: R.w(context, 12)),
              Text(
                index.toString().padLeft(2, '0'),
                style: AppTypography.label(context).copyWith(
                  color: AppColors.neutralGold,
                  fontSize: R.sp(context, 10),
                  fontFamily: 'monospace',
                ),
              ),
              SizedBox(width: R.w(context, 6)),
              Expanded(
                child: Text(
                  section.title,
                  style: AppTypography.h3(context).copyWith(fontSize: R.sp(context, 16)),
                ),
              ),
            ],
          ),
          SizedBox(height: R.h(context, 12)),
          // Items
          ...section.items.map((item) => Padding(
                padding: EdgeInsets.only(bottom: R.h(context, 8)),
                child: Container(
                  padding: EdgeInsets.all(R.w(context, 15)),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(R.w(context, 12)),
                    border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? AppColors.borderDark : AppColors.borderLight),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.subtitle,
                        style: AppTypography.bodySM(context).copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: R.sp(context, 13),
                          color: (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.onSurface : AppColors.deepCharcoal),
                        ),
                      ),
                      SizedBox(height: R.h(context, 5)),
                      Text(
                        item.text,
                        style: AppTypography.bodySM(context).copyWith(
                          fontSize: R.sp(context, 12.5),
                          height: 1.65,
                          color: (Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.onSurface : AppColors.deepCharcoal)
                              .withValues(alpha: 0.65),
                        ),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
