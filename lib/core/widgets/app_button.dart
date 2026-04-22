import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../themes/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Types
// ─────────────────────────────────────────────────────────────────────────────

enum AppButtonType {
  primary,
  secondary,
  outlined,
  text,
  danger,
  ghost,
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget
// ─────────────────────────────────────────────────────────────────────────────

class AppButton extends StatefulWidget {
  const AppButton({
    required this.text,
    required this.onPressed,
    super.key,
    this.type = AppButtonType.primary,
    this.isLoading = false,
    this.icon,
    this.svgIcon,
    this.useSvgColor = true,
    this.width,
    this.height = 52,
    this.color,
    this.textColor,
    this.borderColor,
    this.borderRadius = 14,
    this.fontSize,
    this.fontWeight,
    this.padding,
  });

  const AppButton.primary({
    required this.text,
    required this.onPressed,
    super.key,
    this.isLoading = false,
    this.icon,
    this.svgIcon,
    this.useSvgColor = true,
    this.width = double.infinity,
    this.height = 52,
    this.color,
    this.textColor,
    this.borderColor,
    this.borderRadius = 14,
    this.fontSize,
    this.fontWeight,
    this.padding,
  }) : type = AppButtonType.primary;

  const AppButton.secondary({
    required this.text,
    required this.onPressed,
    super.key,
    this.isLoading = false,
    this.icon,
    this.svgIcon,
    this.useSvgColor = true,
    this.width = double.infinity,
    this.height = 52,
    this.color,
    this.textColor,
    this.borderColor,
    this.borderRadius = 14,
    this.fontSize,
    this.fontWeight,
    this.padding,
  }) : type = AppButtonType.secondary;

  const AppButton.outlined({
    required this.text,
    required this.onPressed,
    super.key,
    this.isLoading = false,
    this.icon,
    this.svgIcon,
    this.useSvgColor = true,
    this.width = double.infinity,
    this.height = 52,
    this.color,
    this.textColor,
    this.borderColor,
    this.borderRadius = 14,
    this.fontSize,
    this.fontWeight,
    this.padding,
  }) : type = AppButtonType.outlined;

  const AppButton.text({
    required this.text,
    required this.onPressed,
    super.key,
    this.isLoading = false,
    this.icon,
    this.svgIcon,
    this.useSvgColor = true,
    this.width,
    this.height = 52,
    this.color,
    this.textColor,
    this.borderColor,
    this.borderRadius = 14,
    this.fontSize,
    this.fontWeight,
    this.padding,
  }) : type = AppButtonType.text;

  const AppButton.danger({
    required this.text,
    required this.onPressed,
    super.key,
    this.isLoading = false,
    this.icon,
    this.svgIcon,
    this.useSvgColor = true,
    this.width = double.infinity,
    this.height = 52,
    this.color,
    this.textColor,
    this.borderColor,
    this.borderRadius = 14,
    this.fontSize,
    this.fontWeight,
    this.padding,
  }) : type = AppButtonType.danger;

  const AppButton.ghost({
    required this.text,
    required this.onPressed,
    super.key,
    this.isLoading = false,
    this.icon,
    this.svgIcon,
    this.useSvgColor = true,
    this.width = double.infinity,
    this.height = 52,
    this.color,
    this.textColor,
    this.borderColor,
    this.borderRadius = 14,
    this.fontSize,
    this.fontWeight,
    this.padding,
  }) : type = AppButtonType.ghost;

  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final bool isLoading;
  final IconData? icon;
  final String? svgIcon;
  final bool useSvgColor;
  final double? width;
  final double? height;
  final Color? color;
  final Color? textColor;
  final Color? borderColor;
  final double borderRadius;
  final double? fontSize;
  final FontWeight? fontWeight;
  final EdgeInsetsGeometry? padding;

