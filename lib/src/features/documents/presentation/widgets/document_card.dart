import 'package:flutter/material.dart';
import 'package:my_documents/src/features/documents/model/document.dart';

import '../document_view_screen.dart';

class DocumentCard extends StatelessWidget {
  final Document document;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showTimeAgo;

  const DocumentCard({
    super.key,
    required this.document,
    this.isSelected = false,
    this.showTimeAgo = false,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap:
          onTap ??
          () => Navigator.push(context, DocumentViewScreen.route(document.id)),
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: Durations.medium2,
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.08)
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary.withValues(alpha: 0.3)
                : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            if (!isSelected)
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          spacing: 8,
          children: [
            Container(
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(10),
              child: Icon(
                Icons.insert_drive_file_rounded,
                size: 28,
                color: colorScheme.primary,
              ),
            ),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          document.title,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (document.isFavorite)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Icon(
                            Icons.star_rounded,
                            size: 18,
                            color: colorScheme.secondary,
                          ),
                        ),
                    ],
                  ),

                  Row(
                    spacing: 4,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: document.status.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          document.status.localizedText(context),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: document.status.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (showTimeAgo)
                        Row(
                          spacing: 2,
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 14,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            Text(
                              _formatTimeAgo(context, document.createdAt),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),

            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  size: 16,
                  color: colorScheme.onPrimary,
                ),
              )
            else
              Icon(
                Icons.chevron_right_rounded,
                size: 24,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
          ],
        ),
      ),
    );
  }
}

String _formatTimeAgo(BuildContext context, DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inDays > 365) {
    final years = (difference.inDays / 365).floor();
    return "$years year ago";
  } else if (difference.inDays > 30) {
    final months = (difference.inDays / 30).floor();
    return "$months month ago";
  } else if (difference.inDays > 7) {
    final weeks = (difference.inDays / 7).floor();
    return "$weeks week ago";
  } else if (difference.inDays > 0) {
    return "${difference.inDays} day ago";
  } else if (difference.inHours > 0) {
    return "${difference.inHours} hour ago";
  } else if (difference.inMinutes > 0) {
    return "${difference.inMinutes} minute ago";
  } else {
    return "Just now";
  }
}
