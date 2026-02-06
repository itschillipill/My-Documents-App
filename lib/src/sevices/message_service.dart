import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_documents/src/core/extensions/extensions.dart';
import 'package:my_documents/src/presentation/widgets/loading_overlay.dart';

import '../presentation/widgets/toast_wiget.dart';

class MessageService {
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>(debugLabel: "MessageService");

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>(debugLabel: "MessageService");

  static OverlayEntry? _loadingOverlay;

  static void _showLoading({String? message}) {
    if (_loadingOverlay != null) return;

    final context = navigatorKey.currentContext;
    if (context == null) return;

    final overlayState = navigatorKey.currentState?.overlay;
    if (overlayState == null) return;

    _loadingOverlay = OverlayEntry(
      builder: (_) => LoadingOverlay(message: message),
    );

    overlayState.insert(_loadingOverlay!);
  }

  static void _hideLoading() {
    if (_loadingOverlay == null) return;
    _loadingOverlay?.remove();
    _loadingOverlay = null;
  }

  static Future<T> showLoading<T>({
    String? message,
    required Future<T> Function() fn,
    Duration delay = const Duration(milliseconds: 500),
    Duration? timeout,
  }) async {
    _showLoading(message: message);

    try {
      final result = await (timeout != null
          ? Future.any([
              fn(),
              Future.delayed(timeout, () {
                throw TimeoutException("Operation timed out");
              }),
            ])
          : fn());

      await Future.delayed(delay);
      return result;
    } catch (e) {
      rethrow;
    } finally {
      _hideLoading();
    }
  }

  static void showSnackBar(String message, {Color? color, Color? textColor}) {
    messengerKey.currentState?.showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 800),
        content: Text(message, style: TextStyle(color: textColor)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void showSuccessSnack(String message) => showSnackBar(
    message,
    color: Colors.green.shade600,
    textColor: Colors.white,
  );

  static void showErrorSnack(String message) => showSnackBar(
    message,
    color: Colors.red.shade600,
    textColor: Colors.white,
  );

  static void showToast(String message, {Color background = Colors.black87}) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    final overlayState = navigatorKey.currentState?.overlay;
    if (overlayState == null) return;

    final overlayEntry = OverlayEntry(
      builder: (context) =>
          ToastWidget(message: message, background: background),
    );

    overlayState.insert(overlayEntry);

    Future.delayed(const Duration(milliseconds: 800), () {
      overlayEntry.remove();
    });
  }

  static void showSuccessToast(String message) =>
      showToast(message, background: Colors.green.shade600);

  static void showErrorToast(String message) =>
      showToast(message, background: Colors.red.shade600);

  static Future<T?> showDialogGlobal<T>(
    Function(BuildContext context) dialog, {
    BuildContext? ctx,
  }) {
    final context = ctx ?? navigatorKey.currentContext;
    if (context == null) {
      debugPrint("Context is null");
      return Future.value(null);
    }

    return showDialog<T>(context: context, builder: (ctx) => dialog(ctx));
  }

  static Future<bool> $confirmAction({
    String title = "",
    String? message,
  }) async {
    final res = await showDialogGlobal(
      (ctx) => AlertDialog(
        title: RichText(
          text: TextSpan(
            style: Theme.of(ctx).textTheme.titleMedium,
            children: [
              TextSpan(text: "${ctx.l10n.confirm} "),
              TextSpan(
                text: title,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        content: Text(message ?? ctx.l10n.confirmAction),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(ctx.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(ctx.l10n.ok),
          ),
        ],
      ),
    );
    return res ?? false;
  }
}
