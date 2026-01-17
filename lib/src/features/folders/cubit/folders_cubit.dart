import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:my_documents/src/core/model/errors.dart';
import 'package:my_documents/src/core/result_or.dart';
import '../../../data/data_sourse.dart';

import 'package:my_documents/src/features/folders/model/folder.dart';

import '../../../utils/sevices/observer.dart';
part 'folders_state.dart';

class FoldersCubit extends Cubit<FoldersState> {
  final DataSource dataSource;

  FoldersCubit({required this.dataSource}) : super(FoldersState.initial()) {
    MyClassObserver.instance.onCreate(name);
    loadData();
  }

  String get name => "FoldersCubit";

  @override
  void emit(FoldersState state) {
    MyClassObserver.instance.onTransition(name, this.state, state);
    super.emit(state);
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    super.onError(error, stackTrace);
    MyClassObserver.instance.onError(name, error, stackTrace);
  }

  @override
  Future<void> close() {
    MyClassObserver.instance.onClose(name);
    return super.close();
  }

  List<Folder> get foldersOrEmpty => state.folders ?? [];

  @protected
  Future<void> loadData() async {
    emit(
      FoldersState.processing(
        folders: state.folders,
        message: 'Loading data...',
      ),
    );
    try {
      final folders = await dataSource.getAllFolders();
      emit(
        FoldersState.processing(
          folders: folders,
          message: 'Data loaded successfully.',
        ),
      );
    } catch (e, s) {
      emit(
        FoldersState.failed(
          folders: state.folders,
          message: "Error loading data",
          error: e,
          stackTrace: s,
        ),
      );
    } finally {
      emit(FoldersState.idle(folders: state.folders));
    }
  }

  Future<void> addFolder(Folder folder) async {
    emit(
      FoldersState.processing(
        folders: state.folders,
        message: 'Adding folder...',
      ),
    );
    try {
      Folder newFolder = await dataSource.insertFolder(folder);
      emit(
        FoldersState.processing(
          folders: [...?state.folders, newFolder],
          message: 'Folder added successfully.',
        ),
      );
    } catch (e, s) {
      emit(
        FoldersState.failed(
          folders: state.folders,
          message: "Error adding folder",
          error: e,
          stackTrace: s,
        ),
      );
    } finally {
      emit(FoldersState.idle(folders: state.folders));
    }
  }

  Future<void> deleteFolder(int id) async {
    emit(
      FoldersState.processing(
        folders: state.folders,
        message: 'Deleting folder...',
      ),
    );
    try {
      bool success = await dataSource.deleteFolder(id);
      if (!success) return;
      final updatedFolders = state.folders
          ?.where((element) => element.id != id)
          .toList();

      emit(
        FoldersState.processing(
          folders: updatedFolders,
          message: 'Folder deleted successfully.',
        ),
      );
    } catch (e, s) {
      emit(
        FoldersState.failed(
          folders: state.folders,
          message: "Error deleting folder",
          error: e,
          stackTrace: s,
        ),
      );
    } finally {
      emit(FoldersState.idle(folders: state.folders));
    }
  }

  Future<void> updateFolder(Folder folder) async {
    emit(
      FoldersState.processing(
        folders: state.folders,
        message: 'Updating folder...',
      ),
    );
    try {
      Folder updatedFolder = await dataSource.updateFolder(folder);

      final updatedFolders = state.folders
          ?.map((e) => e.id == folder.id ? updatedFolder : e)
          .toList();

      emit(
        FoldersState.processing(
          folders: updatedFolders,
          message: 'Folder updated successfully.',
        ),
      );
    } catch (e, s) {
      emit(
        FoldersState.failed(
          folders: state.folders,
          message: "Error updating folder",
          error: e,
          stackTrace: s,
        ),
      );
    } finally {
      emit(FoldersState.idle(folders: state.folders));
    }
  }

  Future<ResultOr<void>> saveFolder(Folder folder) async {
    if (folder.name.isEmpty) return ResultOr.error(ErrorKeys.enterTitle);
    if (foldersOrEmpty.any((element) => element.name == folder.name)) {
      return ResultOr.error(ErrorKeys.folderTitleExists);
    }
    await addFolder(folder);
    return ResultOr.success(null);
  }

  Folder? getFolderById(int? id) =>
      foldersOrEmpty.where((e) => e.id == id).firstOrNull;
}
