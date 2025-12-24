import 'package:flutter/material.dart';
import 'package:my_documents/src/core/extensions/extensions.dart';
import 'package:my_documents/src/widgets/border_box.dart';
import 'package:my_documents/src/utils/page_transition/app_page_route.dart';

import '../model/folder.dart';

class AddFolderPage extends StatelessWidget {
  static PageRoute route() => AppPageRoute.build(
    page: AddFolderPage(),
    transition: PageTransitionType.fade,
  );

  AddFolderPage({super.key});

  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n.addFolder,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton(
              onPressed:
                  () => context.deps.foldersCubit.saveFolder(
                    Folder(id: 0, name: _nameController.text.trim()),
                    onSaved: () => Navigator.pop(context),
                  ),
              child: Text(context.l10n.save),
            ),
          ),
        ],
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 20,
          children: [
            Text(
              context.l10n.folderDetails,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            BorderBox(
              child: TextField(
                controller: _nameController,
                maxLength: 20,
                decoration: InputDecoration(
                  hintText:context.l10n.folderName,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
