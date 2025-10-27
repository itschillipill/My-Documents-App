import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../../../utils/app_data.dart';

Future<void> $platformInitialization() =>
    io.Platform.isAndroid || io.Platform.isIOS
        ? _mobileInitialization()
        : _desktopInitialization();

Future<void> _mobileInitialization() async {}

Future<void> _desktopInitialization() async {
  await windowManager.ensureInitialized();
  final windowOptions = WindowOptions(
    minimumSize: const Size(360, 480),
    size: const Size(960, 800),
    center: true,
    backgroundColor:
        PlatformDispatcher.instance.platformBrightness == Brightness.dark
            ? ThemeData.dark().colorScheme.surface
            : ThemeData.light().colorScheme.surface,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
    /* alwaysOnTop: true, */
    fullScreen: false,
    title: AppData.appName,
  );
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    if (io.Platform.isMacOS) {
      await windowManager.setMovable(true);
    }
    await windowManager.setMaximizable(true);
    await windowManager.show();
    await windowManager.focus();
  });
}
