import 'package:flutter/material.dart';
import 'package:my_documents/src/core/extensions/extensions.dart';
import 'package:my_documents/src/utils/page_transition/app_page_route.dart';
import 'package:my_documents/src/utils/sevices/message_service.dart';
import 'package:my_documents/src/widgets/build_section.dart';

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
      ),
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          spacing: 10,
          children: [
            BuildSection(
              title: context.l10n.folderDetails,
              icon: Icons.folder_outlined,
              children: [
                TextField(
                  controller: _nameController,
                  maxLength: 20,
                  decoration: InputDecoration(
                    hintText: context.l10n.folderName,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(8),
                  ),
                ),
              ],
            ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  final result = await context.deps.foldersCubit.saveFolder(
                    Folder(id: 0, name: _nameController.text.trim()),
                  );
                  result(
                    onSuccess: (_) => Navigator.pop(context),
                    onError: (error) => MessageService.showErrorSnack(
                      error.getMessage(context),
                    ),
                  );
                },
                child: Text(context.l10n.save),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
