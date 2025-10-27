import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_documents/src/app/features/documents/cubit/documents_cubit.dart';
import 'package:my_documents/src/app/features/documents/model/document.dart';
import 'package:my_documents/src/app/features/folders/folder_actions.dart';
import 'package:my_documents/src/app/features/folders/model/folder.dart';
import 'package:my_documents/src/app/features/documents/pages/document_view_page.dart';
import 'package:my_documents/src/app/features/documents/widgets/document_card.dart';
import 'package:my_documents/src/utils/page_transition/app_page_route.dart';

class FolderViewPage extends StatefulWidget {
  static PageRoute route({required Folder folder}) => AppPageRoute.build(
    page: FolderViewPage(folder: folder),
    transition: PageTransitionType.fade,
  );
  final Folder folder;
  const FolderViewPage({super.key, required this.folder});

  @override
  State<FolderViewPage> createState() => _FolderViewPageState();
}

class _FolderViewPageState extends State<FolderViewPage> {
  List<Document> documents = [];
  late DocumentsCubit _documentsCubit;
  @override
  void initState() {
    _documentsCubit = context.read<DocumentsCubit>();
    if (_documentsCubit.state is DocumentsLoaded) {
      documents = widget.folder.getDocuments(
        (_documentsCubit.state as DocumentsLoaded).documents,
      );
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.folder.name,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions:
            widget.folder.isVirtual
                ? null
                : [
                  PopupMenuButton<FolderMenuActions>(
                    popUpAnimationStyle: AnimationStyle(
                      curve: Curves.bounceInOut,
                    ),
                    icon: Icon(Icons.more_vert_rounded),
                    position: PopupMenuPosition.under,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    onSelected: (action) => action.call(context, widget.folder),
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem(
                          value: FolderMenuActions.rename,
                          child: Text("Rename"),
                        ),
                        PopupMenuItem(
                          value: FolderMenuActions.delete,
                          child: Text("Delete"),
                        ),
                      ];
                    },
                  ),
                ],
      ),
      body: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          children: [
            documents.isNotEmpty
                ? Expanded(
                  child: ListView.builder(
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      return DocumentCard(
                        document: documents[index],
                        onTap:
                            () => Navigator.push(
                              context,
                              DocumentViewPage.route(documents[index].id),
                            ),
                      );
                    },
                  ),
                )
                : Center(child: Text("No documents found")),
          ],
        ),
      ),
    );
  }
}
