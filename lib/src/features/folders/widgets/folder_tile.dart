import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_documents/src/core/extensions/extensions.dart';
import 'package:my_documents/src/features/documents/cubit/documents_cubit.dart';

import '../model/folder.dart';
import '../pages/folder_view_page.dart';

class FolderTile extends StatelessWidget {
  final Folder folder;
  const FolderTile({super.key, required this.folder});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Material(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: () {
            Navigator.push(context, FolderViewPage.route(folder: folder));
          },
          child: ListTile(
            leading: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.folder_rounded),
            ),
            title: Text(
              folder.name,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: _getCount(context, folder),
          ),
        ),
      ),
    );
  }
}

Widget _getCount(BuildContext context, Folder folder) {
  return BlocBuilder<DocumentsCubit, DocumentsState>(
    bloc: context.deps.documentsCubit,
    builder: (context, state) {
      return Text(
        "${folder.getDocuments(state.documents ?? []).length} ${context.l10n.documents}",
        style: Theme.of(context).textTheme.bodySmall,
      );
    },
  );
}
