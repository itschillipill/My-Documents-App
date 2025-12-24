import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_documents/src/core/extensions/extensions.dart';
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
    // ⬇️ Получаем только нужные данные
    final documents = context.select<DocumentsCubit, List<Document>?>(
      (cubit) => cubit.documentsOrEmpty,
    );

    final folders = context.select<FoldersCubit, Map<int?, Folder>?>(
      (cubit) => {
        for (final f in cubit.foldersOrEmpty) f.id: f,
        null: Folder.noFolder,
      },
    );

    // ⬇️ Если данные ещё не готовы
    if (documents == null || folders == null) {
      return const SizedBox.shrink();
    }

    // ⬇️ Поиск
    final results =
        documents
            .where((doc) => doc.title.toLowerCase().contains(_query))
            .toList();

    // ⬇️ Группировка по папкам
    final Map<int?, List<Document>> grouped = {};
    for (final doc in results) {
      (grouped[doc.folderId] ??= []).add(doc);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n.search,
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
                hintText: context.l10n.searchDocumentsHint,
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.cancel_outlined),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _query = "";
                            });
                          },
                        )
                        : null,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child:
                  _query.isEmpty
                      ? Center(child: Text(context.l10n.typeToSearch))
                      : grouped.isEmpty
                      ? Center(child: Text(context.l10n.noDocumentsFound))
                      : ListView(
                        children:
                            grouped.entries.map((entry) {
                              final folderName =
                                  folders[entry.key]?.name ??
                                  context.l10n.unknownFolder;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (folderName != Folder.noFolder.name)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.folder),
                                          const SizedBox(width: 5),
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
                                    (doc) => DocumentCard(document: doc),
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
  }
}
