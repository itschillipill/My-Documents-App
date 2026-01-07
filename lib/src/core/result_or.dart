import 'model/errors.dart';

class ResultOr<T> {
  final ErrorKeys? _error;
  final T? _result;

  bool get isSuccess => _result != null;
  bool get isError => _error != null;

  T get result => _result!;
  ErrorKeys get error => _error!;

  ResultOr._(this._result, this._error);

  factory ResultOr.success(T result) => ResultOr._(result, null);
  factory ResultOr.error(ErrorKeys error) => ResultOr._(null, error);

  void call({
    required Function(T result) onSuccess,
    required Function(ErrorKeys error) onError,
  }) {
    if (isSuccess) {
      onSuccess(_result as T);
    } else {
      onError(_error as ErrorKeys);
    }
  }
}
