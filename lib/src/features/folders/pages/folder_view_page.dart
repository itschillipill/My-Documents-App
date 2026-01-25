import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_documents/src/core/extensions/extensions.dart';
import 'package:my_documents/src/features/documents/cubit/documents_cubit.dart';
import 'package:my_documents/src/features/documents/document_actions.dart';
import 'package:my_documents/src/features/documents/widgets/menu_actions.dart';
import 'package:my_documents/src/features/folders/folder_actions.dart';
import 'package:my_documents/src/features/folders/model/folder.dart';
import 'package:my_documents/src/features/documents/widgets/document_card.dart';
import 'package:my_documents/src/features/folders/model/sort_options.dart';
import 'package:my_documents/src/utils/page_transition/app_page_route.dart';

import '../../documents/model/document.dart' show Document, DocumentExtensions;

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
  SortOptions sortOptions = SortOptions.none;
  bool isReverse = false;

  void resetSelecting() {
    setState(() {
      isSelecting = false;
      selectedDocumentsIds.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final folder = widget.folder;
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
            child: !isSelecting
                ? AppBar(
                    key: const ValueKey('normal'),
                    title: Text(folder.folderTitle(context)),
                    actions: [
                      _buildSortButton(
                        context,
                        sortOptions,
                        isReverse,
                        onPressed: (i, so) => setState(() {
                          isReverse = i;
                          sortOptions = so;
                        }),
                      ),
                      if (!folder.isVirtual)
                        MenuActions(
                          actions: [
                            (
                              Rename$FolderAction(
                                context: context,
                                folder: folder,
                              ).call,
                              context.l10n.rename,
                            ),
                            (
                              Delete$FolderAction(
                                context: context,
                                folder: folder,
                              ).call,
                              context.l10n.delete,
                            ),
                          ],
                        ),
                    ],
                  )
                : AppBar(
                    key: const ValueKey('select'),
                    title: Text(selectedDocumentsIds.length.toString()),
                    centerTitle: false,
                    leading: IconButton(
                      onPressed: resetSelecting,
                      icon: const Icon(Icons.close_rounded),
                    ),
                    actions: [
                      IconButton(
                        onPressed: () {
                          Delete$DocumentAction(
                            documentsIds: selectedDocumentsIds.toList(),
                            context: context,
                          ).call();
                          resetSelecting();
                        },
                        icon: Icon(Icons.delete_rounded),
                      ),
                      IconButton(
                        onPressed: () {
                          Share$DocumentAction(
                            documents: context.deps.documentsCubit
                                .getDocumentsByIds(
                                  selectedDocumentsIds.toList(),
                                ),
                            context: context,
                          ).call();
                          resetSelecting();
                        },
                        icon: Icon(Icons.share),
                      ),
                    ],
                  ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: BlocSelector<DocumentsCubit, DocumentsState, List<Document>>(
            bloc: context.deps.documentsCubit,
            selector: (s) => sorted(
              folder.getDocuments(s.documents ?? []),
              sortOptions,
              isReverse,
            ),
            builder: (context, documents) {
              if (documents.isEmpty) {
                return Center(child: Text(context.l10n.noDocumentsFound));
              }
              return ListView.separated(
                itemCount: documents.length,
                separatorBuilder: (context, index) => const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  return DocumentCard(
                    document: documents[index],
                    isSelected: selectedDocumentsIds.contains(
                      documents[index].id,
                    ),
                    onLongPress: () => setState(() {
                      selectedDocumentsIds.add(documents[index].id);
                      isSelecting = true;
                    }),
                    onTap: isSelecting
                        ? () {
                            setState(
                              () => selectedDocumentsIds.addOrRemove(
                                documents[index].id,
                              ),
                            );
                            if (selectedDocumentsIds.isEmpty) {
                              resetSelecting();
                            }
                          }
                        : null,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

List<Document> sorted(
  List<Document> documents,
  SortOptions sortOptions,
  bool isReverse,
) {
  final sorted = [...documents];

  switch (sortOptions) {
    case SortOptions.none:
      break;

    case SortOptions.byAlphabet:
      sorted.sort(
        (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
      );
      break;

    case SortOptions.byUploadDate:
      sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      break;

    case SortOptions.byExpirationDate:
      sorted.sort((a, b) {
        final aDate = a.expirationDate;
        final bDate = b.expirationDate;

        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;

        return aDate.compareTo(bDate);
      });
      break;
  }

  return isReverse ? sorted.reversed.toList() : sorted;
}

Widget _buildSortButton(
  BuildContext context,
  SortOptions sortOptions,
  bool isReverse, {
  required Function(bool, SortOptions) onPressed,
}) {
  return IconButton(
    icon: const Icon(Icons.sort_rounded),
    onPressed: () async {
      final result = await showModalBottomSheet<(bool, SortOptions)>(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (context) {
          SortOptions tempSort = sortOptions;
          bool tempReverse = isReverse;

          return StatefulBuilder(
            builder: (context, setModalState) {
              final theme = Theme.of(context);
              final secondaryColor = theme.colorScheme.secondary;

              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    Text(
                      context.l10n.sortBy,
                      style: theme.textTheme.titleMedium,
                    ),

                    const SizedBox(height: 8),

                    SwitchListTile(
                      title: Text(context.l10n.reverseOrder),
                      value: tempReverse,
                      onChanged: (v) => setModalState(() => tempReverse = v),
                    ),

                    const Divider(),

                    ...SortOptions.values.map((e) {
                      final isSelected = e == tempSort;

                      return ListTile(
                        title: Text(e.title(context)),
                        trailing: isSelected
                            ? Icon(Icons.check_rounded, color: secondaryColor)
                            : null,
                        onTap: () => setModalState(() => tempSort = e),
                      );
                    }),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, (tempReverse, tempSort));
                        },
                        child: Text(context.l10n.apply),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );

      if (result != null) {
        onPressed(result.$1, result.$2);
      }
    },
  );
}

extension SetToggleExtension<T> on Set<T> {
  void addOrRemove(T item) {
    contains(item) ? remove(item) : add(item);
  }
}
