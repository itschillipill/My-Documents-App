import 'dart:async' show runZonedGuarded;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show DeviceOrientation;
import 'package:my_documents/src/sevices/observer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/app.dart';
import 'src/core/constants.dart';
import 'src/dependencies/initialization.dart';
import 'src/dependencies/widgets/dependencies_scope.dart';
import 'src/dependencies/widgets/splash_screen.dart';
import 'src/presentation/widgets/windows_scope.dart';
import 'src/utils/theme/theme.dart';

part 'src/presentation/widgets/initialization_error_screen.dart';

void main() {
  runZonedGuarded(
    () {
      final initialization = InitializationExecutor();
      runApp(
        DependenciesScope(
          initialization: initialization(
            orientations: [DeviceOrientation.portraitUp],
            onError: $initializationErrorHandler,
          ),
          splashScreen: InitializationSplashScreen(progress: initialization),
          child: const App(),
        ),
      );
    },
    (error, stack) {
      SessionLogger.instance.onError("Main", error, stack);
    },
  );
}
