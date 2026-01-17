import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_documents/src/core/extensions/extensions.dart';
import 'package:my_documents/src/features/documents/cubit/documents_cubit.dart';
import 'package:my_documents/src/features/folders/model/folder.dart';
import 'package:my_documents/src/features/folders/pages/folder_view_page.dart';

import '../features/documents/model/document.dart';

class WarningBlock extends StatelessWidget {
  static const Folder _folder = Folder.warningFolder;
  static const Widget _placeholder = SliverToBoxAdapter(
    child: SizedBox.shrink(),
  );

  const WarningBlock({super.key});

  @override
  Widget build(BuildContext context) {
    // Слушаем только список документов
    final documents = context.select<DocumentsCubit, List<Document>>(
      (cubit) => cubit.documentsOrEmpty,
    );

    // Фильтруем документы, которые скоро истекают или уже истекли
    final expiring = _folder.getDocuments(documents);
    if (expiring.isEmpty) return _placeholder;

    return SliverPersistentHeader(
      pinned: true,
      delegate: _WarningHeaderDelegate(
        child: ListTile(
          tileColor: Theme.of(context).cardColor,
          leading: const Icon(Icons.warning),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Text(
            context.l10n.tapToView,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          subtitle: Text(
            "${expiring.length} ${context.l10n.documentsExpiring}",
            style: const TextStyle(color: Colors.redAccent),
          ),
          onTap: () =>
              Navigator.push(context, FolderViewPage.route(folder: _folder)),
        ),
      ),
    );
  }
}

class _WarningHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _WarningHeaderDelegate({required this.child});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      elevation: overlapsContent ? 4 : 0,
      child: SizedBox(height: maxExtent, child: child),
    );
  }

  @override
  double get maxExtent => 80.0;

  @override
  double get minExtent => 80.0;

  @override
  bool shouldRebuild(_) => true;
}
