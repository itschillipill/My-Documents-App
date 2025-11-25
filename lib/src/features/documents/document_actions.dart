import 'package:flutter/material.dart';
import 'package:my_documents/src/core/extensions/extensions.dart';
import 'package:my_documents/src/utils/sevices/file_service.dart';
import 'package:my_documents/src/utils/sevices/message_service.dart';

import 'model/document.dart';
import 'widgets/change_document_details.dart';

abstract class DocumentAction {
  Future<void> call();
}

class ChangeDetails$DocumentAction extends DocumentAction {
  final BuildContext context;
  final Document document;

  ChangeDetails$DocumentAction({required this.context, required this.document});

  @override
  Future<void> call() async {
    await Navigator.push(
      context,
      ChangeDocumentDetails.route(
        oldParams: (
          title: document.title,
          isFavorite: document.isFavorite,
          folder: context.deps.foldersCubit.getFolderById(document.folderId),
        ),
        onUpdate: (p0) {
          context.deps.documentsCubit.updateDocument(
            document.copyWith(
              title: p0.title ?? document.title,
              isFavorite: p0.isFavorite ?? document.isFavorite,
              folderId: p0.folder?.id ?? document.folderId,
            ),
          );
        },
      ),
    );
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
    controller.dispose();
    if (newName == null) return;
    debugPrint("Renaming ${document.title} to $newName");
    // await context.read<DocumentsCubit>().renameDocument(document.id, newName);
  }
}

class Delete$DocumentAction extends DocumentAction {
  final Document document;
  final BuildContext context;

  Delete$DocumentAction({required this.document, required this.context});

  @override
  Future<void> call() async {
    try {
      final confirm = await MessageService.$confirmAction(
        title: "Delete",
        message:
            "This will delete the document permanently. Including all versions.",
      );
      if (!confirm) return;
      debugPrint("Deleting ${document.title}");
      if (context.mounted) {
        Navigator.pop(context);
        await context.deps.documentsCubit.deleteDocument(document);
      }
    } catch (e) {
      MessageService.showErrorSnack(e.toString());
    }
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
