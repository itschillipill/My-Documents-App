import 'package:flutter/material.dart';
import 'package:my_documents/src/core/extensions/extensions.dart';
import 'package:my_documents/src/features/documents/widgets/date_picker.dart'
    as dp;
import 'package:my_documents/src/features/documents/widgets/file_picker_block.dart';
import 'package:my_documents/src/features/documents/widgets/folder_piker.dart';
import 'package:my_documents/src/features/folders/model/folder.dart';
import 'package:my_documents/src/utils/page_transition/app_page_route.dart';
import 'package:my_documents/src/utils/sevices/message_service.dart';
import 'package:my_documents/src/widgets/build_section.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n.addDocument,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              // Folder Selection
              FolderPiker(
                selectedFolder: _folder,
                onSelected: (f) => setState(() => _folder = f),
              ),

              // File Picker
              FilePickerBlock(
                path: _originalPath,
                onSelected: (path) {
                  setState(() => _originalPath = path);
                },
              ),

              // Document Details
              _buildDocumentDetails(context, colorScheme),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed:
                      _originalPath == null
                          ? null
                          : () async {
                            final error = await context.deps.documentsCubit
                                .saveDocument(
                                  title: _titleController.text.trim(),
                                  isFavorite: isFavorite,
                                  folderId: _folder?.id,
                                  originalPath: _originalPath,
                                  comment: _commentController.text.trim(),
                                  expirationDate: _expirationDate,
                                );

                            if (context.mounted) {
                              if (error != null) {
                                MessageService.showErrorSnack(
                                  error.getMessage(context),
                                );
                              } else {
                                Navigator.pop(context);
                              }
                            }
                          },

                  child: Text(
                    context.l10n.save.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentDetails(BuildContext context, ColorScheme colorScheme) {
    return BuildSection(
      title: context.l10n.documentDetails,
      icon: Icons.description_rounded,
      children: [
        // Title field
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Text(
              context.l10n.documentName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
            TextField(
              controller: _titleController,
              maxLength: 50,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: context.l10n.documentName,
                hintStyle: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                ),
                counterText: '',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Comment field
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Text(
              context.l10n.comment,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
            TextField(
              controller: _commentController,
              maxLength: 500,
              maxLines: 5,
              minLines: 3,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: context.l10n.comment,
                hintStyle: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Expiration date picker
        dp.DatePicker(
          onTap:
              (date) => setState(() {
                _expirationDate = date;
              }),
          expirationDate: _expirationDate,
        ),
      ],
    );
  }
}
