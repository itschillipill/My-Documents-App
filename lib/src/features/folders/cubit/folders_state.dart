part of "folders_cubit.dart";

abstract class FoldersState extends Equatable {
  const FoldersState();

  @override
  List<Object?> get props => [];
}

class FoldersInitial extends FoldersState {}

class FoldersLoading extends FoldersState {}

class FoldersLoaded extends FoldersState {
  final List<Folder> folders;

  const FoldersLoaded({required this.folders});

  @override
  List<Object?> get props => [folders];
}

class FoldersError extends FoldersState {
  final String message;

  const FoldersError(this.message);

  @override
  List<Object?> get props => [message];
}
