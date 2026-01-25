import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';

abstract class MyObserver {
  void onCreate(String name);
  void onClose(String name);
  void onError(
    String name,
    Object error,
    StackTrace stackTrace, {
    String? message,
  });
  void log(String name, String message);
}

final class MyClassObserver implements MyObserver {
  static final MyClassObserver instance = MyClassObserver._internal();
  static final MyNavigatorObserver navigatorObserver = MyNavigatorObserver();
  MyClassObserver._internal();

  //for blocs
  void onTransition<T>(String name, T oldState, T newState) {
    debugPrint("|$name| $oldState -> $newState");
  }

  @override
  void onError(
    String name,
    Object error,
    StackTrace stackTrace, {
    String? message,
  }) {
    debugPrint("[ERROR] |$name| $message -> $error\n$stackTrace");
  }

  @override
  void log(String name, String message) {
    debugPrint("[LOG] |$name| $message");
  }

  @override
  void onCreate(String name) {
    debugPrint("[CREATE] |$name|");
  }

  @override
  void onClose(String name) {
    debugPrint("[CLOSE] |$name|");
  }
}

class MyNavigatorObserver extends NavigatorObserver implements MyObserver {
  String _name(Route<dynamic>? route) {
    return route?.settings.name ?? route.runtimeType.toString();
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    final name = _name(route);
    onCreate(name);
    log(name, "push from ${_name(previousRoute)}");
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    final name = _name(route);
    onClose(name);
    log(name, "pop to ${_name(previousRoute)}");
    super.didPop(route, previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    final name = _name(newRoute);
    log(name, "replace ${_name(oldRoute)} -> $name");
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    final name = _name(route);
    log(name, "removed");
    super.didRemove(route, previousRoute);
  }

  @override
  void onCreate(String name) {
    debugPrint("[NAVIGATOR][OPEN] $name");
  }

  @override
  void onClose(String name) {
    debugPrint("[NAVIGATOR][CLOSE] $name");
  }

  @override
  void log(String name, String message) {
    debugPrint("[NAVIGATOR] |$name| $message");
  }

  @override
  void onError(
    String name,
    Object error,
    StackTrace stackTrace, {
    String? message,
  }) {
    debugPrint("[NAVIGATOR][ERROR] |$name| $message -> $error\n$stackTrace");
  }
}
