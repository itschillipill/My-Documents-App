import 'package:flutter/material.dart';
import 'package:my_documents/src/core/extensions/extensions.dart';
import 'package:my_documents/src/features/documents/model/document.dart';
import 'package:my_documents/src/features/documents/widgets/folder_piker.dart';
import 'package:my_documents/src/features/folders/model/folder.dart';

import 'package:my_documents/src/utils/page_transition/app_page_route.dart';
import 'package:my_documents/src/utils/sevices/message_service.dart';

import '../../../widgets/build_section.dart';

typedef Params = ({Folder? folder, String? title, bool? isFavorite});

class ChangeDocumentDetails extends StatefulWidget {
  static PageRoute<Document> route({
    required Function(Params) onUpdate,
    required Params oldParams,
  }) => AppPageRoute.build(
    page: ChangeDocumentDetails(onUpdate: onUpdate, oldParams: oldParams),
    transition: PageTransitionType.slideFromBottom,
  );
  final Params oldParams;
  final Function(Params) onUpdate;
  const ChangeDocumentDetails({
    super.key,
    required this.onUpdate,
    required this.oldParams,
  });

  @override
  State<ChangeDocumentDetails> createState() => _ChangeDocumentDetailsState();
}

class _ChangeDocumentDetailsState extends State<ChangeDocumentDetails> {
  Folder? _folder;
  bool isFavorite = false;
  DateTime? expirationDate;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _titleController.text = widget.oldParams.title ?? "";
    _folder = widget.oldParams.folder;
    isFavorite = widget.oldParams.isFavorite ?? false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;

        final res = await MessageService.$confirmAction(
          title: context.l10n.discardChanges,
        );
        if (res && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            context.l10n.changeDetails,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        body: SafeArea(
          minimum: const EdgeInsets.symmetric(horizontal: 8),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 15,
              children: [
                FolderPiker(onSelected: (f)=> setState(()=>_folder=f), selectedFolder: _folder,),
                BuildSection(
                  title: context.l10n.documentName,
                  icon: Icons.description_rounded,
                  children: [
                    TextField(
                      controller: _titleController,
                      maxLength: 20,
                      decoration: InputDecoration(
                        hintText: context.l10n.documentName,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      final title = _titleController.text.trim();
                      if (title.isEmpty) {
                        MessageService.showSnackBar(context.l10n.enterTitle);
                        return;
                      }
                      if (title != widget.oldParams.title &&
                          context.deps.documentsCubit.documentsOrEmpty.any(
                            (e) => title == e.title,
                          )) {
                        MessageService.showSnackBar(
                          context.l10n.documentTitleExists,
                        );
                        return;
                      }
                      final res = await MessageService.$confirmAction(
                        title: context.l10n.changeDetails,
                      );
                      if (res && context.mounted) {
                        widget.onUpdate((
                          folder: _folder,
                          title: title,
                          isFavorite: isFavorite,
                        ));
                        Navigator.pop(context);
                      }
                    },
                    child: Text(context.l10n.save),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
