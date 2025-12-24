import 'package:flutter/material.dart';
import 'package:my_documents/src/core/extensions/extensions.dart';

class DatePicker extends StatelessWidget {
  final DateTime? expirationDate;
  final Function(DateTime?) onTap;

  const DatePicker({super.key, this.expirationDate, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: true,
      controller: TextEditingController(
        text:
            expirationDate == null
                ? context.l10n.noExpiration
                : expirationDate!.formatted,
      ),
      decoration: InputDecoration(
        hintText: context.l10n.expirationDate,
        suffixIcon: Icon(Icons.calendar_month_rounded),
      ),
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365 * 15)),
        );
        onTap(date);
      },
    );
  }
}
