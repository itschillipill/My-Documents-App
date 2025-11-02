import 'dart:async' show runZonedGuarded;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show DeviceOrientation;

import 'src/app/app.dart';
import 'src/app/dependencies/initialization.dart';
import 'src/app/dependencies/widgets/dependencies_scope.dart';
import 'src/app/dependencies/widgets/splash_screen.dart';
import 'src/app/widgets/windows_scope.dart';
import 'src/utils/app_data.dart';
import 'src/utils/theme/theme.dart';

part 'src/app/dependencies/widgets/initialization_error_screen.dart';

void main() => runZonedGuarded(() {
  final initialization = InitializationExecutor();
  runApp(
    DependenciesScope(
      initialization: initialization(
        orientations: [DeviceOrientation.portraitUp],
        onError: _initializationErrorHandler,
      ),
      splashScreen: InitializationSplashScreen(progress: initialization),
      child: const App(),
    ),
  );
}, (error, stack) {});
