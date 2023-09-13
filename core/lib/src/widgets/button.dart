import 'package:core/src/extension/context_extension.dart';
import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  const Button({
    Key? key,
    required this.label,
    required this.onPressed,
    this.background,
    this.textStyle,
    this.scale = 1,
    this.height = 69,
    this.width = double.infinity,
    this.isLoading = false,
    this.filled = true,
    this.prefix,
    this.disable = false,
  }) : super(key: key);

  final VoidCallback onPressed;
  final String label;
  final Color? background;
  final TextStyle? textStyle;
  final double scale;
  final double height;
  final double width;
  final bool filled;
  final bool isLoading;
  final Widget? prefix;
  final bool disable;

  factory Button.filled({
    required String label,
    required VoidCallback onPressed,
    Color? background,
    TextStyle? textStyle,
    double scale = 1,
    double height = 69,
    double width = double.infinity,
    bool isLoading = false,
    Widget? prefix,
    bool disable = false,
  }) {
    return Button(
      label: label,
      onPressed: onPressed,
      background: background,
      textStyle: textStyle,
      scale: scale,
      height: height,
      width: width,
      isLoading: isLoading,
      filled: true,
      prefix: prefix,
      disable: disable,
    );
  }

  factory Button.outlined({
    required String label,
    required VoidCallback onPressed,
    Color? background,
    TextStyle? textStyle,
    double scale = 1,
    double height = 69,
    double width = double.infinity,
    isLoading = false,
    Widget? prefix,
    bool disable = false,
  }) {
    return Button(
      label: label,
      onPressed: onPressed,
      background: background,
      textStyle: textStyle,
      scale: scale,
      height: height,
      width: width,
      isLoading: isLoading,
      filled: false,
      prefix: prefix,
      disable: disable,
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = this.height;
    const double borderRadius = 48;

    return DecoratedBox(
      decoration: disable || filled == false
          ? const BoxDecoration()
          : BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  context.theme.color.burntSienna,
                  context.theme.color.russianViolet,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
      child: ElevatedButton(
        onPressed: disable
            ? null
            : isLoading
                ? null
                : onPressed,
        style: filled
            ? ElevatedButton.styleFrom(
                elevation: 0,
                padding: EdgeInsets.zero,
                fixedSize: Size(width, height),
                backgroundColor: background ?? context.theme.color.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
              )
            : ElevatedButton.styleFrom(
                elevation: 0,
                fixedSize: Size(width, height),
                backgroundColor: disable
                    ? context.theme.color.disabled
                    : background ?? context.theme.color.transparent,
                side: BorderSide(
                  color: isLoading
                      ? context.theme.color.transparent
                      : context.theme.color.white,
                  width: 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
              ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isLoading
                ? Transform.scale(
                    scale: scale,
                    child: const SizedBox(
                      height: 30,
                      width: 30,
                      child: CircularProgressIndicator(),
                    ),
                  )
                : prefix == null
                    ? Text(
                        label,
                        style: textStyle ?? _labelTextStyle(context),
                      )
                    : Row(
                        children: [
                          prefix!,
                          const SizedBox(width: 10),
                          Text(
                            label,
                            style: textStyle ?? _labelTextStyle(context),
                          ),
                        ],
                      ),
          ],
        ),
      ),
    );
  }

  TextStyle _labelTextStyle(BuildContext context) {
    return TextStyle(
      color: context.theme.color.white,
      fontSize: 20,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.025,
    );
  }
}
