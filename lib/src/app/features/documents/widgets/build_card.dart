import 'package:flutter/material.dart';
import 'package:my_documents/src/app/widgets/border_box.dart';

class BuildSection extends StatelessWidget {
  final List<Widget> children;

  const BuildSection({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 10,
      children: children,
    );
  }
}

class BuildCard extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  const BuildCard({
    super.key,
    required this.text,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: BorderBox(
            height: 100,
            child: GestureDetector(
              onTap: onTap,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                spacing: 5,
                children: [Icon(icon), Text(text, textAlign: TextAlign.center)],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
