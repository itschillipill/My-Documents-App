import 'package:flutter/material.dart';
import 'package:my_documents/src/core/extensions/extensions.dart';
import 'package:my_documents/src/features/documents/widgets/date_picker.dart';
import 'package:my_documents/src/features/documents/widgets/file_picker_block.dart';
import 'package:my_documents/src/features/folders/model/folder.dart';

import 'package:my_documents/src/widgets/border_box.dart';
import 'package:my_documents/src/utils/page_transition/app_page_route.dart';

import '../../folders/pages/select_folder_page.dart';
import '../widgets/build_card.dart';

class AddDocumentScreen extends StatefulWidget {
  static PageRoute route() => AppPageRoute.build(
    page: const AddDocumentScreen(),
    transition: PageTransitionType.slideFromBottom,
  );

  const AddDocumentScreen({super.key});

  @override
  State<AddDocumentScreen> createState() => _AddDocumentScreenState();
}

class _AddDocumentScreenState extends State<AddDocumentScreen> {
  Folder? _folder;
  DateTime? _expirationDate;
  bool isFavorite = false;
  String? _originalPath;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add Document",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton(
              onPressed:
                  () => context.deps.documentsCubit.saveDocument(
                    title: _titleController.text.trim(),
                    isFavorite: isFavorite,
                    folderId: _folder?.id,
                    originalPath: _originalPath,
                    onSaved: () => Navigator.pop(context),
                    comment: _commentController.text.trim(),
                    expirationDate: _expirationDate,
                  ),
              child: const Text("Save"),
            ),
          ),
        ],
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(8),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 20,
            children: [
              BuildSection(
                children: [
                  Text(
                    "Add To Folder",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  BorderBox(
                    child: ListTile(
                      leading: const Icon(Icons.folder_rounded),
                      title: Text(
                        _folder != null ? _folder!.name : "Select a folder...",
                      ),
                      onTap: () async {
                        final Folder? folder = await Navigator.push(
                          context,
                          SelectFolderPage.route(),
                        );
                        if (folder != null) {
                          if (folder.id == Folder.noFolder.id) {
                            setState(() {
                              _folder = null;
                            });
                          } else {
                            setState(() {
                              _folder = folder;
                            });
                          }
                        }
                      },
                      trailing: const Icon(Icons.arrow_forward_ios_rounded),
                    ),
                  ),
                ],
              ),

              FilePickerBlock(
                path: _originalPath,
                onSelected: (path) {
                  setState(() => _originalPath = path);
                },
              ),

              BuildSection(
                children: [
                  Text(
                    "Document Details",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  TextField(
                    controller: _titleController,
                    maxLength: 20,
                    decoration: const InputDecoration(
                      hintText: "Document Name",
                    ),
                  ),
                  TextField(
                    controller: _commentController,
                    maxLength: 150,
                    maxLines: 5,
                    minLines: 3,
                    decoration: const InputDecoration(hintText: "Comment"),
                  ),
                  DatePicker(
                    onTap:
                        (date) => setState(() {
                          _expirationDate = date;
                        }),
                    expirationDate: _expirationDate,
                  ),
                ],
              ),

              ListTile(
                title: const Text("Add to Favorites"),
                leading: const Icon(Icons.star_border_rounded),
                trailing: Switch.adaptive(
                  value: isFavorite,
                  onChanged: (v) {
                    setState(() {
                      isFavorite = v;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
