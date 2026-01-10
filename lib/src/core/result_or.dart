import 'model/errors.dart';

class ResultOr<T> {
  final ErrorKeys? _error;
  final T? _result;

  bool get isSuccess => _error == null;
  bool get isError => !isSuccess;

  ResultOr._(this._result, this._error);

  factory ResultOr.success(T result) => ResultOr._(result, null);
  factory ResultOr.error(ErrorKeys error) => ResultOr._(null, error);

  void call({
    required void Function(T result) onSuccess,
    required void Function(ErrorKeys error) onError,
  }) {
    if (isSuccess) {
      onSuccess(_result as T);
    } else {
      onError(_error as ErrorKeys);
    }
  }
}
