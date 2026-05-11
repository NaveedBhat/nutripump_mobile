import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../providers/providers.dart';

class ThemeSelectionTile extends ConsumerWidget {
  const ThemeSelectionTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    String modeName = 'System';
    IconData modeIcon = Icons.brightness_auto_rounded;
    if (themeMode == ThemeMode.light) {
      modeName = 'Light';
      modeIcon = Icons.light_mode_rounded;
    } else if (themeMode == ThemeMode.dark) {
      modeName = 'Dark';
      modeIcon = Icons.dark_mode_rounded;
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: R.w(context, 16)),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.surfaceDark
              : Colors.white,
          borderRadius: BorderRadius.circular(R.w(context, 12)),
        ),
        child: InkWell(
          onTap: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                      top: Radius.circular(R.w(context, 20)))),
              builder: (ctx) => const _ThemeSelectionSheet(),
            );
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: R.w(context, 16), vertical: R.h(context, 12)),
            child: Row(
              children: [
                Container(
                  width: R.w(context, 34),
                  height: R.w(context, 34),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(R.w(context, 8)),
                  ),
                  child: Icon(Icons.color_lens_outlined,
                      size: R.sp(context, 16), color: AppColors.primary),
                ),
                SizedBox(width: R.w(context, 12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Appearance',
                        style: AppTypography.bodySM(context).copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: R.sp(context, 13),
                        ),
                      ),
                      SizedBox(height: R.h(context, 1)),
                      Text(
                        'Customize your visual experience',
                        style: AppTypography.labelGold(context).copyWith(
                          fontSize: R.sp(context, 10),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: R.w(context, 8), vertical: R.h(context, 4)),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .outline
                        .withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(R.w(context, 6)),
                  ),
                  child: Row(
                    children: [
                      Icon(modeIcon,
                          size: R.sp(context, 12),
                          color:
                              (Theme.of(context).brightness == Brightness.dark
                                  ? Theme.of(context).colorScheme.onSurface
                                  : AppColors.deepCharcoal)),
                      SizedBox(width: R.w(context, 4)),
                      Text(
                        modeName,
                        style: AppTypography.bodySM(context).copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: R.sp(context, 10),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: R.w(context, 8)),
                Icon(Icons.chevron_right_rounded,
                    color: Theme.of(context).colorScheme.outline,
                    size: R.sp(context, 18)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemeSelectionSheet extends ConsumerWidget {
  const _ThemeSelectionSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(R.w(context, 20), R.h(context, 20),
            R.w(context, 20), R.h(context, 16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Appearance',
                style: AppTypography.h3(context)
                    .copyWith(fontSize: R.sp(context, 18))),
            SizedBox(height: R.h(context, 4)),
            Text('Choose how NutriPump looks to you.',
                style: AppTypography.bodySM(context)
                    .copyWith(color: AppColors.neutralGold)),
            SizedBox(height: R.h(context, 24)),
            _ThemeOption(
              icon: Icons.brightness_auto_rounded,
              label: 'System Default',
              isSelected: themeMode == ThemeMode.system,
              onTap: () {
                ref.read(themeProvider.notifier).setTheme(ThemeMode.system);
                Navigator.pop(context);
              },
            ),
            const Divider(height: 1),
            _ThemeOption(
              icon: Icons.light_mode_rounded,
              label: 'Light Mode',
              isSelected: themeMode == ThemeMode.light,
              onTap: () {
                ref.read(themeProvider.notifier).setTheme(ThemeMode.light);
                Navigator.pop(context);
              },
            ),
            const Divider(height: 1),
            _ThemeOption(
              icon: Icons.dark_mode_rounded,
              label: 'Dark Mode',
              isSelected: themeMode == ThemeMode.dark,
              onTap: () {
                ref.read(themeProvider.notifier).setTheme(ThemeMode.dark);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: R.h(context, 16)),
        child: Row(
          children: [
            Icon(icon,
                color: isSelected
                    ? AppColors.primary
                    : (Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(context).colorScheme.onSurface
                        : AppColors.deepCharcoal),
                size: R.sp(context, 20)),
            SizedBox(width: R.w(context, 16)),
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodySM(context).copyWith(
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected
                      ? AppColors.primary
                      : (Theme.of(context).brightness == Brightness.dark
                          ? Theme.of(context).colorScheme.onSurface
                          : AppColors.deepCharcoal),
                  fontSize: R.sp(context, 14),
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded,
                  color: AppColors.primary, size: R.sp(context, 20)),
          ],
        ),
      ),
    );
  }
}
