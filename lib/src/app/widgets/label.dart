import 'package:flutter/material.dart';

class Label extends StatelessWidget {
  final Widget label;
  final Color? color;
  const Label({super.key, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? Colors.grey.shade400,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
        child: label,
      ),
    );
  }
}
