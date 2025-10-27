import 'package:flutter/material.dart';
import 'package:my_documents/src/app/extensions/extensions.dart';
import 'package:my_documents/src/app/features/documents/model/document.dart';
import 'package:my_documents/src/app/widgets/border_box.dart';
import 'package:my_documents/src/app/widgets/label.dart';

class DocumentVersionCard extends StatelessWidget {
  final bool isCurrent;
  final DocumentVersion documentVersion;
  final VoidCallback onDelete;
  final VoidCallback onOpen;
  final VoidCallback onSetCurrent;

  const DocumentVersionCard({
    super.key,
    this.isCurrent = false,
    required this.documentVersion,
    required this.onDelete,
    required this.onOpen,
    required this.onSetCurrent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: BorderBox(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: isCurrent
                      ? Colors.green.withValues(alpha: 0.1)
                      : theme.colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(12),
                child: Icon(
                  isCurrent
                      ? Icons.verified_rounded
                      : Icons.history_rounded,
                  size: 32,
                  color: isCurrent
                      ? Colors.green
                      : theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Version ${documentVersion.id}",
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (isCurrent)
                          Label(
                            color: Colors.green,
                            label: Text(
                              "Current",
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Uploaded: ${documentVersion.uploadedAt.formatted}",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    if (documentVersion.comment != null &&
                        documentVersion.comment!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          "Comment: ${documentVersion.comment}",
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    if (documentVersion.expirationDate != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          "Expires: ${documentVersion.expirationDate!.formatted}",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                    const SizedBox(height: 10),

                    // 🔘 Кнопки действий
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onOpen,
                            icon: const Icon(Icons.remove_red_eye_outlined),
                            label: const Text("Open"),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (!isCurrent)
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: onSetCurrent,
                              icon: const Icon(Icons.check_circle_outline),
                              label: const Text("Set current"),
                            ),
                          ),
                        IconButton(
                          onPressed: onDelete,
                          icon: const Icon(Icons.delete_outline),
                          color: Colors.redAccent,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
