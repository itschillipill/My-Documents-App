import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_documents/src/app/extensions/extensions.dart';
import 'package:my_documents/src/app/features/documents/cubit/documents_cubit.dart';
import 'package:my_documents/src/app/features/documents/model/document.dart';
import 'package:my_documents/src/app/features/folders/model/folder.dart';
import 'package:my_documents/src/app/features/documents/pages/document_view_page.dart';
import 'package:my_documents/src/app/features/folders/pages/folder_view_page.dart';

class DocumentsBlock extends StatelessWidget {
  static const Folder _allFolder = Folder.allFolder;
  const DocumentsBlock({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DocumentsCubit, DocumentsState>(
      buildWhen: (previous, current) => current is DocumentsLoaded,
      builder: (context, state) {
        if (state is DocumentsLoaded) {
          final documents = state.documents;

          final favorites = documents.where((e) => e.isFavorite).toList();
          final nonFavorites = documents.where((e) => !e.isFavorite).toList();
          final prioritizedDocs = [...favorites, ...nonFavorites];

          final docsToShow = prioritizedDocs.take(3).toList();
          if (docsToShow.isEmpty) {
            return Center(child: Text("No documents here, yet!"));
          }

          final items = [...docsToShow, null];

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            itemCount: items.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width > 700 ? 4 : 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 3.5 / 2,
            ),
            itemBuilder: (context, index) {
              final doc = items[index];
              return _buildDocCard(doc, context);
            },
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildCard(Widget icon, {VoidCallback? onTap, Widget? label}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 5,
        children: [icon, if (label != null) label],
      ).withBorder(padding: EdgeInsets.all(16)),
    );
  }

  Widget _buildDocCard(Document? doc, BuildContext context) {
    final isAll = doc == null;
    return _buildCard(
      onTap: () {
        if (isAll) {
          Navigator.push(context, FolderViewPage.route(folder: _allFolder));
        } else {
          Navigator.push(context, DocumentViewPage.route(doc.id));
        }
      },
      Icon(isAll ? Icons.folder_open : Icons.description, size: 40),
      label: Text(
        isAll ? "All" : doc.title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
