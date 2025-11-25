import 'package:flutter/material.dart';
import 'package:my_documents/src/widgets/border_box.dart';

class SectionBlock extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const SectionBlock({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return BorderBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
          Divider(),
          ...children,
        ],
      ),
    );
  }
}
