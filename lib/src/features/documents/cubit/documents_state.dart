part of "documents_cubit.dart";

abstract class DocumentsState extends Equatable {
  const DocumentsState();

  @override
  List<Object?> get props => [];
}

class DocumentsInitial extends DocumentsState {}

class DocumentsLoading extends DocumentsState {}

class DocumentsLoaded extends DocumentsState {
  final List<Document> documents;

  const DocumentsLoaded({required this.documents});

  @override
  List<Object?> get props => [documents];
}

class DocumentsError extends DocumentsState {
  final String message;

  const DocumentsError(this.message);

  @override
  List<Object?> get props => [message];

  @override
  String toString() => "DocumentsError with message: $message";
}
