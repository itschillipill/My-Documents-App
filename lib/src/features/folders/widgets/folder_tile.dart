import 'package:flutter/material.dart';
import 'package:my_documents/src/core/extensions/extensions.dart';

import '../model/folder.dart';
import '../pages/folder_view_page.dart';

class FolderTile extends StatelessWidget {
  final Folder folder;
  const FolderTile({super.key, required this.folder});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Material(
        color: colorScheme.surface,
        child: InkWell(
          onTap: () {
            Navigator.push(context, FolderViewPage.route(folder: folder));
          },
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.folder_rounded),
            ),
            title: Text(
              folder.name,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              _getFolderInfo(folder, context),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            trailing: Icon(Icons.chevron_right_rounded),
          ),
        ),
      ),
    );
  }
}

String _getFolderInfo(Folder folder, BuildContext context) {
  final docCount =
      folder.getDocuments(context.deps.documentsCubit.documentsOrEmpty).length;
  return "${context.l10n.documents}: $docCount";
}
