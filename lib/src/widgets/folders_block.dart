import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_documents/src/core/extensions/extensions.dart';
import 'package:my_documents/src/features/folders/cubit/folders_cubit.dart';
import 'package:my_documents/src/features/folders/pages/folders_view.dart';
import '../features/folders/model/folder.dart';
import '../features/folders/pages/folder_view_page.dart';
import 'package:my_documents/src/features/documents/cubit/documents_cubit.dart';

class FoldersBlock extends StatelessWidget {
  const FoldersBlock({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<FoldersCubit, FoldersState, List<Folder>>(
      selector: (state) => (state.folders ?? []).take(4).toList(),
      bloc: context.deps.foldersCubit,
      builder: (context, folders) {
        if (folders.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }
        return SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Text(
                      context.l10n.folders,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Spacer(),
                    TextButton(
                      onPressed: () {
                        Navigator.push(context, FoldersView.route());
                      },
                      child: Text(
                        context.l10n.viewAll,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    // IconButton(onPressed: (){}, icon: Icon(Icons.settings)),
                  ],
                ),
              ),
              GridView.builder(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 300,
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 12,
                  childAspectRatio: getAspectRatio(context),
                ),
                itemCount: folders.length,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final folder = folders[index];
                  return EnhancedFolderCard(folder: folder);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

double getAspectRatio(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  return switch (width) {
    < 600 => 1.8,
    > 600 => 2,
    _ => 3,
  };
}

class EnhancedFolderCard extends StatelessWidget {
  final Folder folder;
  final VoidCallback? onTap;

  const EnhancedFolderCard({super.key, required this.folder, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap:
          onTap ??
          () {
            Navigator.push(context, FolderViewPage.route(folder: folder));
          },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: Durations.medium2,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.transparent, width: 1.5),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          spacing: 5,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              spacing: 4,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Icon(Icons.folder_rounded, color: colorScheme.primary),
                ),
                Expanded(
                  child: Text(
                    folder.name,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            BlocBuilder<DocumentsCubit, DocumentsState>(
              bloc: context.deps.documentsCubit,
              builder: (context, state) {
                final documents = folder.getDocuments(state.documents ?? []);
                final count = documents.length;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${context.l10n.documents}: $count",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
