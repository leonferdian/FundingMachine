import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double borderRadius;
  final bool isLoading;
  final bool isFullWidth;
  final double elevation;
  final BorderSide? side;
  final Gradient? gradient;

  const PrimaryButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.width,
    this.height = 50,
    this.padding,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius = 12,
    this.isLoading = false,
    this.isFullWidth = true,
    this.elevation = 0,
    this.side,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final buttonChild = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : child;

    final button = ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? const Color(0xFF6C63FF),
        foregroundColor: foregroundColor ?? Colors.white,
        minimumSize: Size(
          isFullWidth ? double.infinity : width ?? 0,
          height!,
        ),
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: side ?? BorderSide.none,
        ),
        elevation: elevation,
        shadowColor: Colors.transparent,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      child: buttonChild,
    );

    if (gradient != null) {
      return Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: elevation > 0
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: elevation * 2,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: button,
      );
    }

    return button;
  }
}
