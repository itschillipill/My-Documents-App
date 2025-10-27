import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:my_documents/src/app/dependencies/dependencies.dart';

import '../dependencies/widgets/dependencies_scope.dart';

extension ContextExtension on BuildContext {
  ExtensionType get ext => ExtensionType(this);
}

extension type ExtensionType(BuildContext _context) {
  Dependencies get deps => DependenciesScope.of(_context);
}

extension DateExtension on DateTime {
  String get formatted {
    return DateFormat('d MMMM yyyy').format(this);
  }
}
