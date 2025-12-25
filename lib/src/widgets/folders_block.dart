import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_documents/src/core/extensions/extensions.dart';
import 'package:my_documents/src/features/folders/cubit/folders_cubit.dart';

import '../features/folders/model/folder.dart';
import '../features/folders/widgets/folder_tile.dart';

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
    return SliverList(
      delegate: SliverChildBuilderDelegate(semanticIndexOffset: 1, (
        context,
        index,
      ) {
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
        return FolderTile(folder: folder);
      }, childCount: folders.length + 1),
    );
  }
}
