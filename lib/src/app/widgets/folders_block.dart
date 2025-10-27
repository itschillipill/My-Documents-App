import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_documents/src/app/features/documents/cubit/documents_cubit.dart';
import 'package:my_documents/src/app/features/folders/cubit/folders_cubit.dart';
import 'package:my_documents/src/app/features/folders/pages/folder_view_page.dart';
import 'border_box.dart';

class FoldersBlock extends StatelessWidget {
  const FoldersBlock({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FoldersCubit, FoldersState>(
      buildWhen: (previous, current) => current is FoldersLoaded,
      builder: (context, state) {
        if (state is FoldersLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is FoldersError) {
          return const Center(child: Text("Error loading folders"));
        }
        if (state is FoldersLoaded) {
          if (state.folders.isEmpty) return const SizedBox.shrink();

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: 5,
              children: [
                Text(
                  "Folders",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                if (state.folders.isNotEmpty)
                  ListView.builder(
                    itemCount: state.folders.length,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final folder = state.folders[index];
                      return BlocBuilder<DocumentsCubit, DocumentsState>(
                        buildWhen:
                            (previous, current) => current is DocumentsLoaded,
                        builder: (context, documentsState) {
                          final documents =
                              documentsState is DocumentsLoaded
                                  ? folder.getDocuments(
                                    documentsState.documents,
                                  )
                                  : [];
                          return Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: BorderBox(
                              child: ListTile(
                                leading: const Icon(Icons.folder),
                                title: Text(folder.name),
                                subtitle: Text("${documents.length} documents"),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios_sharp,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    FolderViewPage.route(folder: folder),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                  )
                else
                  const Center(child: Text("No folders here, yet!")),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
