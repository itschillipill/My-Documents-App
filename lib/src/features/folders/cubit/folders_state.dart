part of "folders_cubit.dart";

/// Entity placeholder

/// {@template folders_state}
/// FoldersState.
/// {@endtemplate}
sealed class FoldersState extends _$FoldersStateBase {
  /// {@macro folders_state}
  const FoldersState({
    required super.folders,
    required super.message,
    super.error,
    super.stackTrace,
  });

  /// Idle
  /// {@macro folders_state}
  const factory FoldersState.idle({
    List<Folder>? folders,
    String message,
    Object? error,
    StackTrace? stackTrace,
  }) = FoldersState$Idle;

  /// Processing
  /// {@macro folders_state}
  const factory FoldersState.processing({
    List<Folder>? folders,
    String message,
    Object? error,
    StackTrace? stackTrace,
  }) = FoldersState$Processing;

  /// Failed
  /// {@macro folders_state}
  const factory FoldersState.failed({
    List<Folder>? folders,
    String message,
    Object? error,
    StackTrace? stackTrace,
  }) = FoldersState$Failed;

  /// Initial
  /// {@macro folders_state}
  factory FoldersState.initial({
    List<Folder>? folders,
    String? message,
    Object? error,
    StackTrace? stackTrace,
  }) => FoldersState$Idle(
    folders: folders,
    message: message ?? 'Initial',
    error: error,
    stackTrace: stackTrace,
  );
}

/// Idle
final class FoldersState$Idle extends FoldersState {
  const FoldersState$Idle({
    super.folders,
    super.message = 'Idle',
    super.error,
    super.stackTrace,
  });

  @override
  String get type => 'idle';
}

/// Processing
final class FoldersState$Processing extends FoldersState {
  const FoldersState$Processing({
    super.folders,
    super.message = 'Processing',
    super.error,
    super.stackTrace,
  });

  @override
  String get type => 'processing';
}

/// Failed
final class FoldersState$Failed extends FoldersState {
  const FoldersState$Failed({
    super.folders,
    super.message = 'Failed',
    super.error,
    super.stackTrace,
  });

  @override
  String get type => 'failed';
}

/// Pattern matching for [FoldersState].
typedef FoldersStateMatch<R, S extends FoldersState> = R Function(S element);

@immutable
abstract base class _$FoldersStateBase {
  const _$FoldersStateBase({
    required this.folders,
    required this.message,
    this.error,
    this.stackTrace,
  });

  /// Type alias for [FoldersState].
  abstract final String type;

  /// folders entity payload.
  @nonVirtual
  final List<Folder>? folders;

  /// Message or description.
  @nonVirtual
  final String message;

  /// Error object.
  @nonVirtual
  final Object? error;

  /// Stack trace object.
  @nonVirtual
  final StackTrace? stackTrace;

  /// Has folders?
  bool get hasfolders => folders != null;

  /// Check if is Idle.
  bool get isIdle => this is FoldersState$Idle;

  /// Check if is Processing.
  bool get isProcessing => this is FoldersState$Processing;

  /// Check if is Failed.
  bool get isFailed => this is FoldersState$Failed;

  /// Pattern matching for [FoldersState].
  R map<R>({
    required FoldersStateMatch<R, FoldersState$Idle> idle,
    required FoldersStateMatch<R, FoldersState$Processing> processing,
    required FoldersStateMatch<R, FoldersState$Failed> failed,
  }) => switch (this) {
    FoldersState$Idle s => idle(s),
    FoldersState$Processing s => processing(s),
    FoldersState$Failed s => failed(s),
    _ => throw AssertionError(),
  };

  /// Pattern matching for [FoldersState].
  R maybeMap<R>({
    required R Function() orElse,
    FoldersStateMatch<R, FoldersState$Idle>? idle,
    FoldersStateMatch<R, FoldersState$Processing>? processing,
    FoldersStateMatch<R, FoldersState$Failed>? failed,
  }) => map<R>(
    idle: idle ?? (_) => orElse(),
    processing: processing ?? (_) => orElse(),
    failed: failed ?? (_) => orElse(),
  );

  /// Pattern matching for [FoldersState].
  R? mapOrNull<R>({
    FoldersStateMatch<R, FoldersState$Idle>? idle,
    FoldersStateMatch<R, FoldersState$Processing>? processing,
    FoldersStateMatch<R, FoldersState$Failed>? failed,
  }) => map<R?>(
    idle: idle ?? (_) => null,
    processing: processing ?? (_) => null,
    failed: failed ?? (_) => null,
  );

  @override
  int get hashCode => Object.hash(type, folders);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is _$FoldersStateBase &&
          type == other.type &&
          identical(folders, other.folders));

  @override
  String toString() => 'FoldersState.$type{message: $message}';
}
