import 'package:flutter/material.dart';
import 'package:my_documents/src/core/extensions/extensions.dart';
import 'package:my_documents/src/features/documents/model/document.dart';
import 'package:my_documents/src/widgets/border_box.dart';
import 'package:my_documents/src/widgets/label.dart';

import '../pages/document_view_page.dart';

class DocumentCard extends StatelessWidget {
  final Document document;
  final bool isSelected;
  final VoidCallback? onTap;
  const DocumentCard({
    super.key,
    required this.document,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap:
            onTap ??
            () => Navigator.push(context, DocumentViewPage.route(document.id)),
        child: BorderBox(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
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
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        document.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Created: ${document.createdAt.formatted}",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Label(
                        color: document.status.color,
                        label: Text(
                          document.status.statusText,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedSwitcher(
                  duration: Durations.medium2,
                  child:
                      isSelected
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
      ),
    );
  }
}
