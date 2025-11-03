import 'package:flutter/material.dart';
import 'package:my_documents/src/utils/theme/theme.dart' show AppPalette;

class BorderBox extends StatelessWidget {
  final Widget child;
  final BoxConstraints? constraints;
  final double? height;
  final double? width;
  final EdgeInsets? padding;
  const BorderBox({
    super.key,
    required this.child,
    this.constraints,
    this.height,
    this.width,
    this.padding = const EdgeInsets.all(4),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      constraints: constraints,
      padding: padding,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.all(Radius.circular(8)),
        border: Border.all(color: AppPalette.borderColor),
      ),
      child: child,
    );
  }
}
