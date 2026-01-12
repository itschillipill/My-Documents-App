import 'dart:io' show File;

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:my_documents/src/core/result_or.dart';
import 'package:my_documents/src/utils/sevices/file_service.dart';
import 'package:my_documents/src/utils/sevices/observer.dart';
import '../../../core/model/errors.dart';
import '../../../data/data_sourse.dart';

import 'package:my_documents/src/features/documents/model/document.dart';
part 'documents_state.dart';

class DocumentsCubit extends Cubit<DocumentsState> {
  final DataSource dataSource;

  DocumentsCubit({required this.dataSource}) : super(DocumentsState.initial()) {
    MyBlocObserver.instance.onCreate(name);
    loadData();
  }

  String get name => "DocumentsCubit";

  @override
  void emit(DocumentsState state) {
    MyBlocObserver.instance.onTransition(name, this.state, state);
    super.emit(state);
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    super.onError(error, stackTrace);
    MyBlocObserver.instance.onError(name, error, stackTrace);
  }

  @override
  Future<void> close() {
    MyBlocObserver.instance.onClose(name);
    return super.close();
  }

  List<Document> get documentsOrEmpty => state.documents ?? [];

  Future<void> loadData() async {
    emit(
      DocumentsState.processing(
        documents: state.documents,
        message: "Loading data",
      ),
    );
    try {
      final documents = await dataSource.getAllDocuments();
      emit(
        DocumentsState.processing(documents: documents, message: "Data loaded"),
      );
    } catch (e, s) {
      emit(
        DocumentsState.failed(
          documents: state.documents,
          error: e,
          message: "Error loading data",
          stackTrace: s,
        ),
      );
      MyBlocObserver.instance.onError(name, e, s);
    } finally {
      emit(DocumentsState.idle(documents: state.documents));
    }
  }

  Future<void> restoreDocuments(List<Document> documents) async {}

  Future<void> addDocument(Document document) async {
    emit(
      DocumentsState.processing(
        documents: state.documents,
        message: "Adding document",
      ),
    );
    try {
      Document newDocument = await dataSource.insertDocument(document);
      emit(
        DocumentsState.processing(
          documents: [...?state.documents, newDocument],
          message: "Document added successfully",
        ),
      );
    } catch (e, s) {
      emit(
        DocumentsState.failed(
          documents: state.documents,
          message: "Error adding document",
          error: e,
          stackTrace: s,
        ),
      );
      MyBlocObserver.instance.onError(name, e, s);
    } finally {
      emit(DocumentsState.idle(documents: state.documents));
    }
  }

  Future<void> deleteDocuments(List<int> documentIds) async {
    emit(
      DocumentsState.processing(
        documents: state.documents,
        message: "Deleting documents",
      ),
    );
    try {
      final documentsToDelete = getDocumentsByIds(documentIds);
      final res = await dataSource.deleteDocumentsByIds(documentIds);
      if (!res) return;

      await FileService.deleteDocumentsFiles(
        documentsToDelete,
        documentsOrEmpty,
      );

      final updatedDocuments =
          state.documents?.where((d) => !documentIds.contains(d.id)).toList();

      emit(
        DocumentsState.processing(
          documents: updatedDocuments,
          message: "Documents deleted successfully",
        ),
      );
    } catch (e, s) {
      emit(
        DocumentsState.failed(
          documents: state.documents,
          message: "Error deleting documents",
          error: e,
          stackTrace: s,
        ),
      );
      MyBlocObserver.instance.onError(name, e, s);
    } finally {
      emit(DocumentsState.idle(documents: state.documents));
    }
  }

  Future<void> updateDocument(Document updatedDocument) async {
    emit(
      DocumentsState.processing(
        documents: state.documents,
        message: "Updating document",
      ),
    );
    try {
      final res = await dataSource.updateDocument(updatedDocument);
      if (!res) return;
      final updatedDocuments =
          state.documents
              ?.map(
                (doc) => doc.id == updatedDocument.id ? updatedDocument : doc,
              )
              .toList();

      emit(
        DocumentsState.processing(
          documents: updatedDocuments,
          message: "Document updated successfully",
        ),
      );
    } catch (e, s) {
      emit(
        DocumentsState.failed(
          documents: state.documents,
          message: "Error updating document",
          error: e,
          stackTrace: s,
        ),
      );
      MyBlocObserver.instance.onError(name, e, s);
    } finally {
      emit(DocumentsState.idle(documents: state.documents));
    }
  }

