import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_documents/src/core/extensions/extensions.dart';
import 'package:my_documents/src/features/documents/cubit/documents_cubit.dart';
import 'package:my_documents/src/features/folders/cubit/folders_cubit.dart';

import '../features/documents/model/document.dart';
import '../features/folders/model/folder.dart';
import '../features/folders/pages/folder_view_page.dart';

class FoldersBlock extends StatelessWidget {
  const FoldersBlock({super.key});

  @override
  Widget build(BuildContext context) {
    final folders = context.select<FoldersCubit, List<Folder>>(
      (cubit) => cubit.foldersOrEmpty,
    );

    if (folders.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final documents = context.select<DocumentsCubit, List<Document>>(
      (cubit) => cubit.documentsOrEmpty,
    );

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        semanticIndexOffset: 1,
        (context, index) {
          // Заголовок
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                context.l10n.folders,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            );
          }

          final folder = folders[index - 1];

          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Material(
               color: Theme.of(context).cardColor,
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                leading: const Icon(Icons.folder),
                title: Text(folder.name),
                onTap: () => Navigator.push(context, FolderViewPage.route(folder: folder),),
                subtitle: Text("${folder.getDocuments(documents).length} ${context.l10n.items}"),
                trailing: const Icon(Icons.arrow_forward_ios_sharp),
              ),
            ),
          );
        },
        childCount: folders.length + 1,
      ),
    );
  }
}
