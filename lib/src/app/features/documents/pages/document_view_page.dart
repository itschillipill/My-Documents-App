import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_documents/src/app/features/documents/cubit/documents_cubit.dart';
import 'package:my_documents/src/app/extensions/extensions.dart';
import 'package:my_documents/src/app/features/documents/model/document.dart';
import 'package:my_documents/src/app/features/documents/pages/add_new_document_version.dart';
import 'package:my_documents/src/app/features/documents/widgets/document_previewer.dart';
import 'package:my_documents/src/utils/page_transition/app_page_route.dart';
import 'package:open_filex/open_filex.dart';

import '../document_actions.dart';
import 'document_version_history.dart';

class DocumentViewPage extends StatelessWidget {
  static PageRoute route(int documentId, {int? versionId}) =>
      AppPageRoute.build(
        page: DocumentViewPage(documentId: documentId, versionId: versionId),
        transition: PageTransitionType.slideFromBottom,
      );
  final int documentId;
  final int? versionId;
  const DocumentViewPage({super.key, required this.documentId, this.versionId});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DocumentsCubit>();
    return BlocBuilder<DocumentsCubit, DocumentsState>(
      buildWhen: (previous, current) => current is DocumentsLoaded,
      builder: (context, state) {
        final List<Document> documents = cubit.documentsOrEmpty;
        final document = cubit.getDocumentById(documentId);
        final documentVersion = document?.versions.firstWhere(
          (v) => v.id == (versionId??(document.currentVersionId)),
          orElse: () => document.versions.first,
        );
        if (documents.isEmpty || document == null || documentVersion == null) {
          return Material(
            child: Center(
              child: Column(
                spacing: 12,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Something went wrong!"),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Go Back"),
                  ),
                  if (kDebugMode)
                    ElevatedButton(
                      onPressed: () {
                        debugPrint("state: $state");
                        debugPrint("Document: $document");
                        debugPrint(
                          "Current Document Version: $documentVersion",
                        );
                      },
                      child: Text("Get info"),
                    ),
                ],
              ),
            ),
          );
        }
        bool isCurrent = document.currentVersionId == documentVersion.id;
        debugPrint("Document: $document");
        debugPrint(
          "Current Document Version: ${documentVersion.id}, serched for: ${versionId??document.currentVersionId}",
        );
        return Scaffold(
          appBar: AppBar(
            title: Text(document.title),
            actions: [
              if (isCurrent)
                PopupMenuButton<DocumentAction>(
                  popUpAnimationStyle: AnimationStyle(
                    curve: Curves.bounceInOut,
                  ),
                  icon: Icon(Icons.more_vert_rounded),
                  position: PopupMenuPosition.under,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  onSelected: (action) => action.call(),
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(
                        value: ChangeDetails$DocumentAction(
                          context: context,
                          document: document,
                        ),
                        child: Text("Change Details"),
                      ),
                    ];
                  },
                ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  spacing: 20,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (documentVersion.comment?.isNotEmpty == true)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Comment:",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          Row(
                            children: [
                              SelectableText(documentVersion.comment!),
                            ],
                          ).withBorder(padding: EdgeInsets.all(8)),
                        ],
                      ),
                    Column(
                      spacing: 5,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DocumentRow(
                          "Upload Date",
                          document.createdAt.formatted,
                        ),
                        DocumentRow(
                          "Expiration Date",
                          documentVersion.expirationDate != null
                              ? documentVersion.expirationDate!.formatted
                              : "No expiration",
                        ),
                        DocumentRow("Status", document.status.statusText),
                      ],
                    ).withBorder(padding: EdgeInsets.all(8)),
                    DocumentPreviewer(
                      path: documentVersion.filePath,
                      isImage: documentVersion.isImage,
                    ),
                    ElevatedButton(
                      onPressed:
                          () async =>
                              await OpenFilex.open(documentVersion.filePath),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 5,
                        children: [
                          Icon(Icons.remove_red_eye_rounded),
                          Text("Open In External App"),
                        ],
                      ),
                    ),

                    tile(
                      label: "Share Document",
                      icon: Icons.share_rounded,
                      action: Share$DocumentAction(
                        path: documentVersion.filePath,
                      ),
                    ),
                    if (isCurrent) ...[
                      tile(
                        label: "Upload New Version",
                        icon: Icons.file_download_outlined,
                        onTap:
                            () async => await Navigator.push(
                              context,
                              AddNewDocumentVersion.route(document.id),
                            ),
                      ),
                      tile(
                        label: "Manage Versions",
                        icon: Icons.history_rounded,
                        onTap:
                            () => Navigator.push(
                              context,
                              DocumentVersionHistory.route(document.id),
                            ),
                      ),
                      tile(
                        label: "Delete Document",
                        icon: Icons.delete_rounded,
                        action: Delete$DocumentAction(
                          document: document,
                          context: context,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class DocumentRow extends StatelessWidget {
  final String label;
  final String value;

  const DocumentRow(this.label, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Text(value, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

Widget tile({
  required String label,
  required IconData icon,
  VoidCallback? onTap,
  DocumentAction? action,
}) {
  return ListTile(
    title: Text(label),
    leading: Icon(icon),
    onTap: onTap ?? () => action?.call(),
    trailing: onTap != null ? Icon(Icons.arrow_forward_ios_rounded) : null,
  ).withBorder();
}
