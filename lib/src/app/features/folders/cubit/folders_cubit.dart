import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/data_sourse.dart';

import 'package:my_documents/src/app/features/folders/model/folder.dart';
part 'folders_state.dart';

class FoldersCubit extends Cubit<FoldersState> {
  final DataSource dataSource;

  FoldersCubit({required this.dataSource}) : super(FoldersInitial()) {
    loadData();
  }

  Future<void> loadData() async {
    emit(FoldersLoading());
    try {
      final folders = await dataSource.getAllFolders();
      emit(FoldersLoaded(folders: folders));
    } catch (e) {
      emit(FoldersError(e.toString()));
    }
  }

  Future<void> addFolder(Folder folder) async {
    try {
      await dataSource.insertFolder(folder);
      await loadData();
    } catch (e) {
      emit(FoldersError(e.toString()));
    }
  }

  Future<void> deleteFolder(int id) async {
    try {
      await dataSource.deleteFolder(id);
      await loadData();
    } catch (e) {
      emit(FoldersError(e.toString()));
    }
  }

  Future<void> updateFolder(Folder folder) async {
    try {
      await dataSource.updateFolder(folder);
      await loadData();
    } catch (e) {
      emit(FoldersError(e.toString()));
    }
  }
}
