import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_documents/src/core/extensions/extensions.dart';
import 'package:my_documents/src/features/documents/cubit/documents_cubit.dart';
import 'package:my_documents/src/features/documents/model/document.dart';
import 'package:my_documents/src/features/documents/pages/add_document_screen.dart';
import 'package:my_documents/src/features/documents/pages/document_view_page.dart';
import 'package:my_documents/src/features/folders/model/folder.dart';
import 'package:my_documents/src/features/folders/pages/folder_view_page.dart';

class DocumentsBlock extends StatelessWidget {
  static const Folder _allFolder = Folder.allFolder;

  const DocumentsBlock({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.sizeOf(context).width;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: BlocBuilder<DocumentsCubit, DocumentsState>(
          buildWhen:
              (previous, current) => current.documents != previous.documents,
          builder: (context, state) {
            final documents = state.documents ?? [];
            if (documents.isEmpty) {
              return _buildEmptyState(context, colorScheme, screenWidth);
            }
            final gridDelegate = _calculateGridDelegate(screenWidth);
            final iconSize = _calculateIconSize(screenWidth);
            final favorites = documents.where((e) => e.isFavorite);
            final nonFavorites = documents.where((e) => !e.isFavorite);
            final prioritizedDocs = [...favorites, ...nonFavorites];
            final docsToShow = prioritizedDocs.take(3);
            final items = [...docsToShow, null];

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              gridDelegate: gridDelegate,
              itemBuilder: (context, index) {
                return _buildDocumentCard(
                  doc: items[index],
                  context: context,
                  colorScheme: colorScheme,
                  theme: theme,
                  iconSize: iconSize,
                  screenWidth: screenWidth,
                );
              },
            );
          },
        ),
      ),
    );
  }

  SliverGridDelegateWithFixedCrossAxisCount _calculateGridDelegate(
    double screenWidth,
  ) {
    final (
      int crossAxisCount,
      double mainSpacing,
      double crossSpacing,
      double aspectRatio,
    ) = switch (screenWidth) {
      < 400 => (2, 8, 8, 1.4),
      < 500 => (2, 10, 10, 1.3),
      < 700 => (3, 12, 12, 1.2),
      < 900 => (4, 12, 12, 1.1),
      _ => (5, 16, 16, 1.0),
    };
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: mainSpacing,
      crossAxisSpacing: crossSpacing,
      childAspectRatio: aspectRatio,
    );
  }

  double _calculateIconSize(double screenWidth) {
    final double iconSize = switch (screenWidth) {
      < 400 => 20,
      < 500 => 24,
      < 700 => 28,
      < 900 => 32,
      _ => 36,
    };
    return iconSize;
  }

  Widget _buildDocumentCard({
    required Document? doc,
    required BuildContext context,
    required ColorScheme colorScheme,
    required ThemeData theme,
    required double iconSize,
    required double screenWidth,
  }) {
    final isAll = doc == null;
    double iconContainerSize = 50;
    double borderRadius = 14;

    return MaterialButton(
      elevation: 0,
      onPressed: () {
        Navigator.push(
          context,
          isAll
              ? FolderViewPage.route(folder: _allFolder)
              : DocumentViewPage.route(doc.id),
        );
      },
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 8,
        children: [
          Container(
            width: iconContainerSize,
            height: iconContainerSize,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(borderRadius - 4),
            ),
            child: Icon(
              isAll ? Icons.folder_open_rounded : Icons.description_rounded,
              size: iconSize,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          Text(
            isAll ? context.l10n.all : doc.title,
            maxLines: screenWidth < 400 ? 1 : 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    ColorScheme colorScheme,
    double screenWidth,
  ) {
    final isSmallScreen = screenWidth < 400;

    return Container(
      padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 20 : 28),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 10,
        children: [
          Text(
            context.l10n.addFirstDocument,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          SizedBox(
            width: isSmallScreen ? double.infinity : null,
            child: ElevatedButton.icon(
              onPressed:
                  () => Navigator.push(context, AddDocumentScreen.route()),
              icon: const Icon(Icons.add_rounded),
              label: Text(context.l10n.addDocument),
            ),
          ),
        ],
      ),
    );
  }
}
