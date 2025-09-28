import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:our_bung_play/shared/sp_svg.dart';
import 'package:our_bung_play/shared/themes/f_colors.dart';
import 'package:our_bung_play/shared/themes/f_font_styles.dart';

class FSearchChips extends StatelessWidget {
  final String label;
  final String? iconPath;
  final double radius;
  final Color? color;
  final Color? fontColor;
  final GestureTapCallback? onTap;

  const FSearchChips({
    super.key,
    required this.label,
    this.iconPath,
    this.radius = 20,
    this.color,
    this.fontColor,
    this.onTap,
  });

  Color _getFontColor(BuildContext context) {
    return fontColor ?? FColors.of(context).labelStrong;
  }

  Color _getBackgroundColor(BuildContext context) {
    return color ?? FColors.of(context).backgroundNormalN;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: _getBackgroundColor(context),
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: FTextStyles.bodyL.m.copyWith(
                color: _getFontColor(context),
              ),
            ),
            if (iconPath != null) ...[
              const Gap(4),
              SPSvg.asset(
                iconPath!,
                width: 16,
                height: 16,
                color: _getFontColor(context),
              )
            ],
          ],
        ),
      ),
    );
  }
}
