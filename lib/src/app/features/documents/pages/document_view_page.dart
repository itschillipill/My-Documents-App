import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_documents/src/app/features/documents/cubit/documents_cubit.dart';
import 'package:my_documents/src/app/extensions/extensions.dart';
import 'package:my_documents/src/app/features/documents/model/document.dart';
import 'package:my_documents/src/app/features/documents/pages/add_new_document_version.dart';
import 'package:my_documents/src/app/widgets/border_box.dart';
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
    return BlocBuilder<DocumentsCubit, DocumentsState>(
      buildWhen: (previous, current) => current is DocumentsLoaded,
      builder: (context, state) {
        final cubit = context.read<DocumentsCubit>();
        if (state is! DocumentsLoaded) {
          return Center(child: CircularProgressIndicator());
        }
        final document = cubit.getDocumentById(documentId);
        if (document == null) return Center(child: Text("Document not found"));
        final documentVersion = cubit.getDocumentVersionByDocumentId(
          documentId: documentId,
          versionId: versionId,
        );
        if (documentVersion == null) {
          return Center(child: Text("Document version not found"));
        }

        debugPrint(document.toMap().toString());
      //  debugPrint(document.versions.map((e) => e.toMap()).join("\n"));
        return Scaffold(
          appBar: AppBar(
            title: Text(
              document.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            actions: [
              PopupMenuButton<DocumentMenuAction>(
                popUpAnimationStyle: AnimationStyle(curve: Curves.bounceInOut),
                icon: Icon(Icons.more_vert_rounded),
                position: PopupMenuPosition.under,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                onSelected: (action) => action.call(context, document),
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      value: DocumentMenuAction.changeFolder,
                      child: Text(
                        document.folderId == null
                            ? "Add to Folder"
                            : "Change Folder",
                      ),
                    ),
                    PopupMenuItem(
                      value: DocumentMenuAction.rename,
                      child: Text("Rename"),
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
                  children: [
                    BorderBox(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          spacing: 5,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            DocumentRow("Title", document.title),
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
                        ),
                      ),
                    ),
                    AspectRatio(
                      aspectRatio: 4 / 2,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.red,
                        ),
                        child: Center(
                          child: Text("Preview is not available yet"),
                        ),
                      ),
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

                    BorderBox(
                      child: ListTile(
                        title: Text("Share Document"),
                        leading: Icon(Icons.share_rounded),
                        onTap: () {},
                      ),
                    ),
                    BorderBox(
                      child: ListTile(
                        title: Text("Upload New Version"),
                        leading: Icon(Icons.file_download_outlined),
                        onTap:
                            () async => await Navigator.push(
                              context,
                              AddNewDocumentVersion.route(document.id),
                            ),
                      ),
                    ),
                    BorderBox(
                      child: ListTile(
                        title: Text("Manage Versions"),
                        leading: Icon(Icons.history_rounded),
                        trailing: Icon(Icons.arrow_forward_ios_rounded),
                        onTap:
                            () => Navigator.push(
                              context,
                              DocumentVersionHistory.route(document.id),
                            ),
                      ),
                    ),
                    BorderBox(
                      child: ListTile(
                        title: Text("Delete Document"),
                        leading: Icon(Icons.delete_rounded),
                        onTap: () {},
                      ),
                    ),
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
