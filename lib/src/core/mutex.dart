import 'dart:async';
import 'dart:collection';

class Mutex {
  Mutex();

  final DoubleLinkedQueue<Completer<void>> _queue =
      DoubleLinkedQueue<Completer<void>>();

  bool get isLocked => _queue.isNotEmpty;

  int get tasks => _queue.length;

  Future<void> lock() {
    final previous = _queue.lastOrNull?.future ?? Future<void>.value();
    _queue.add(Completer<void>.sync());
    return previous;
  }

  void unlock() {
    if (_queue.isEmpty) {
      assert(false, "Mutex unlock called when no tasks are waiting");
      return;
    }
    final completer = _queue.removeFirst();
    if (completer.isCompleted) {
      assert(
        false,
        "Mutex unlock called when the completer is already completed",
      );
      return;
    }
    completer.complete();
  }

  Future<T> synchronize<T>(Future<T> Function() task) async {
    await lock();
    try {
      return await task();
    } finally {
      unlock();
    }
  }
}
