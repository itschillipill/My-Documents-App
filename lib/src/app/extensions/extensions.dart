import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:my_documents/src/app/dependencies/dependencies.dart';
import 'package:my_documents/src/utils/sevices/notification/notification_service.dart';

import '../dependencies/widgets/dependencies_scope.dart';
import '../widgets/border_box.dart';

extension BuildContextX on BuildContext {
  Dependencies get deps => DependenciesScope.of(this);
  ThemeData get theme => Theme.of(this);
  NotificationService? get notificationService => null;
}

extension DateExtension on DateTime {
  String get formatted {
    return DateFormat('d MMMM yyyy').format(this);
  }
}

extension WidgetX on Widget {
  Widget withBorder({EdgeInsets? padding}) =>
      BorderBox(padding: padding, child: this);
}
