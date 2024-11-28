import 'package:flutter/material.dart';

import '../constants.dart';

class GradientButton extends StatefulWidget {
  final Future<void> Function()? onPressed; // Allow asynchronous onPressed
  final String? label;
  final double? height;
  final double? width;
  final double? labelFontSize;
  final Color? labelColor;
  final ValueKey? valueKey;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final String? semanticLabel;
  final Gradient? gradient;
  final BoxBorder? border;
  final FocusNode? buttonFocusNode;

  const GradientButton({
    super.key,
    this.onPressed,
    this.semanticLabel,
    this.label,
    this.valueKey,
    this.margin,
    this.padding,
    this.height = 44,
    this.width,
    this.labelFontSize,
    this.borderRadius = 6.0,
    this.labelColor,
    this.gradient,
    this.border,
    this.buttonFocusNode,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius:
        BorderRadius.all(Radius.circular(borderRadius)),
        // color: Theme.of(context).colorScheme.background,
        border: widget.border ?? Border.all(color: Colors.transparent),
        gradient: widget.gradient
      ),
      height: widget.height,
      width: widget.width,
      child: ElevatedButton(
        focusNode: widget.buttonFocusNode,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.all(Radius.circular(borderRadius)),
          ),
          backgroundColor: Colors.blueAccent.shade200,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          elevation: 0,
        ),
        onPressed:
        widget.onPressed != null ? () => widget.onPressed!() : null,
        child: Text(
          widget.label!.toUpperCase(),
          key: widget.valueKey,
          style: const TextStyle(color: Colors.white),
          semanticsLabel: widget.semanticLabel,
        ),
      ),
    );
  }
}