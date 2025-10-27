import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_documents/src/app/features/documents/cubit/documents_cubit.dart';
import 'package:my_documents/src/app/widgets/border_box.dart';
import 'package:my_documents/src/app/features/documents/widgets/document_version_card.dart';
import 'package:my_documents/src/utils/page_transition/app_page_route.dart';

class DocumentVersionHistory extends StatelessWidget {
  static PageRoute route(int documentId) => AppPageRoute.build(
    page: DocumentVersionHistory(documentId: documentId),
    transition: PageTransitionType.slideFromRight,
  );

  final int documentId;
  const DocumentVersionHistory({super.key, required this.documentId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DocumentsCubit, DocumentsState>(
      buildWhen: (previous, current) => (current is DocumentsLoaded),
      builder: (context, state) {
        if (state is! DocumentsLoaded) return SizedBox.shrink();
        final document = state.documents.firstWhere((d) => d.id == documentId);
        final versions = [
          ...document.versions.where((v) => v.id == document.currentVersionId),
          ...document.versions.where((v) => v.id != document.currentVersionId),
        ];
        return Scaffold(
          appBar: AppBar(
            title: Text(
              "Version History",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            actions: [
              IconButton(onPressed: () {}, icon: Icon(Icons.more_vert_rounded)),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                spacing: 20,
                children: [
                  BorderBox(
                    child: ListTile(
                      title: Text(document.title),
                      leading: Icon(Icons.description_rounded),
                      subtitle: Text("${versions.length} versions found"),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: versions.length,
                      itemBuilder: (context, index) {
                        return DocumentVersionCard(
                          onDelete: () {},
                          onSetCurrent: () {},
                          documentVersion: versions[index],
                          isCurrent:
                              document.currentVersionId == versions[index].id,
                          onOpen: () {},
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
