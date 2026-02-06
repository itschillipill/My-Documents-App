import 'mutex.dart';
import 'dart:async';
import 'package:meta/meta.dart';

mixin SequentialHandler{
  final Mutex _$mutex = Mutex();

  bool get isProcessing => _$mutex.locked;

  @protected
  Future<T?> handle<T>(
    Future<T> Function() handler, {
    Future<void> Function(Object error, StackTrace stackTrace)? error,
    Future<void> Function()? done,
    String? name,
    Map<String, Object?>? meta,
  }) => _$mutex.synchronize<T?>(handler);
}