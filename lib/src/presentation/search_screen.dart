import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_documents/src/core/extensions/extensions.dart';
import 'package:my_documents/src/features/documents/cubit/documents_cubit.dart';
import 'package:my_documents/src/features/documents/model/document.dart';
import 'package:my_documents/src/features/documents/presentation/document_view_screen.dart';
import 'package:my_documents/src/features/documents/presentation/widgets/document_card.dart';
import 'package:my_documents/src/features/folders/cubit/folders_cubit.dart';
import 'package:my_documents/src/features/folders/model/folder.dart';
import 'package:my_documents/src/features/folders/presentation/widgets/folder_tile.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = "";

  void _searchFor(String value) {
    setState(() {
      _query = value.trim().toLowerCase();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Iterable<Document> filterDocuments(List<Document> documents) {
    if (_query.isEmpty) return [];
    return documents.where((doc) => doc.title.toLowerCase().contains(_query));
  }

  Iterable<Folder> filterFolders(List<Folder> folders) {
    if (_query.isEmpty) return [];
    return folders.where(
      (folder) => folder.name.toLowerCase().contains(_query),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: _buildAppBar(),
      body: BlocSelector<DocumentsCubit, DocumentsState, Iterable<Document>>(
        bloc: context.deps.documentsCubit,
        selector: (s) => filterDocuments(s.documents ?? []),
        builder: (context, filteredDocuments) {
          return BlocSelector<FoldersCubit, FoldersState, Iterable<Folder>>(
            bloc: context.deps.foldersCubit,
            selector: (s) => filterFolders(s.folders ?? []),
            builder: (context, filteredFolders) {
              return SafeArea(
                minimum: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    _buildSearchField(),
                    Expanded(
                      child: _query.isEmpty
                          ? _buildEmptySearchState(colorScheme)
                          : _buildSearchResults(
                              filteredDocuments,
                              filteredFolders,
                              colorScheme,
                            ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(title: Text(context.l10n.search), centerTitle: false);
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: _searchController,
        onChanged: _searchFor,
        decoration: InputDecoration(
          fillColor: Theme.of(context).colorScheme.surface,
          prefixIcon: Icon(Icons.search_rounded),
          hintText: context.l10n.searchDocumentsHint,
          filled: true,
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear_rounded),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _query = "";
                    });
                  },
                )
              : null,
        ),
        textInputAction: TextInputAction.search,
      ),
    );
  }

  Widget _buildEmptySearchState(
    ColorScheme colorScheme, {
    bool hasNoResults = false,
  }) {
    return Center(
      child: Column(
        spacing: 8,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasNoResults ? Icons.search_off_rounded : Icons.search_rounded,
            size: 64,
            color: colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          Text(
            hasNoResults
                ? context.l10n.noDocumentsFound
                : context.l10n.typeToSearch,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(
    Iterable<Document> filteredDocuments,
    Iterable<Folder> filteredFolders,
    ColorScheme colorScheme,
  ) {
    final hasDocuments = filteredDocuments.isNotEmpty;
    final hasFolders = filteredFolders.isNotEmpty;
    final totalResults = filteredDocuments.length + filteredFolders.length;

    if (totalResults == 0) {
      return _buildEmptySearchState(colorScheme, hasNoResults: true);
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      children: [
        if (hasFolders) ...[
          _buildSectionHeader(
            context,
            title: context.l10n.folders,
            count: filteredFolders.length,
            icon: Icons.folder_rounded,
          ),
          const SizedBox(height: 8),
          ...filteredFolders.map((folder) => FolderTile(folder: folder)),
          const SizedBox(height: 20),
        ],

        if (hasDocuments) ...[
          _buildSectionHeader(
            context,
            title: context.l10n.documents,
            count: filteredDocuments.length,
            icon: Icons.description_rounded,
          ),
          const SizedBox(height: 8),
          ...filteredDocuments.map(
            (document) => DocumentCard(
              document: document,
              onTap: () => Navigator.push(
                context,
                DocumentViewScreen.route(document.id),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required int count,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    return Row(
      spacing: 8,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              count.toString(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
