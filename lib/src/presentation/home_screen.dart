import 'package:flutter/material.dart';
import 'package:my_documents/src/core/extensions/extensions.dart';
import 'package:my_documents/src/features/documents/presentation/add_document_screen.dart';
import 'package:my_documents/src/presentation/widgets/document_block.dart';
import 'package:my_documents/src/presentation/widgets/folders_block.dart';
import 'package:my_documents/src/presentation/widgets/warning_block.dart';

import '../features/folders/presentation/add_folder_screen.dart';

class MyHomeScreen extends StatelessWidget {
  const MyHomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.appTitle,
                    style: context.theme.textTheme.headlineLarge,
                  ),
                  Text(context.l10n.quickAccess),
                ],
              ),
              IconButton(
                onPressed: () => _showAddMenu(context),
                icon: Icon(Icons.add_rounded),
              ),
            ],
          ),
          const Expanded(
            child: CustomScrollView(
              slivers: [FoldersBlock(), WarningBlock(), DocumentBlock()],
            ),
          ),
        ],
      ),
    );
  }
}

void _showAddMenu(BuildContext context) async {
  await showModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (context) {
      return Container(
        margin: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            _buildMenuButton(
              context,
              icon: Icons.description_rounded,
              label: context.l10n.addDocument,
              onTap: () {
                Navigator.pushReplacement(context, AddDocumentScreen.route());
              },
            ),
            _buildMenuButton(
              context,
              icon: Icons.folder_rounded,
              label: context.l10n.addFolder,
              onTap: () {
                Navigator.pushReplacement(context, AddFolderScreen.route());
              },
            ),
            _buildMenuButton(
              context,
              icon: Icons.close_rounded,
              label: context.l10n.cancel,
              onTap: () => Navigator.pop(context),
              isCancel: true,
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildMenuButton(
  BuildContext context, {
  required IconData icon,
  required String label,
  required VoidCallback onTap,
  bool isCancel = false,
}) {
  final colorScheme = Theme.of(context).colorScheme;

  return Material(
    color: colorScheme.primary,
    borderRadius: BorderRadius.circular(12),
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Row(
          spacing: 16,
          children: [
            Icon(
              icon,
              color: isCancel
                  ? colorScheme.surface.withValues(alpha: 0.6)
                  : colorScheme.surface,
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: isCancel
                    ? colorScheme.surface.withValues(alpha: 0.6)
                    : colorScheme.surface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
