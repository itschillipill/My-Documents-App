import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_documents/src/core/extensions/extensions.dart';
import 'package:my_documents/src/features/documents/cubit/documents_cubit.dart';
import 'package:my_documents/src/features/documents/presentation/document_view_screen.dart';
import 'package:my_documents/src/presentation/widgets/border_box.dart';
import 'package:my_documents/src/features/documents/presentation/widgets/document_version_card.dart';
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
      bloc: context.deps.documentsCubit,
      buildWhen: (previous, current) => current.documents != previous.documents,
      builder: (context, state) {
        final document = (state.documents ?? []).firstWhere(
          (d) => d.id == documentId,
        );
        final versionsWithIndex =
            document.versions
                .asMap()
                .entries
                .map((e) => (version: e.value, index: e.key))
                .toList()
              ..sort((a, b) {
                if (a.version.id == document.currentVersionId) return -1;
                if (b.version.id == document.currentVersionId) return 1;
                return 0;
              });
        debugPrint(versionsWithIndex.toString());
        return Scaffold(
          appBar: AppBar(
            title: Text(
              context.l10n.versionHistory,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: versionsWithIndex.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: BorderBox(
                              child: ListTile(
                                title: Text(document.title),
                                leading: Icon(Icons.description_rounded),
                                subtitle: Text(
                                  "${versionsWithIndex.length} ${context.l10n.versions}",
                                ),
                              ),
                            ),
                          );
                        }
                        final version = versionsWithIndex[index - 1].version;
                        return DocumentVersionCard(
                          index: versionsWithIndex[index - 1].index,
                          documentVersion: version,
                          isCurrent: version.id == document.currentVersionId,
                          onDelete: () {},
                          onSetCurrent: () {},
                          onOpen: () {
                            Navigator.push(
                              context,
                              DocumentViewScreen.route(
                                documentId,
                                versionId: version.id,
                              ),
                            );
                          },
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
