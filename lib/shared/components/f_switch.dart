import 'package:flutter/material.dart';
import 'package:our_bung_play/shared/themes/f_colors.dart';

class FSwitch extends StatefulWidget {
  final bool active;
  final ValueChanged<bool> onTap;
  final Color activeColor;
  final Color inactiveColor;
  final Color toggleColor;
  final double? width;
  final double? height;
  final double toggleSize;
  final double borderRadius;
  final bool disabled;
  final Color? activeToggleColor;
  final Color? inactiveToggleColor;
  final double padding;

  const FSwitch({
    super.key,
    required this.active,
    required this.onTap,
    required this.activeColor,
    required this.inactiveColor,
    required this.toggleColor,
    this.width,
    this.height,
    this.toggleSize = 40.0,
    this.borderRadius = 20.0,
    this.disabled = false,
    this.activeToggleColor,
    this.inactiveToggleColor,
    this.padding = 2,
  });

  @override
  _FSwitchState createState() => _FSwitchState();

  // Factory for default type
  factory FSwitch.normal(
    BuildContext context, {
    required bool active,
    required ValueChanged<bool> onTap,
    bool? disabled,
  }) =>
      FSwitch(
        active: active,
        disabled: disabled ?? false,
        onTap: onTap,
        toggleSize: 20,
        width: 42.0,
        height: 24.0,
        activeColor: FColors.of(context).solidStrong,
        inactiveColor: FColors.of(context).solidAlternative,
        toggleColor: FColors.of(context).inverseStrong,
      );

  // Factory for custom type (example)
  factory FSwitch.small(
    BuildContext context, {
    required bool active,
    required ValueChanged<bool> onTap,
    bool? disabled,
  }) =>
      FSwitch(
        active: active,
        disabled: disabled ?? false,
        onTap: onTap,
        toggleSize: 16,
        width: 36.0,
        height: 20.0,
        activeColor: FColors.of(context).solidStrong,
        inactiveColor: FColors.of(context).solidAlternative,
        toggleColor: FColors.of(context).inverseStrong,
      );

// Add more factories as needed for different types
}

class _FSwitchState extends State<FSwitch> {
  Color switchColor() {
    if (widget.disabled) {
      return widget.active ? FColors.of(context).solidNeutral : FColors.of(context).solidAlternative;
    } else {
      return widget.active ? widget.activeColor : widget.inactiveColor;
    }
  }

  Color toggleColor() {
    if (widget.disabled) {
      return widget.active ? FColors.of(context).solidAlternative : FColors.of(context).solidDisable;
    } else {
      return widget.active
          ? (widget.activeToggleColor ?? widget.toggleColor)
          : (widget.inactiveToggleColor ?? widget.toggleColor);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.disabled) return;
        widget.onTap(!widget.active);
      },
      child: Container(
        width: widget.width,
        height: widget.height,
        padding: EdgeInsets.all(widget.padding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          color: switchColor(),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 150),
          alignment: widget.active ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: widget.toggleSize,
            height: widget.toggleSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: toggleColor(),
            ),
          ),
        ),
      ),
    );
  }
}
