import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_documents/src/app/features/folders/cubit/folders_cubit.dart';
import 'package:my_documents/src/app/features/folders/model/folder.dart';

typedef FolderActionHandler = Future<void> Function(
  BuildContext context,
  Folder document,
);
enum FolderMenuActions {
  rename(_rename),
  delete(_delete);
  final FolderActionHandler call;
  const FolderMenuActions(this.call);
}

Future<void> _rename(BuildContext context, Folder folder) async {
  final name = await showDialog<String>(
    context: context,
    builder: (context) {
      final controller = TextEditingController(text: folder.name);
      return AlertDialog(
        title: Text("Rename Folder"),
        content: TextField(
          controller: controller,
          autofocus: true,
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
      );
    },
  );
  if (name != null&&context.mounted) {
    context.read<FoldersCubit>().updateFolder(folder.copyWith(name: name));
  }
  }
Future<void> _delete(BuildContext context, Folder folder) async {
  final cubit = context.read<FoldersCubit>();
  if (await showDialog<bool>(
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
      false) {
    cubit.deleteFolder(folder.id);
    Navigator.pop(context);
  }
}