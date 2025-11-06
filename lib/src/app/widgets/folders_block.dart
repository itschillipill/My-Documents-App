import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_documents/src/app/extensions/extensions.dart';
import 'package:my_documents/src/app/features/documents/cubit/documents_cubit.dart';
import 'package:my_documents/src/app/features/folders/cubit/folders_cubit.dart';
import 'package:my_documents/src/app/features/folders/pages/folder_view_page.dart';

class FoldersBlock extends StatelessWidget {
  const FoldersBlock({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FoldersCubit, FoldersState>(
      buildWhen: (_, current) => current is FoldersLoaded,
      builder: (context, foldersState) {
        if (foldersState is FoldersLoaded) {
          if (foldersState.folders.isEmpty) return const SizedBox.shrink();
          return BlocBuilder<DocumentsCubit, DocumentsState>(
            builder: (context, documentsState) {
              return ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: foldersState.folders.length,
                itemBuilder: (context, index) {
                  final folder = foldersState.folders[index];
                  final documents =
                      documentsState is DocumentsLoaded
                          ? folder.getDocuments(documentsState.documents)
                          : [];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child:
                        ListTile(
                          leading: const Icon(Icons.folder),
                          title: Text(folder.name),
                          subtitle: Text("${documents.length} documents"),
                          trailing: const Icon(Icons.arrow_forward_ios_sharp),
                          onTap: () {
                            Navigator.push(
                              context,
                              FolderViewPage.route(folder: folder),
                            );
                          },
                        ).withBorder(),
                  );
                },
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
