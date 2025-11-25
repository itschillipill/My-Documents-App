import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class WindowScope extends StatefulWidget {
  const WindowScope({required this.title, required this.child, super.key});

  final String title;
  final Widget child;

  @override
  State<WindowScope> createState() => _WindowScopeState();
}

class _WindowScopeState extends State<WindowScope> {
  @override
  Widget build(BuildContext context) =>
      kIsWeb || io.Platform.isAndroid || io.Platform.isIOS
          ? widget.child
          : Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const _WindowTitle(),
              Expanded(child: widget.child),
            ],
          );
}

class _WindowTitle extends StatefulWidget {
  const _WindowTitle();

  @override
  State<_WindowTitle> createState() => _WindowTitleState();
}

class _WindowTitleState extends State<_WindowTitle> with WindowListener {
  final ValueNotifier<bool> _isFullScreen = ValueNotifier(false);
  final ValueNotifier<bool> _isAlwaysOnTop = ValueNotifier(false);
  final ValueNotifier<bool> _isMaximaized = ValueNotifier(true);

  @override
  void initState() {
    windowManager.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowEnterFullScreen() {
    super.onWindowEnterFullScreen();
    _isFullScreen.value = true;
  }

  @override
  void onWindowLeaveFullScreen() {
    super.onWindowLeaveFullScreen();
    _isFullScreen.value = false;
  }

  @override
  void onWindowMaximize() {
    super.onWindowMaximize();
    _isMaximaized.value = false;
  }

  @override
  void onWindowUnmaximize() {
    super.onWindowUnmaximize();
    _isMaximaized.value = true;
  }

  @override
  void onWindowFocus() {
    setState(() {});
    // do something
  }

  void setMaximaize() {
    Future<void>(() async {
      _isMaximaized.value = await windowManager.isMaximized();
      if (_isMaximaized.value) {
        await windowManager.unmaximize();
      } else {
        await windowManager.maximize();
      }
    }).ignore();
  }

  void setAlwaysOnTop(bool value) {
    Future<void>(() async {
      await windowManager.setAlwaysOnTop(value);
      _isAlwaysOnTop.value = await windowManager.isAlwaysOnTop();
    }).ignore();
  }

  void setFullScreen(bool value) {
    Future<void>(() async {
      await windowManager.setFullScreen(value);
      _isFullScreen.value = await windowManager.isFullScreen();
    }).ignore();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 24,
    child: DragToMoveArea(
      child: Material(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            // Builder(
            //   builder: (context) {
            //     final size = MediaQuery.of(context).size;
            //     return AnimatedPositioned(
            //       duration: const Duration(milliseconds: 350),
            //       left: size.width < 800 ? 8 : 78,
            //       right: 78,
            //       top: 0,
            //       bottom: 0,
            //       child: Center(
            //         child: AnimatedSwitcher(
            //           duration: const Duration(milliseconds: 250),
            //           transitionBuilder:
            //               (child, animation) => FadeTransition(
            //                 opacity: animation,
            //                 child: ScaleTransition(
            //                   scale: animation,
            //                   child: child,
            //                 ),
            //               ),
            //           child: Text(
            //             context
            //                     .findAncestorWidgetOfExactType<WindowScope>()
            //                     ?.title ??
            //                 'App',
            //             maxLines: 1,
            //             overflow: TextOverflow.ellipsis,
            //             style: Theme.of(
            //               context,
            //             ).textTheme.labelLarge?.copyWith(height: 1),
            //           ),
            //         ),
            //       ),
            //     );
            //   },
            // ),
            _WindowButtons$Windows(
              isFullScreen: _isFullScreen,
              isAlwaysOnTop: _isAlwaysOnTop,
              isMaximaized: _isMaximaized,
              setAlwaysOnTop: setAlwaysOnTop,
              setFullScreen: setFullScreen,
              setMaximaize: setMaximaize,
            ),
          ],
        ),
      ),
    ),
  );
}

class _WindowButtons$Windows extends StatelessWidget {
  const _WindowButtons$Windows({
    required ValueListenable<bool> isFullScreen,
    required ValueListenable<bool> isAlwaysOnTop,
    required ValueListenable<bool> isMaximaized,
    required this.setAlwaysOnTop,
    required this.setMaximaize,
    required this.setFullScreen,
  }) : _isFullScreen = isFullScreen,
       _isMaximaized = isMaximaized,
       _isAlwaysOnTop = isAlwaysOnTop;

  // ignore: unused_field
  final ValueListenable<bool> _isFullScreen;
  final ValueListenable<bool> _isAlwaysOnTop;
  final ValueListenable<bool> _isMaximaized;

  final ValueChanged<bool> setAlwaysOnTop;
  final ValueChanged<bool> setFullScreen;
  final VoidCallback setMaximaize;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerRight,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        // Is always on top
        ValueListenableBuilder<bool>(
          valueListenable: _isAlwaysOnTop,
          builder:
              (context, isAlwaysOnTop, _) => _WindowButton(
                onPressed: () => setAlwaysOnTop(!isAlwaysOnTop),
                icon: isAlwaysOnTop ? Icons.push_pin : Icons.push_pin_outlined,
              ),
        ),
        // Minimize
        _WindowButton(
          onPressed: () => windowManager.minimize(),
          icon: Icons.minimize,
        ),

        ValueListenableBuilder<bool>(
          valueListenable: _isMaximaized,
          builder:
              (context, isMaximaized, _) => _WindowButton(
                onPressed: setMaximaize,
                icon:
                    !isMaximaized
                        ? Icons.square_rounded
                        : Icons.crop_square_rounded,
              ),
        ),

        // Set Full Screen
        // ValueListenableBuilder<bool>(
        //   valueListenable: _isFullScreen,
        //   builder: (context, isFullScreen, _) => _WindowButton(
        //         onPressed: () => setFullScreen(!isFullScreen),
        //         icon: isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
        //       )),

        // Close
        _WindowButton(
          onPressed: () => windowManager.close(),
          icon: Icons.close,
        ),
        const SizedBox(width: 4),
      ],
    ),
  );
}

class _WindowButton extends StatelessWidget {
  const _WindowButton({required this.onPressed, required this.icon});

  final VoidCallback onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    child: IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      iconSize: 16,
      alignment: Alignment.center,
      padding: EdgeInsets.zero,
      splashRadius: 12,
      constraints: const BoxConstraints.tightFor(width: 24, height: 24),
    ),
  );
}
