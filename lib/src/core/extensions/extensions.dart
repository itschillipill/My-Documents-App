import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:my_documents/src/dependencies/dependencies.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../dependencies/widgets/dependencies_scope.dart';

extension BuildContextX on BuildContext {
  Dependencies get deps => DependenciesScope.of(this);
  ThemeData get theme => Theme.of(this);
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

extension DateExtension on DateTime {
  String formatted(BuildContext ctx) =>
      DateFormat('d MMMM yyyy', ctx.l10n.localeName).format(this);
}
