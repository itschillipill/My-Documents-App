import 'package:flutter/foundation.dart' show debugPrint;
abstract class MyObserver{
  void onCreate(String name);
  void onClose(String name);
  void onError(String name, Object error, StackTrace stackTrace,{String? message});
  void log(String name, String message);
}

final class MyClassObserver implements MyObserver {
  static final MyClassObserver instance = MyClassObserver._internal();
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
