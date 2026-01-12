part of "documents_cubit.dart";

/// {@template documents_state}
/// DocumentsState.
/// {@endtemplate}
sealed class DocumentsState extends _$DocumentsStateBase {
  /// {@macro documents_state}
  const DocumentsState({
    required super.documents,
    required super.message,
    super.error,
    super.stackTrace,
  });

  /// Idle
  /// {@macro documents_state}
  const factory DocumentsState.idle({
    List<Document>? documents,
    String message,
    Object? error,
    StackTrace? stackTrace,
  }) = DocumentsState$Idle;

  /// Processing
  /// {@macro documents_state}
  const factory DocumentsState.processing({
    List<Document>? documents,
    String message,
    Object? error,
    StackTrace? stackTrace,
  }) = DocumentsState$Processing;

  /// Failed
  /// {@macro documents_state}
  const factory DocumentsState.failed({
    List<Document>? documents,
    String message,
    Object? error,
    StackTrace? stackTrace,
  }) = DocumentsState$Failed;

  /// Initial
  /// {@macro documents_state}
  factory DocumentsState.initial({
    String? message,
    Object? error,
    StackTrace? stackTrace,
  }) => DocumentsState$Idle(
    documents: null,
    message: message ?? 'Initial',
    error: error,
    stackTrace: stackTrace,
  );
}

/// Idle
final class DocumentsState$Idle extends DocumentsState {
  const DocumentsState$Idle({
    super.documents,
    super.message = 'Idle',
    super.error,
    super.stackTrace,
  });

  @override
  String get type => 'idle';
}

/// Processing
final class DocumentsState$Processing extends DocumentsState {
  const DocumentsState$Processing({
    super.documents,
    super.message = 'Processing',
    super.error,
    super.stackTrace,
  });

  @override
  String get type => 'processing';
}

/// Failed
final class DocumentsState$Failed extends DocumentsState {
  const DocumentsState$Failed({
    super.documents,
    super.message = 'Failed',
    super.error,
    super.stackTrace,
  });

  @override
  String get type => 'failed';
}

/// Pattern matching for [DocumentsState].
typedef DocumentsStateMatch<R, S extends DocumentsState> =
    R Function(S element);

@immutable
abstract base class _$DocumentsStateBase {
  const _$DocumentsStateBase({
    required this.documents,
    required this.message,
    this.error,
    this.stackTrace,
  });

  /// Type alias for [DocumentsState].
  abstract final String type;

  /// documents entity payload.
  @nonVirtual
  final List<Document>? documents;

  /// Message or description.
  @nonVirtual
  final String message;

  /// Error object.
  @nonVirtual
  final Object? error;

  /// Stack trace object.
  @nonVirtual
  final StackTrace? stackTrace;

  /// Has documents?
  bool get hasDocuments => documents != null && documents!.isNotEmpty;

  /// Check if is Idle.
  bool get isIdle => this is DocumentsState$Idle;

  /// Check if is Processing.
  bool get isProcessing => this is DocumentsState$Processing;

  /// Check if is Failed.
  bool get isFailed => this is DocumentsState$Failed;

  /// Pattern matching for [DocumentsState].
  R map<R>({
    required DocumentsStateMatch<R, DocumentsState$Idle> idle,
    required DocumentsStateMatch<R, DocumentsState$Processing> processing,
    required DocumentsStateMatch<R, DocumentsState$Failed> failed,
  }) => switch (this) {
    DocumentsState$Idle s => idle(s),
    DocumentsState$Processing s => processing(s),
    DocumentsState$Failed s => failed(s),
    _ => throw AssertionError(),
  };

  /// Pattern matching for [DocumentsState].
  R maybeMap<R>({
    required R Function() orElse,
    DocumentsStateMatch<R, DocumentsState$Idle>? idle,
    DocumentsStateMatch<R, DocumentsState$Processing>? processing,
    DocumentsStateMatch<R, DocumentsState$Failed>? failed,
  }) => map<R>(
    idle: idle ?? (_) => orElse(),
    processing: processing ?? (_) => orElse(),
    failed: failed ?? (_) => orElse(),
  );

  /// Pattern matching for [DocumentsState].
  R? mapOrNull<R>({
    DocumentsStateMatch<R, DocumentsState$Idle>? idle,
    DocumentsStateMatch<R, DocumentsState$Processing>? processing,
    DocumentsStateMatch<R, DocumentsState$Failed>? failed,
  }) => map<R?>(
    idle: idle ?? (_) => null,
    processing: processing ?? (_) => null,
    failed: failed ?? (_) => null,
  );

  @override
  int get hashCode => Object.hash(type, documents);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is _$DocumentsStateBase &&
          type == other.type &&
          identical(documents, other.documents));

  @override
  String toString() => 'DocumentsState.$type{message: $message}';
}
