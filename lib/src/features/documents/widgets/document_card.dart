import 'package:flutter/material.dart';
import 'package:my_documents/src/features/documents/model/document.dart';
import 'package:my_documents/src/widgets/border_box.dart';
import 'package:my_documents/src/widgets/label.dart';

import '../pages/document_view_page.dart';

class DocumentCard extends StatelessWidget {
  final Document document;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  const DocumentCard({
    super.key,
    required this.document,
    this.isSelected = false,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onLongPress: onLongPress,
          onTap:
              onTap ??
              () =>
                  Navigator.push(context, DocumentViewPage.route(document.id)),
          child: BorderBox(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              spacing: 12,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(6),
                  child: Icon(
                    Icons.insert_drive_file_rounded,
                    size: 32,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    spacing: 5,
                    children: [
                      Text(
                        document.title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Label(
                        color: document.status.color,
                        label: document.status.localizedText(context),
                      ),
                    ],
                  ),
                ),
                AnimatedSwitcher(
                  duration: Durations.medium2,
                  child: isSelected
                      ? Icon(
                          Icons.check_rounded,
                          color: theme.colorScheme.secondary,
                          size: 20,
                        )
                      : document.isFavorite
                      ? Icon(
                          Icons.star_rounded,
                          color: theme.colorScheme.secondary,
                          size: 20,
                        )
                      : SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
