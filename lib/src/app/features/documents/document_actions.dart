import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_documents/src/utils/sevices/message_service.dart';

import '../folders/pages/select_folder_page.dart';
import 'cubit/documents_cubit.dart';
import 'model/document.dart';

/// Базовый класс для всех действий с документом
abstract class DocumentAction {
  const DocumentAction();
  Future<void> call();
}

/// Действие: изменить папку документа
class ChangeFolder$DocumentAction extends DocumentAction {
  final BuildContext context;
  final Document document;

  ChangeFolder$DocumentAction({required this.context, required this.document});

  @override
  Future<void> call() async {
    final folder = await Navigator.push(context, SelectFolderPage.route());
    if (folder != null && context.mounted) {
      await context.read<DocumentsCubit>().updateDocument(
        document.copyWith(folderId: folder.id),
      );
    }
  }
}

/// Действие: переименовать документ
class Rename$DocumentAction extends DocumentAction {
  final BuildContext context;
  final Document document;

  Rename$DocumentAction({required this.context, required this.document});

  @override
  Future<void> call() async {
    final controller = TextEditingController(text: document.title);
    final newName = await MessageService.showDialogGlobal<String>(
      AlertDialog(
        title: Text("Rename Document"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: "Enter new name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text("Save"),
          ),
        ],
      ),
    );
    if (newName == null) return;
    debugPrint("Renaming ${document.title} to $newName");
    // Тут можно вызвать cubit для изменения имени
    // await context.read<DocumentsCubit>().renameDocument(document.id, newName);
  }
}

/// Действие: удалить документ
class Delete$DocumentAction extends DocumentAction {
  final Document document;
  final DocumentsCubit cubit;

  Delete$DocumentAction({required this.document, required this.cubit});

  @override
  Future<void> call() async {
    debugPrint("Deleting ${document.title}");
    await cubit.deleteDocument(document.id);
  }
}

/// Действие: поделиться документом
class Share$DocumentAction extends DocumentAction {
  final Document document;

  Share$DocumentAction({required this.document});

  @override
  Future<void> call() async {
    debugPrint("Sharing ${document.title}");
    // Можно открыть share диалог
  }
}
