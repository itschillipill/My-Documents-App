import 'package:flutter/foundation.dart' show debugPrint;

final class MyBlocObserver {
  static final MyBlocObserver instance = MyBlocObserver._internal();
  MyBlocObserver._internal();

  void onTransition<T>(String name, T oldState, T newState) {
    debugPrint("|$name| $oldState -> $newState");
  }

  void onError(String name, Object error, StackTrace stackTrace) {
    debugPrint(
      "[ERROR] |$name| -> $error\n$stackTrace",
    );
  }
  void onCreate(String name) {
    debugPrint("[CREATE] |$name|");
  }

  void onClose(String name) {
    debugPrint("[CLOSE] |$name|");
  }
}
