import 'package:flutter/material.dart';

class MessageService {
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static void showSnackBar(String message, {Color? color}) {
    messengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void showSuccessSnack(String message) =>
      showSnackBar(message, color: Colors.green.shade600);

  static void showErrorSnack(String message) =>
      showSnackBar(message, color: Colors.red.shade600);

  static void showToast(String message, {Color background = Colors.black87}) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    final overlayState = navigatorKey.currentState?.overlay;
    if (overlayState == null) return;

    final overlayEntry = OverlayEntry(
      builder:
          (context) => _ToastWidget(message: message, background: background),
    );

    overlayState.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  static void showSuccessToast(String message) =>
      showToast(message, background: Colors.green.shade600);

  static void showErrorToast(String message) =>
      showToast(message, background: Colors.red.shade600);
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final Color background;

  const _ToastWidget({required this.message, required this.background});

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
  late final Animation<Offset> _offsetAnimation = Tween(
    begin: const Offset(0, -1),
    end: const Offset(0, 0),
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 20,
      right: 20,
      child: SlideTransition(
        position: _offsetAnimation,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: widget.background,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              widget.message,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
