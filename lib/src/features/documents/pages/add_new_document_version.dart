import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_documents/src/core/extensions/extensions.dart';
import 'package:my_documents/src/features/documents/model/document.dart';
import 'package:my_documents/src/features/documents/widgets/date_picker.dart';
import 'package:my_documents/src/features/documents/widgets/file_picker_block.dart';
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

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _saveDocument(BuildContext context) async {
    final cubit = context.read<DocumentsCubit>();

    if (_originalPath == null) {
      MessageService.showSnackBar(context.l10n.chooseFile);
      return;
    }

    final isValidSize = await FileService.validateFileSize(_originalPath!);
    if (!isValidSize && context.mounted) {
      MessageService.showErrorSnack(context.l10n.fileIsTooLarge);
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
      if (context.mounted)
        MessageService.showSnackBar("${context.l10n.errorSavirgFile}: $e");
    }
    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n.addVersion,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton(
              onPressed: () => _saveDocument(context),
              child: Text(context.l10n.save),
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
                    context.l10n.versionDetais,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  TextField(
                    controller: _commentController,
                    maxLength: 150,
                    maxLines: 5,
                    minLines: 3,
                    decoration: InputDecoration(hintText: context.l10n.comment),
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
