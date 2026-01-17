import 'package:flutter/material.dart';
import 'package:my_documents/src/core/extensions/extensions.dart';
import 'package:my_documents/src/widgets/border_box.dart';
import 'package:my_documents/src/widgets/build_section.dart';

import '../../folders/model/folder.dart';
import '../../folders/pages/select_folder_page.dart';

class FolderPiker extends StatelessWidget {
  final Function(Folder? folder) onSelected;
  final Folder? selectedFolder;
  const FolderPiker({super.key, required this.onSelected, this.selectedFolder});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return BuildSection(
      title: context.l10n.addToFolder,
      icon: Icons.folder_rounded,
      children: [
        InkWell(
          onTap: () async {
            final Folder? folder = await Navigator.push(
              context,
              SelectFolderPage.route(),
            );
            if (folder != null) {
              if (folder.id == Folder.noFolder.id) {
                onSelected(null);
              } else {
                onSelected(folder);
              }
            }
          },
          child: BorderBox(
            child: Row(
              spacing: 12,
              children: [
                Icon(
                  Icons.folder_open_rounded,
                  color: colorScheme.primary,
                  size: 24,
                ),
                Expanded(
                  child: Text(
                    selectedFolder != null
                        ? selectedFolder!.name
                        : context.l10n.selectFolder,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: selectedFolder != null
                          ? colorScheme.onSurface
                          : colorScheme.onSurface.withValues(alpha: 0.6),
                      fontWeight: selectedFolder != null
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
