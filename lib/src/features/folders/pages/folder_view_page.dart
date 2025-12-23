import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_documents/src/features/documents/cubit/documents_cubit.dart';
import 'package:my_documents/src/features/folders/folder_actions.dart';
import 'package:my_documents/src/features/folders/model/folder.dart';
import 'package:my_documents/src/features/documents/widgets/document_card.dart';
import 'package:my_documents/src/utils/page_transition/app_page_route.dart';

class FolderViewPage extends StatefulWidget {
  static PageRoute route({required Folder folder}) => AppPageRoute.build(
    page: FolderViewPage._(folder: folder),
    transition: PageTransitionType.slideFromLeft,
  );
  final Folder folder;
  const FolderViewPage._({required this.folder});

  @override
  State<FolderViewPage> createState() => _FolderViewPageState();
}

class _FolderViewPageState extends State<FolderViewPage> {
  bool isSelecting = false;
  Set<int> selectedDocumentsIds = {};

  void resetSelecting() {
    setState(() {
      isSelecting = false;
      selectedDocumentsIds.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isSelecting,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && isSelecting) resetSelecting();
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -0.2),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child:
                !isSelecting
                    ? AppBar(
                      key: const ValueKey('normal'),
                      title: Text(widget.folder.name),
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
                                  onSelected:
                                      (action) =>
                                          action.call(context, widget.folder),
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
                    )
                    : AppBar(
                      key: const ValueKey('select'),
                      title: const Text("Select Documents"),
                      leading: IconButton(
                        onPressed: resetSelecting,
                        icon: const Icon(Icons.cancel_outlined),
                      ),
                      actions: [
                        IconButton(
                          onPressed: () {
                            BlocProvider.of<DocumentsCubit>(
                              context,
                            ).deleteDocuments(selectedDocumentsIds.toList());
                            resetSelecting();
                          },
                          icon: Icon(Icons.delete_rounded),
                        ),
                        IconButton(
                          onPressed: () {
                            BlocProvider.of<DocumentsCubit>(
                              context,
                            ).shareDocuments(selectedDocumentsIds.toList());
                            resetSelecting();
                          },
                          icon: Icon(Icons.share),
                        ),
                      ],
                    ),
          ),
        ),
        body: BlocBuilder<DocumentsCubit, DocumentsState>(
          buildWhen: (_, current) => current is DocumentsLoaded,
          builder: (context, state) {
            if (state is! DocumentsLoaded) {
              return Center(child: CircularProgressIndicator());
            }
            final documents = widget.folder.getDocuments(state.documents);
            return Padding(
              padding: EdgeInsets.all(12.0),
              child: Column(
                children: [
                  documents.isNotEmpty
                      ? Expanded(
                        child: ListView.builder(
                          itemCount: documents.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onLongPress:
                                  () => setState(() {
                                    selectedDocumentsIds.add(
                                      documents[index].id,
                                    );
                                    isSelecting = true;
                                  }),
                              child: DocumentCard(
                                document: documents[index],
                                isSelected: selectedDocumentsIds.contains(
                                  documents[index].id,
                                ),
                                onTap:
                                    !isSelecting
                                        ? null
                                        : () {
                                          setState(() {
                                            selectedDocumentsIds.addOrRemove(
                                              documents[index].id,
                                            );
                                          });
                                        },
                              ),
                            );
                          },
                        ),
                      )
                      : Center(child: Text("No documents found")),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

extension SetToggleExtension<T> on Set<T> {
  void addOrRemove(T item) {
    contains(item) ? remove(item) : add(item);
  }
}
