import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_documents/src/utils/sevices/file_service.dart';
import 'package:my_documents/src/utils/sevices/message_service.dart';

import '../folders/pages/select_folder_page.dart';
import 'cubit/documents_cubit.dart';
import 'model/document.dart';

abstract class DocumentAction {
  const DocumentAction();
  Future<void> call();
}

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

class Rename$DocumentAction extends DocumentAction {
  final BuildContext context;
  final Document document;

  Rename$DocumentAction({required this.context, required this.document});

  @override
  Future<void> call() async {
    final controller = TextEditingController(text: document.title);
    final newName = await MessageService.showDialogGlobal<String>(
      (ctx) => AlertDialog(
        title: Text("Rename Document"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: "Enter new name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: Text("Save"),
          ),
        ],
      ),
    );
    if (newName == null) return;
    debugPrint("Renaming ${document.title} to $newName");
    // await context.read<DocumentsCubit>().renameDocument(document.id, newName);
  }
}

class Delete$DocumentAction extends DocumentAction {
  final Document document;
  final DocumentsCubit cubit;

  Delete$DocumentAction({required this.document, required this.cubit});

  @override
  Future<void> call() async {
    try {
      final confirm = await MessageService.$confirmAction(title: "Delete");
      if (!confirm) return;
      debugPrint("Deleting ${document.title}");
    } catch (e) {
      MessageService.showErrorSnack(e.toString());
    }

    //   await cubit.deleteDocument(document.id);
  }
}

class Share$DocumentAction extends DocumentAction {
  final String path;

  Share$DocumentAction({required this.path});

  @override
  Future<void> call() async {
    debugPrint("Sharing $path");
    await FileService.shareFile(path);
  }
}
