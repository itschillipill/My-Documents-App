import 'package:flutter/material.dart' show BuildContext;
import 'package:my_documents/src/core/extensions/extensions.dart';

enum SortOptions {
  byUploadDate,
  byAlphabet,
  byExpirationDate,
  none;

  String title(BuildContext ctx) {
    switch (this) {
      case SortOptions.byUploadDate:
        return ctx.l10n.uploadDate;
      case SortOptions.byAlphabet:
        return ctx.l10n.name;
      case SortOptions.byExpirationDate:
        return ctx.l10n.expirationDate;
      case SortOptions.none:
        return ctx.l10n.noFilter;
    }
  }
}
