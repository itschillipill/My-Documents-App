import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_documents/src/core/extensions/extensions.dart';
import 'package:my_documents/src/features/documents/cubit/documents_cubit.dart';
import 'package:my_documents/src/features/folders/model/folder.dart';
import 'package:my_documents/src/features/folders/presentation/folder_view_screen.dart';

import '../../features/documents/model/document.dart';

class WarningBlock extends StatelessWidget {
  static const Folder _folder = Folder.warningFolder;
  static const Widget _placeholder = SliverToBoxAdapter(
    child: SizedBox.shrink(),
  );

  const WarningBlock({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<DocumentsCubit, DocumentsState, List<Document>>(
      selector: (state) => _folder.getDocuments(state.documents ?? []),
      bloc: context.deps.documentsCubit,
      builder: (context, state) {
        if (state.isEmpty) return _placeholder;
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border(
                  left: BorderSide(
                    color: Theme.of(context).colorScheme.secondary,
                    width: 3,
                  ),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: Icon(
                    Icons.warning_rounded,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  title: Text(
                    context.l10n.tapToView,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Text(
                    "${state.length} ${context.l10n.documentsExpiring}",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    FolderViewScreen.route(folder: _folder),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
