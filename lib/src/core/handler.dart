import 'mutex.dart';

mixin Handler {
  final Mutex mutex = Mutex();
}
