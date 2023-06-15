import 'package:flutter/material.dart';

enum ButtonType { elevated, filled, text, outlined }

class LoaderButton extends StatelessWidget {
  final VoidCallback onPressed;
  final ButtonType type;
  final Widget child;
  final bool loading;

  const LoaderButton({
    Key? key,
    required this.onPressed,
    required this.type,
    required this.child,
    required this.loading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _button(
      child: IntrinsicHeight(
        child: Stack(
          children: [
            Center(child: child),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 250),
              opacity: loading ? 1.0 : 0.0,
              child: Align(
                alignment: Alignment.centerRight,
                child: Builder(builder: (context) {
                  return SizedBox.square(
                    dimension: 12.0,
                    child: CircularProgressIndicator(
                      color: DefaultTextStyle.of(context).style.color,
                      strokeWidth: 3.0,
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ButtonStyleButton _button({required Widget child}) {
    return switch (type) {
      ButtonType.elevated => ElevatedButton(onPressed: onPressed, child: child),
      ButtonType.outlined => OutlinedButton(onPressed: onPressed, child: child),
      ButtonType.filled => FilledButton(onPressed: onPressed, child: child),
      ButtonType.text => TextButton(onPressed: onPressed, child: child),
    };
  }
}
