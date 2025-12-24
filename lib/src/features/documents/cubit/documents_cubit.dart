import 'dart:io' show File;

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:flutter/material.dart' show BuildContext;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_documents/src/utils/sevices/file_service.dart';
import 'package:my_documents/src/utils/sevices/message_service.dart';
import '../../../data/data_sourse.dart';

import 'package:my_documents/src/features/documents/model/document.dart';
part 'documents_state.dart';

class DocumentsCubit extends Cubit<DocumentsState> {
  final DataSource dataSource;

  DocumentsCubit({required this.dataSource}) : super(DocumentsInitial()) {
    loadData();
  }

  List<Document> get documentsOrEmpty {
    if (state case DocumentsLoaded s) return s.documents;
    return const [];
  }

  Future<void> loadData() async {
    emit(DocumentsLoading());
    try {
      final documents = await dataSource.getAllDocuments();
      emit(DocumentsLoaded(documents: documents));
      if (kDebugMode) {
        MessageService.showSuccessSnack("Documents loaded successfully");
      }
    } catch (e) {
      emit(DocumentsError(e.toString()));
    }
  }

  Future<void> addDocument(Document document) async {
    try {
      await dataSource.insertDocument(document);
      await loadData();
    } catch (e) {
      emit(DocumentsError(e.toString()));
    }
  }

  Future<bool> deleteDocument(Document document) async {
    try {
      final res = await dataSource.deleteDocument(document.id);
      if (res) {
        await loadData();
        await FileService.deleteDocumentsFiles([document], documentsOrEmpty);
      }
      return res;
    } catch (e) {
      emit(DocumentsError(e.toString()));
      return false;
    }
  }

  Future<void> deleteDocuments(List<int> documentIds) async {
    try {
      final documentsToDelete = getDocumentsByIds(documentIds);

      final res = await dataSource.deleteDocumentsByIds(documentIds);
      if (!res) return;

      await FileService.deleteDocumentsFiles(
        documentsToDelete,
        documentsOrEmpty,
      );
      await loadData();
    } catch (e) {
      emit(DocumentsError(e.toString()));
    }
  }

  Future<void> shareDocuments(
    List<int> documentIds,
    BuildContext context,
  ) async {
    try {
      List<String> paths = [];
      final documents = getDocumentsByIds(documentIds);
      for (final doc in documents) {
        paths.add(
          doc.versions.firstWhere((v) => doc.currentVersionId == v.id).filePath,
        );
      }
      await FileService.shareFiles(paths, context);
    } catch (e) {
      emit(DocumentsError(e.toString()));
    }
  }

  Future<void> updateDocument(Document updatedDocument) async {
    try {
      await dataSource.updateDocument(updatedDocument);
      await loadData();
    } catch (e) {
      emit(DocumentsError(e.toString()));
    }
  }

  Future<void> addNewVersion(int documentId, DocumentVersion version) async {
    try {
      await dataSource.addNewVersion(documentId, version);
      await loadData();
    } catch (e) {
      emit(DocumentsError(e.toString()));
    }
  }

  Document? getDocumentById(int documentId) =>
      documentsOrEmpty.where((e) => e.id == documentId).firstOrNull;

  DocumentVersion? getDocumentVersionByDocumentId({
    required int documentId,
    int? versionId,
  }) {
    final document = getDocumentById(documentId);
    if (document == null) throw Exception("Document not found");
    if (versionId == null) return document.versions.first;
    return document.versions.where((e) => e.id == versionId).firstOrNull ??
        document.versions.firstOrNull;
  }

  List<Document> getDocumentsByIds(List<int> documentIds) {
    return documentsOrEmpty.where((e) => documentIds.contains(e.id)).toList();
  }

  Future<void> saveDocument({
    required String title,
    required String? originalPath,
    bool isFavorite = false,
    int? folderId,
    String? comment,
    DateTime? expirationDate,
    Function()? onSaved,
  }) async {
    if (title.isEmpty || originalPath == null) {
      MessageService.showSnackBar("Please enter title and choose a file");
      return;
    }

    if (documentsOrEmpty.any((element) => element.title == title)) {
      MessageService.showSnackBar("Document with this title already exists");
      return;
    }

    final isValidSize = await FileService.validateFileSize(originalPath);
    if (!isValidSize) {
      MessageService.showSnackBar("File is too large (max 50 MB)");
      return;
    }

    try {
      final safePath = await FileService.saveFileToAppDir(originalPath);

      final doc = Document(
        id: 0,
        title: title,
        folderId: folderId,
        isFavorite: isFavorite,
        createdAt: DateTime.now(),
        currentVersionId: 1,
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

      onSaved?.call();
    } catch (e) {
      debugPrint("Error saving file: $e");
      MessageService.showSnackBar("Error saving file: $e");
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
    } catch (e) {
      debugPrint("Error getting all documents size: $e");
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

  void throwError(String message) => emit(DocumentsError(message));
}
