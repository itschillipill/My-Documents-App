import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_documents/src/app/features/documents/model/document.dart';
import 'package:my_documents/src/app/features/documents/widgets/date_picker.dart';
import 'package:my_documents/src/app/features/documents/widgets/file_picker_block.dart';
import 'package:my_documents/src/utils/page_transition/app_page_route.dart';
import 'package:my_documents/src/utils/sevices/file_service.dart';
import 'package:my_documents/src/utils/sevices/message_service.dart';

import '../cubit/documents_cubit.dart';
import '../widgets/build_card.dart';

class AddNewDocumentVersion extends StatefulWidget {
  static PageRoute route(int documentId) => AppPageRoute.build(
    page: AddNewDocumentVersion(documentId: documentId),
    transition: PageTransitionType.slideFromRight,
  );
  final int documentId;
  const AddNewDocumentVersion({super.key, required this.documentId});

  @override
  State<AddNewDocumentVersion> createState() => _AddNewDocumentVersionState();
}

class _AddNewDocumentVersionState extends State<AddNewDocumentVersion> {
  DateTime? _expirationDate;
  String? _originalPath;
  final TextEditingController _commentController = TextEditingController();
  void _saveDocument(BuildContext context) async {
    final cubit = context.read<DocumentsCubit>();

    if (_originalPath == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please choose a file")));
      return;
    }

    final isValidSize = await FileService.validateFileSize(_originalPath!);
    if (!isValidSize && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("File is too large (max 50 MB)")),
      );
      return;
    }

    try {
      final safePath = await FileService.saveFileToAppDir(_originalPath!);

      final docVersion = DocumentVersion(
        id: 0,
        documentId: widget.documentId,
        filePath: safePath,
        uploadedAt: DateTime.now(),
        comment:
            _commentController.text.trim().isEmpty
                ? null
                : _commentController.text.trim(),
        expirationDate: _expirationDate,
      );

      await cubit.addNewVersion(widget.documentId, docVersion);
    } catch (e) {
      MessageService.showSnackBar("Error saving file: $e");
    }
    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add Version",
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
              FilePickerBlock(
                path: _originalPath,
                onSelected: (path) {
                  setState(() => _originalPath = path);
                },
              ),
              BuildSection(
                children: [
                  Text(
                    "Version Details",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  TextField(
                    controller: _commentController,
                    maxLength: 150,
                    maxLines: 5,
                    minLines: 3,
                    decoration: const InputDecoration(hintText: "Comment"),
                  ),
                  DatePicker(
                    onTap: (date) {
                      setState(() => _expirationDate = date);
                    },
                    expirationDate: _expirationDate,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
