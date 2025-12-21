import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_documents/src/features/documents/cubit/documents_cubit.dart';
import 'package:my_documents/src/features/folders/cubit/folders_cubit.dart';
import 'package:my_documents/src/features/documents/widgets/document_card.dart';
import '../features/documents/model/document.dart';
import '../features/folders/model/folder.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = "";

  void _searchFor(String value) {
    setState(() {
      _query = value.toLowerCase();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DocumentsCubit, DocumentsState>(
      builder: (context, documentsState) {
        if ((documentsState is! DocumentsLoaded)) return SizedBox.shrink();
        return BlocBuilder<FoldersCubit, FoldersState>(
          builder: (context, foldersState) {
            if ((foldersState is! FoldersLoaded)) return SizedBox.shrink();
            final results =
                documentsState.documents
                    .where((doc) => doc.title.toLowerCase().contains(_query))
                    .toList();

            final Map<int?, List<Document>> grouped = {};
            for (var doc in results) {
              grouped.putIfAbsent(doc.folderId, () => []).add(doc);
            }
            return Scaffold(
              appBar: AppBar(
                title: Text(
                  "Search",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                centerTitle: true,
              ),
              body: SafeArea(
                minimum: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      onChanged: _searchFor,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: "Search documents...",
                        suffixIcon:
                            _searchController.text.isNotEmpty
                                ? IconButton(
                                  onPressed:
                                      () => setState(() {
                                        _searchController.clear();
                                        _query = "";
                                      }),
                                  icon: const Icon(Icons.cancel_outlined),
                                )
                                : null,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child:
                          _query.isEmpty
                              ? const Center(child: Text("Type to search..."))
                              : grouped.isEmpty
                              ? const Center(child: Text("No results found"))
                              : ListView(
                                children:
                                    grouped.entries.map((entry) {
                                      final folderName =
                                          entry.key == null
                                              ? Folder.noFolder.name
                                              : foldersState.folders
                                                  .firstWhere(
                                                    (f) => f.id == entry.key,
                                                    orElse:
                                                        () => Folder(
                                                          id: entry.key!,
                                                          name:
                                                              "Unknown Folder",
                                                        ),
                                                  )
                                                  .name;

                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (folderName !=
                                              Folder.noFolder.name)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 8.0,
                                                  ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                spacing: 5,
                                                children: [
                                                  Icon(Icons.folder),
                                                  Text(
                                                    folderName,
                                                    style:
                                                        Theme.of(
                                                          context,
                                                        ).textTheme.titleMedium,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ...entry.value.map(
                                            (doc) =>
                                                DocumentCard(document: doc),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                              ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
