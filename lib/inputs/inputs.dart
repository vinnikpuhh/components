// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputField extends StatefulWidget {
  const InputField({
    super.key,
    this.prefix,
    this.suffix,
    this.readOnly = false,
    this.outerDecoration,
    this.inputDecoration,
    this.contentPadding,
    this.maxLines,
    this.textInputAction,
    this.keyboardType,
    this.validator,
    this.autofocus = false,
    this.onChanged,
    this.onFieldSubmitted,
    this.focusNode,
    this.cursorWidth = 1.0,
    this.inputTextStyle,
    this.controller,
    this.formatters,
    this.cursorColor,
  }) /* : assert(
          inputDecoration != null &&
              (suffix != null || prefix != null || contentPadding != null),
          'Если есть inputDecoration, то suffix, prefix, contentPadding, должны быть равны null',
        ),
        super(key: key) */
  ;

  final Widget? prefix;
  final Widget? suffix;
  final bool? readOnly;
  final Decoration? outerDecoration;
  final InputDecoration? inputDecoration;
  final EdgeInsets? contentPadding;
  final int? maxLines;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool? autofocus;
  final void Function(String?)? onChanged;
  final void Function(String?)? onFieldSubmitted;
  final FocusNode? focusNode;
  final double? cursorWidth;
  final TextStyle? inputTextStyle;
  final TextEditingController? controller;
  final List<TextInputFormatter>? formatters;
  final Color? cursorColor;

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  @override
  Widget build(BuildContext context) {
    final child = TextFormField(
      maxLines: widget.maxLines,
      readOnly: widget.readOnly!,
      textInputAction: widget.textInputAction,
      validator: widget.validator,
      autofocus: widget.autofocus!,
      onChanged: widget.onChanged,
      controller: widget.controller,
      focusNode: widget.focusNode,
      keyboardType: widget.keyboardType,
      cursorWidth: widget.cursorWidth!,
      inputFormatters: widget.formatters,
      onFieldSubmitted: widget.onFieldSubmitted,
      style: widget.inputTextStyle,
      decoration: inputDecoration(),
    );

    if (widget.outerDecoration == null) {
      return child;
    } else {
      return Container(
        decoration: widget.outerDecoration,
        child: child,
      );
    }
  }

  InputDecoration inputDecoration() {
    return widget.inputDecoration ??
        InputDecoration(
          prefixIcon: widget.prefix,
          suffixIcon: widget.suffix,
          contentPadding: widget.contentPadding,
        );
  }
}