  @override
  State<AppButton> createState() => _AppButtonState();
}

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 160),
      lowerBound: 0,
      upperBound: 1,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  bool get _isDisabled => widget.onPressed == null || widget.isLoading;

  void _onTapDown(TapDownDetails _) {
    if (_isDisabled) return;
    _pressController.forward();
  }

  void _onTapUp(TapUpDetails _) {
    _pressController.reverse();
    if (_isDisabled) return;
    HapticFeedback.lightImpact();
    widget.onPressed?.call();
  }

  void _onTapCancel() => _pressController.reverse();

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.color ?? _resolveTypeColor(context);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) =>
          Transform.scale(scale: _scaleAnimation.value, child: child),
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: DecoratedBox(
            decoration: _buildDecoration(context, baseColor),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: Padding(
                padding: widget.padding ??
                    const EdgeInsetsDirectional.symmetric(horizontal: 16),
                child: Center(child: _buildContent(context, baseColor)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildDecoration(BuildContext context, Color baseColor) {
    final radius = BorderRadius.circular(widget.borderRadius);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isDisabled && widget.type != AppButtonType.text) {
      return BoxDecoration(
        borderRadius: radius,
        color: isDark ? Colors.grey[800] : Colors.grey[200],
      );
    }

    switch (widget.type) {
      case AppButtonType.primary:
        final darker = Color.fromARGB(
          (baseColor.a * 255.0).round().clamp(0, 255),
          (baseColor.r * 255.0 * 0.75).round().clamp(0, 255),
          (baseColor.g * 255.0 * 0.75).round().clamp(0, 255),
          (baseColor.b * 255.0 * 0.75).round().clamp(0, 255),
        );
        return BoxDecoration(
          borderRadius: radius,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [baseColor, darker],
          ),
          border: widget.borderColor != null
              ? Border.all(color: widget.borderColor!, width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: baseColor.withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        );

      case AppButtonType.secondary:
        return BoxDecoration(
          borderRadius: radius,
          color: baseColor.withValues(alpha: 0.15),
          border: widget.borderColor != null
              ? Border.all(color: widget.borderColor!, width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: baseColor.withValues(alpha: 0.10),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        );

      case AppButtonType.outlined:
        return BoxDecoration(
          borderRadius: radius,
          border: Border.all(
            color: widget.borderColor ?? baseColor,
            width: 1.5,
          ),
        );

      case AppButtonType.danger:
        final dangerColor = widget.color ?? AppColors.danger;
        final dangerDarker = Color.fromARGB(
          (dangerColor.a * 255.0).round().clamp(0, 255),
          (dangerColor.r * 255.0 * 0.80).round().clamp(0, 255),
          (dangerColor.g * 255.0 * 0.80).round().clamp(0, 255),
          (dangerColor.b * 255.0 * 0.80).round().clamp(0, 255),
        );
        return BoxDecoration(
          borderRadius: radius,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [dangerColor, dangerDarker],
          ),
          border: widget.borderColor != null
              ? Border.all(color: widget.borderColor!, width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: dangerColor.withValues(alpha: 0.30),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        );

      case AppButtonType.ghost:
        return BoxDecoration(
          borderRadius: radius,
          color: baseColor.withValues(alpha: isDark ? 0.10 : 0.07),
          border: widget.borderColor != null
              ? Border.all(color: widget.borderColor!, width: 1.5)
              : null,
        );

      case AppButtonType.text:
        return const BoxDecoration();
    }
  }

  Widget _buildContent(BuildContext context, Color baseColor) {
    final contentColor = _resolveContentColor(context, baseColor);

    if (widget.isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(contentColor),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.svgIcon != null) ...[
          widget.useSvgColor
              ? SvgPicture.asset(
                  widget.svgIcon!,
                  width: 20,
                  height: 20,
                  colorFilter: ColorFilter.mode(contentColor, BlendMode.srcIn),
                )
              : SvgPicture.asset(widget.svgIcon!, width: 20, height: 20),
          const SizedBox(width: 8),
        ] else if (widget.icon != null) ...[
          Icon(widget.icon, size: 20, color: contentColor),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            widget.text,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: _isDisabled ? Colors.grey[400] : contentColor,
                  fontSize: widget.fontSize ?? 15,
                  fontWeight: widget.fontWeight ?? FontWeight.w600,
                  letterSpacing: 0.3,
                ),
          ),
        ),
      ],
    );
  }

  Color _resolveTypeColor(BuildContext context) {
    switch (widget.type) {
      case AppButtonType.danger:
        return AppColors.danger;
      default:
        return AppColors.teal;
    }
  }

  Color _resolveContentColor(BuildContext context, Color baseColor) {
    if (_isDisabled) return Colors.grey[400]!;
    if (widget.textColor != null) return widget.textColor!;
    switch (widget.type) {
      case AppButtonType.primary:
      case AppButtonType.danger:
        return Colors.white;
      case AppButtonType.secondary:
      case AppButtonType.ghost:
      case AppButtonType.outlined:
      case AppButtonType.text:
        return baseColor;
    }
  }
}
