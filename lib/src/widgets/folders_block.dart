import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_documents/src/core/extensions/extensions.dart';
import 'package:my_documents/src/features/documents/cubit/documents_cubit.dart';
import 'package:my_documents/src/features/folders/cubit/folders_cubit.dart';
import 'package:my_documents/src/features/folders/pages/folder_view_page.dart';

import '../features/documents/model/document.dart';
import '../features/folders/model/folder.dart';

class FoldersBlock extends StatelessWidget {
  const FoldersBlock({super.key});

  @override
  Widget build(BuildContext context) {
    // Слушаем только folders
    final folders = context.select<FoldersCubit, List<Folder>>(
      (cubit) => cubit.foldersOrEmpty,
    );
    if (folders.isEmpty) return const SizedBox.shrink();

    // Слушаем только документы
    final documents = context.select<DocumentsCubit, List<Document>>(
      (cubit) => cubit.documentsOrEmpty,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            context.l10n.folders,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Column(
          children: [
            ...folders.map((folder) {
              final folderDocuments = folder.getDocuments(documents);

              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: ListTile(
                  tileColor: Theme.of(context).cardColor,
                  leading: const Icon(Icons.folder),
                  title: Text(folder.name),
                  subtitle: Text("${folderDocuments.length} ${context.l10n.items}"),
                  trailing: const Icon(Icons.arrow_forward_ios_sharp),
                  onTap: () {
                    Navigator.push(
                      context,
                      FolderViewPage.route(folder: folder),
                    );
                  },
                ),
              );
            }),
          ],
        ),
      ],
    );
  }
}
