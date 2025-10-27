import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/data_sourse.dart';

import 'package:my_documents/src/app/features/documents/model/document.dart';
part 'documents_state.dart';

class DocumentsCubit extends Cubit<DocumentsState> {
  final DataSource dataSource;

  DocumentsCubit({required this.dataSource}) : super(DocumentsInitial()) {
    loadData();
  }

  Future<void> loadData() async {
    emit(DocumentsLoading());
    try {
      final documents = await dataSource.getAllDocuments();
      emit(DocumentsLoaded(documents: documents));
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

  Future<void> deleteDocument(int documentId) async {
    try {
      await dataSource.deleteDocument(documentId);
      await loadData();
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

  Document? getDocumentById(int documentId){
    if (state is DocumentsLoaded) {
      return (state as DocumentsLoaded).documents
    .where((e) => e.id == documentId)
    .cast<Document?>()
    .firstOrNull;
    }
    return null;
  }

  DocumentVersion? getDocumentVersionByDocumentId({required int documentId, int? versionId}){
    final document = getDocumentById(documentId);
    if (document == null) throw Exception("Document not found");
    if (versionId == null) return document.versions.first;
    return document.versions.where((e) => e.id == versionId).cast<DocumentVersion?>()
    .firstOrNull;
  }
    
  
}
