import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_documents/src/features/documents/cubit/documents_cubit.dart';
import 'package:my_documents/src/features/folders/cubit/folders_cubit.dart';
import 'package:my_documents/src/features/folders/model/folder.dart';

typedef FolderActionHandler =
    Future<void> Function(BuildContext context, Folder document);

enum FolderMenuActions {
  rename(_rename),
  delete(_delete);

  final FolderActionHandler call;
  const FolderMenuActions(this.call);
}

Future<void> _rename(BuildContext context, Folder folder) async {
  final controller = TextEditingController(text: folder.name);
  final name = await showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Rename Folder"),
        content: TextField(controller: controller, autofocus: true),
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
      );
    },
  );
  controller.dispose();
  if (name != null && context.mounted) {
    context.read<FoldersCubit>().updateFolder(folder.copyWith(name: name));
  }
}

Future<void> _delete(BuildContext context, Folder folder) async {
  final foldersCubit = context.read<FoldersCubit>();
  final documentsCubit = context.read<DocumentsCubit>();

  final confirmed =
      await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Delete Folder"),
            content: Text("Are you sure you want to delete this folder?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text("Delete"),
              ),
            ],
          );
        },
      ) ??
      false;

  if (confirmed) {
    await foldersCubit.deleteFolder(folder.id).then((v) async {
      await documentsCubit.loadData();
    });
    if (context.mounted) Navigator.pop(context);
  }
}
