import 'package:flutter/material.dart';
import 'package:my_documents/src/features/documents/model/document.dart';
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

    return InkWell(
      onTap:
          onTap ??
          () => Navigator.push(context, DocumentViewPage.route(document.id)),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8),
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
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Label(
                      color: document.status.color,
                      label: Text(
                        document.status.localizedText(context),
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
    );
  }
}
