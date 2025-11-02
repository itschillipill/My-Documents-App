import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_documents/src/app/features/documents/widgets/date_picker.dart';
import 'package:my_documents/src/app/features/documents/widgets/file_picker_block.dart';
import 'package:my_documents/src/app/features/folders/model/folder.dart';
import 'package:my_documents/src/utils/sevices/message_service.dart';

import 'package:my_documents/src/app/widgets/border_box.dart';
import 'package:my_documents/src/utils/page_transition/app_page_route.dart';
import 'package:my_documents/src/utils/sevices/file_service.dart';

import '../cubit/documents_cubit.dart';
import '../model/document.dart';
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

  Future<void> _saveDocument(BuildContext context) async {
    final title = _titleController.text.trim();
    final cubit = context.read<DocumentsCubit>();

    if (title.isEmpty || _originalPath == null) {
      MessageService.showSnackBar("Please enter title and choose a file");
      return;
    }

    if ((cubit.state as DocumentsLoaded).documents.any(
      (element) => element.title == title,
    )) {
      MessageService.showSnackBar("Document with this title already exists");
      return;
    }

    final isValidSize = await FileService.validateFileSize(_originalPath!);
    if (!isValidSize) {
      MessageService.showSnackBar("File is too large (max 50 MB)");
      return;
    }

    try {
      // копируем файл в папку приложения
      final safePath = await FileService.saveFileToAppDir(_originalPath!);

      final doc = Document(
        id: 0,
        title: title,
        folderId: _folder?.id,
        isFavorite: isFavorite,
        createdAt: DateTime.now(),
        currentVersionId: 1,
        versions: [
          DocumentVersion(
            id: 0,
            documentId: 0,
            filePath: safePath,
            uploadedAt: DateTime.now(),
            comment:
                _commentController.text.trim().isEmpty
                    ? null
                    : _commentController.text.trim(),
            expirationDate: _expirationDate,
          ),
        ],
      );

      await cubit.addDocument(doc);

      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      MessageService.showSnackBar("Error saving file: $e");
    }
  }

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
              onPressed: () => _saveDocument(context),
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
