import 'package:flutter/material.dart';
import 'package:my_documents/src/core/extensions/extensions.dart';
import 'package:my_documents/src/features/documents/model/document.dart';
import 'package:my_documents/src/features/folders/model/folder.dart';

import 'package:my_documents/src/widgets/border_box.dart';
import 'package:my_documents/src/utils/page_transition/app_page_route.dart';
import 'package:my_documents/src/utils/sevices/message_service.dart';

import '../../folders/pages/select_folder_page.dart';
import 'build_card.dart';

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
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                      context.l10n.addToFolder,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    BorderBox(
                      child: ListTile(
                        leading: const Icon(Icons.folder_rounded),
                        title: Text(
                          _folder != null
                              ? _folder!.name
                              : context.l10n.selectFolder,
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

                BuildSection(
                  children: [
                    Text(
                      context.l10n.documentDetails,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    TextField(
                      controller: _titleController,
                      maxLength: 20,
                      decoration: InputDecoration(
                        hintText: context.l10n.documentName,
                      ),
                    ),
                  ],
                ),

                ListTile(
                  title: Text(context.l10n.addToFavorities),
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
      ),
    );
  }
}
