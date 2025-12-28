import 'package:flutter/material.dart';
import 'package:my_documents/src/core/extensions/extensions.dart';
import 'package:my_documents/src/utils/sevices/file_service.dart';
import 'package:my_documents/src/utils/sevices/message_service.dart';

import '../../core/model/actions.dart';
import 'model/document.dart';
import 'widgets/change_document_details.dart';

typedef DocumentAction = MyActions;

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
        title: Text(ctx.l10n.rename),
        content: TextField(
          controller: controller,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(ctx.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: Text(ctx.l10n.save),
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
  final List<int> documentsIds;
  final BuildContext context;

  Delete$DocumentAction({required this.documentsIds, required this.context});

  @override
  Future<void> call() async {
    try {
      final confirm = await MessageService.$confirmAction(
        title: context.l10n.delete,
        message:context.l10n.willDeleteAllVersions,
      );
      if (!confirm) return;
      debugPrint("Deleting ${documentsIds.length} documents");
      if (context.mounted) {
        Navigator.pop(context);
        await context.deps.documentsCubit.deleteDocuments(documentsIds);
      }
    } catch (e) {
      MessageService.showErrorSnack(e.toString());
    }
  }
}

class Share$DocumentAction extends DocumentAction {
  final List<Document> documents;
  final BuildContext context;


  Share$DocumentAction({required this.documents, required this.context});

  @override
  Future<void> call() async {
    final paths = documents.map((doc) => doc.currentVersion.filePath).toList();
    debugPrint("Sharing $paths");
   final err= await FileService.shareFiles(paths);
   if(err!=null&&context.mounted){
    MessageService.showErrorSnack(err.getMessage(context));
   }
  }
}
