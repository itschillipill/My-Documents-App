import 'dart:async' show runZonedGuarded;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show DeviceOrientation;
import 'package:shared_preferences/shared_preferences.dart';

import 'src/app.dart';
import 'src/core/constants.dart';
import 'src/dependencies/initialization.dart';
import 'src/dependencies/widgets/dependencies_scope.dart';
import 'src/dependencies/widgets/splash_screen.dart';
import 'src/widgets/windows_scope.dart';
import 'src/utils/theme/theme.dart';

part 'src/dependencies/widgets/initialization_error_screen.dart';

void main() {
  runZonedGuarded(() {
    final initialization = InitializationExecutor();
    runApp(
      DependenciesScope(
        initialization: initialization(
          orientations: [DeviceOrientation.portraitUp],
          onError: _$initializationErrorHandler,
        ),
        splashScreen: InitializationSplashScreen(progress: initialization),
        child: const App(),
      ),
    );
  }, (error, stack) {});
}
