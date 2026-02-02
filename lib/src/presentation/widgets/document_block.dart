import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_documents/src/core/extensions/extensions.dart';
import 'package:my_documents/src/features/documents/cubit/documents_cubit.dart';
import 'package:my_documents/src/features/documents/model/document.dart';
import 'package:my_documents/src/features/documents/presentation/add_document_screen.dart';
import 'package:my_documents/src/features/folders/model/folder.dart';
import 'package:my_documents/src/features/folders/presentation/folder_view_screen.dart';
import '../../features/documents/presentation/widgets/document_card.dart';

Widget _buildEmptyState(BuildContext context, double screenWidth) {
  final isSmallScreen = screenWidth < 400;

  return Container(
    padding: EdgeInsets.symmetric(
      vertical: isSmallScreen ? 32 : 48,
      horizontal: 16,
    ),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 24),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.description_outlined,
          size: isSmallScreen ? 64 : 80,
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
        ),
        const SizedBox(height: 16),
        Text(
          context.l10n.addFirstDocument,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: isSmallScreen ? double.infinity : null,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.push(context, AddDocumentScreen.route()),
            icon: const Icon(Icons.add_rounded),
            label: Text(
              context.l10n.addDocument,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    ),
  );
}

/// {@template document_block}
/// DocumentBlock widget.
/// {@endtemplate}
class DocumentBlock extends StatelessWidget {
  /// {@macro document_block}
  const DocumentBlock({super.key});

  static const Folder _allFolder = Folder.allFolder;

  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(
    child: BlocSelector<DocumentsCubit, DocumentsState, List<Document>>(
      bloc: context.deps.documentsCubit,
      selector: (state) {
        final docs = List<Document>.from(state.documents ?? []);
        docs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return docs.take(4).toList();
      },
      builder: (context, state) {
        final screenWidth = MediaQuery.sizeOf(context).width;

        if (state.isEmpty) {
          return _buildEmptyState(context, screenWidth);
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.l10n.recent,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          FolderViewScreen.route(folder: _allFolder),
                        );
                      },
                      label: Text(
                        context.l10n.viewAll,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.length,
                separatorBuilder: (context, index) => const SizedBox(height: 4),
                itemBuilder: (context, index) =>
                    DocumentCard(document: state[index]),
              ),
            ],
          ),
        );
      },
    ),
  );
}
