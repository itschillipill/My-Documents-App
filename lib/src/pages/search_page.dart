import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_documents/src/core/extensions/extensions.dart';
import 'package:my_documents/src/features/documents/cubit/documents_cubit.dart';
import 'package:my_documents/src/features/documents/model/document.dart';
import 'package:my_documents/src/features/documents/pages/document_view_page.dart';
import 'package:my_documents/src/features/documents/widgets/document_card.dart';
import 'package:my_documents/src/features/folders/cubit/folders_cubit.dart';
import 'package:my_documents/src/features/folders/model/folder.dart';
import 'package:my_documents/src/features/folders/widgets/folder_tile.dart';

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
      _query = value.trim().toLowerCase();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final documents = context.select<DocumentsCubit, List<Document>?>(
      (cubit) => cubit.documentsOrEmpty,
    );

    final folders = context.select<FoldersCubit, List<Folder>?>(
      (cubit) => cubit.foldersOrEmpty,
    );

    if (documents == null || folders == null) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final List<Document> filteredDocuments = _query.isEmpty
        ? []
        : documents
              .where((doc) => doc.title.toLowerCase().contains(_query))
              .toList();

    final List<Folder> filteredFolders = _query.isEmpty
        ? []
        : folders
              .where((folder) => folder.name.toLowerCase().contains(_query))
              .toList();

    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
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
    List<Document> filteredDocuments,
    List<Folder> filteredFolders,
    ColorScheme colorScheme,
  ) {
    final hasDocuments = filteredDocuments.isNotEmpty;
    final hasFolders = filteredFolders.isNotEmpty;
    final totalResults = filteredDocuments.length + filteredFolders.length;

    if (totalResults == 0) {
      return _buildEmptySearchState(colorScheme, hasNoResults: true);
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
          const SizedBox(height: 24),
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
              onTap: () {
                Navigator.push(context, DocumentViewPage.route(document.id));
              },
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
