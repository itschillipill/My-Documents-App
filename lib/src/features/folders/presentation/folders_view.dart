import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/extensions/extensions.dart';
import '../cubit/folders_cubit.dart';
import '../model/folder.dart';
import 'widgets/folder_tile.dart';

class FoldersView extends StatelessWidget {
  static Route route() =>
      MaterialPageRoute(builder: (_) => const FoldersView());
  const FoldersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.folders)),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: BlocSelector<FoldersCubit, FoldersState, List<Folder>>(
          selector: (state) => state.folders ?? [],
          bloc: context.deps.foldersCubit,
          builder: (context, folders) {
            if (folders.isEmpty) {
              return Center(child: Text(context.l10n.noFoldersFound));
            }
            return ListView.builder(
              itemCount: folders.length,
              itemBuilder: (context, index) {
                return FolderTile(folder: folders[index]);
              },
            );
          },
        ),
      ),
    );
  }
}
