import 'package:flutter/material.dart';
import 'package:my_documents/src/core/extensions/extensions.dart';
import 'package:my_documents/src/features/folders/model/folder.dart';
import 'package:my_documents/src/utils/sevices/message_service.dart';

import '../../core/model/actions.dart';

typedef FolderActions = MyActions; 

class Rename$FolderAction extends FolderActions {
  final BuildContext context;
  final Folder folder;

  Rename$FolderAction({required this.context, required this.folder});

  @override
  Future<void> call() async {
  final name = await MessageService.showDialogGlobal((ctx){
      final controller = TextEditingController(text: folder.name);
       return AlertDialog(
        title: Text(ctx.l10n.rename),
        content: TextField(
          maxLength: 20,
          controller: controller,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(ctx.l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isEmpty || newName == folder.name)return;
              Navigator.pop(context, controller.text);
            },
            child: Text(ctx.l10n.save),
          ),
        ],
      );
    });
  if (name != null && context.mounted) {
    context.deps.foldersCubit.updateFolder(folder.copyWith(name: name));
    Navigator.pop(context);
  }
  }
}

class Delete$FolderAction extends FolderActions {
   final BuildContext context;
  final Folder folder;

  Delete$FolderAction({required this.context, required this.folder});

  @override
  Future<void> call() async {
final foldersCubit = context.deps.foldersCubit;

  final confirmed = await MessageService.$confirmAction(
    title: context.l10n.delete,
  );

  if (confirmed) {
    await foldersCubit.deleteFolder(folder.id).then((_) async {
      await foldersCubit.loadData();
    });
    if (context.mounted) Navigator.pop(context);
  }
  }
}