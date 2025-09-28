import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:our_bung_play/generated/assets.dart';
import 'package:our_bung_play/shared/sp_svg.dart';
import 'package:our_bung_play/shared/themes/f_colors.dart';
import 'package:our_bung_play/shared/themes/f_font_styles.dart';

enum FSortDropdownType { normal, small }

class FSortDropdown extends StatelessWidget {
  const FSortDropdown._({
    required this.label,
    required this.type,
    this.onTap,
  });

  factory FSortDropdown.normal({
    required String label,
    VoidCallback? onTap,
  }) {
    return FSortDropdown._(
      label: label,
      onTap: onTap,
      type: FSortDropdownType.normal,
    );
  }

  factory FSortDropdown.small({
    required String label,
    VoidCallback? onTap,
  }) {
    return FSortDropdown._(
      label: label,
      onTap: onTap,
      type: FSortDropdownType.small,
    );
  }

  final String label;
  final VoidCallback? onTap;
  final FSortDropdownType type;

  TextStyle _textStyle(BuildContext context) {
    switch (type) {
      case FSortDropdownType.normal:
        return FTextStyles.bodyL.b.copyWith(
          color: FColors.of(context).solidStrong,
        );
      case FSortDropdownType.small:
        return FTextStyles.bodyM.r.copyWith(
          color: FColors.of(context).solidStrong,
        );
    }
  }

  String get _iconAsset {
    switch (type) {
      case FSortDropdownType.normal:
        return Assets.iconsNormalChevronDownSmallThick;
      case FSortDropdownType.small:
        return Assets.iconsNormalChevronDownNormalThin;
    }
  }

  double get _gap {
    switch (type) {
      case FSortDropdownType.normal:
        return 4;
      case FSortDropdownType.small:
        return 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap?.call(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Text(
              label,
              style: _textStyle(context),
            ),
            Gap(_gap),
            SPSvg.asset(
              _iconAsset,
              width: 16,
              height: 16,
              color: FColors.of(context).labelAlternative,
            ),
          ],
        ),
      ),
    );
  }
}
