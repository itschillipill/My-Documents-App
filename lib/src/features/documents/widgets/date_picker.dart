import 'package:flutter/material.dart';
import 'package:my_documents/src/core/extensions/extensions.dart';

class DatePicker extends StatelessWidget {
  final Function(DateTime?) onTap;
  final DateTime? expirationDate;

  const DatePicker({super.key, required this.onTap, this.expirationDate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text(
          context.l10n.expirationDate,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        InkWell(
          onTap: () async {
            final selectedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(3000),
            );
            if (selectedDate != null) onTap(selectedDate);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              spacing: 12,
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  color:
                      expirationDate != null
                          ? colorScheme.primary
                          : colorScheme.onSurface.withValues(alpha: 0.6),
                  size: 20,
                ),
                Expanded(
                  child: Text(
                    expirationDate != null
                        ? expirationDate!.formatted(context)
                        : context.l10n.setExpirationDate,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color:
                          expirationDate != null
                              ? colorScheme.onSurface
                              : colorScheme.onSurface.withValues(alpha: 0.6),
                      fontWeight:
                          expirationDate != null
                              ? FontWeight.w500
                              : FontWeight.normal,
                    ),
                  ),
                ),
                if (expirationDate != null)
                  IconButton(
                    onPressed: () => onTap(null),
                    icon: Icon(
                      Icons.close_rounded,
                      color: colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