  Future<void> addNewVersion(int documentId, DocumentVersion version) async {
    emit(
      DocumentsState.processing(
        documents: state.documents,
        message: "Adding new version",
      ),
    );

    try {
      // Добавляем версию в базу
      final newVersion = await dataSource.addNewVersion(documentId, version);

      // Получаем текущий документ
      final oldDocument = getDocumentById(documentId);
      if (oldDocument == null) return;

      // Создаём новый объект документа с обновлённой версией
      final updatedDocument = oldDocument.copyWith(
        currentVersionId: newVersion.id,
        versions: [...oldDocument.versions, newVersion],
      );

      // Обновляем список документов
      final updatedDocuments =
          state.documents
              ?.map((doc) => doc.id == documentId ? updatedDocument : doc)
              .toList();

      emit(
        DocumentsState.processing(
          documents: updatedDocuments,
          message: "New version added successfully",
        ),
      );
    } catch (e, s) {
      emit(
        DocumentsState.failed(
          documents: state.documents,
          message: "Error adding new version",
          error: e,
          stackTrace: s,
        ),
      );
      MyBlocObserver.instance.onError(name, e, s);
    } finally {
      emit(DocumentsState.idle(documents: state.documents));
    }
  }

  Document? getDocumentById(int documentId) =>
      documentsOrEmpty.where((e) => e.id == documentId).firstOrNull;

  DocumentVersion? getDocumentVersionByDocumentId({
    required int documentId,
    int? versionId,
  }) {
    final document = getDocumentById(documentId);
    if (document == null) return null;
    if (versionId == null) return document.versions.first;
    return document.versions.where((e) => e.id == versionId).firstOrNull ??
        document.versions.firstOrNull;
  }

  List<Document> getDocumentsByIds(List<int> documentIds) {
    return documentsOrEmpty.where((e) => documentIds.contains(e.id)).toList();
  }

  Future<ResultOr<String>> saveDocument({
    required String title,
    required String? originalPath,
    bool isFavorite = false,
    int? folderId,
    String? comment,
    DateTime? expirationDate,
  }) async {
    if (title.isEmpty) return ResultOr.error(ErrorKeys.enterTitle);

    if (originalPath == null) return ResultOr.error(ErrorKeys.selectFile);

    if (documentsOrEmpty.any((element) => element.title == title)) {
      return ResultOr.error(ErrorKeys.documentTitleExists);
    }

    final isValidSize = await FileService.validateFileSize(originalPath);
    if (!isValidSize) return ResultOr.error(ErrorKeys.reachedMaxSize);

    try {
      final safePath = await FileService.saveFileToAppDir(originalPath);

      final doc = Document(
        id: 0,
        title: title,
        folderId: folderId,
        isFavorite: isFavorite,
        createdAt: DateTime.now(),
        currentVersionId: null,
        versions: [
          DocumentVersion(
            id: 0,
            documentId: 0,
            filePath: safePath,
            uploadedAt: DateTime.now(),
            comment: comment,
            expirationDate: expirationDate,
          ),
        ],
      );

      await addDocument(doc);

      return ResultOr.success(safePath);
    } catch (e, s) {
      MyBlocObserver.instance.onError(name, e, s, message: "Error saving file");
      return ResultOr.error(ErrorKeys.errorSavingFile);
    }
  }

  Future<int> getAllDocumentsSize() async {
    try {
      final uniquePaths =
          documentsOrEmpty
              .expand((doc) => doc.versions.map((v) => v.filePath))
              .toSet();

      final sizes = await Future.wait(
        uniquePaths.map((path) async {
          final file = File(path);
          if (await file.exists()) {
            return await file.length();
          }
          return 0;
        }),
      );

      final totalSize = sizes.fold<int>(0, (sum, size) => sum + size);

      return totalSize;
    } catch (e, s) {
      MyBlocObserver.instance.onError(
        name,
        e,
        s,
        message: "Error getting all documents size",
      );
      return 0;
    }
  }

  Future<void> debugAllFiles() async {
    final allVersions = documentsOrEmpty.expand((doc) => doc.versions);
    for (final v in allVersions) {
      final file = File(v.filePath);
      debugPrint(
        "--------------------------------------------------------------------",
      );
      if (await file.exists()) {
        debugPrint("${v.filePath}: ${await file.length() / (1024 * 1024)} MB");
      } else {
        debugPrint("${v.filePath}: not found");
      }
    }
  }

  void throwError(String message) => emit(
    DocumentsState.failed(
      documents: state.documents,
      message: message,
      error: Exception(message),
    ),
  );
}
