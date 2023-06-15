import 'package:flutter/material.dart';

class SquareButton extends StatelessWidget {
  const SquareButton._({
    Key? key,
    this.size = 40.0,
    this.color,
    this.borderRadius = 0.0,
    this.border,
    this.gradient,
    this.decoration,
    required this.onPressed,
    required this.child,
  })  : assert(
          gradient != null && color == null ||
              color != null && gradient == null ||
              color == null && gradient == null && decoration != null,
          'Либо только цвет, либо только градиент. Нельзя указывать оба',
        ),
        super(key: key);

  factory SquareButton.gradient({
    Key? key,
    required Gradient gradient,
    required Widget child,
    required VoidCallback onPressed,
    double size = 40.0,
    double borderRadius = 0.0,
    Border? border,
  }) {
    return SquareButton._(
      onPressed: onPressed,
      size: size,
      border: border,
      gradient: gradient,
      borderRadius: borderRadius,
      decoration: null,
      child: child,
    );
  }

  factory SquareButton.color({
    Key? key,
    required Color color,
    required Widget child,
    required VoidCallback onPressed,
    double size = 40.0,
    double borderRadius = 0.0,
    Border? border,
  }) {
    return SquareButton._(
      onPressed: onPressed,
      size: size,
      border: border,
      color: color,
      borderRadius: borderRadius,
      decoration: null,
      child: child,
    );
  }

  factory SquareButton.customDecoration({
    Key? key,
    double? size,
    Decoration? decoration,
    required Widget child,
    required VoidCallback onPressed,
  }) {
    return SquareButton._(
      onPressed: onPressed,
      decoration: decoration,
      child: child,
    );
  }

  final Widget child;
  final double size;
  final Color? color;
  final Gradient? gradient;
  final double borderRadius;
  final Border? border;
  final Decoration? decoration;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: size,
        width: size,
        decoration: getDecoration(),
        child: Center(child: child),
      ),
    );
  }

  Decoration getDecoration() {
    return decoration ??
        BoxDecoration(
          color: color,
          gradient: gradient,
          border: border,
          borderRadius: BorderRadius.circular(borderRadius),
        );
  }
}
