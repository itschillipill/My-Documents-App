import 'package:flutter/material.dart';

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
    this.width = double.infinity,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: constraints,
      height: height,
                            width: double.infinity,
                             decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12)
    ),
      padding: padding,
      child: child,
    );
  }
}
