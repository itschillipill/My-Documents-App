import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_documents/src/app/features/documents/cubit/documents_cubit.dart';
import 'package:my_documents/src/app/features/folders/model/folder.dart';
import 'package:my_documents/src/app/features/folders/pages/folder_view_page.dart';
import 'package:my_documents/src/app/widgets/border_box.dart';

class WarningBlock extends StatelessWidget {
  static const Folder _folder = Folder.warningFolder;
  static const Widget _placeholder = SliverToBoxAdapter(
    child: SizedBox.shrink(),
  );
  const WarningBlock({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DocumentsCubit, DocumentsState>(
      buildWhen: (previous, current) => current is DocumentsLoaded,
      builder: (context, state) {
        if (state is! DocumentsLoaded) return _placeholder;
        final documents = state.documents;
        final expiring = _folder.getDocuments(documents);
        if (expiring.isEmpty) return _placeholder;
        return SliverPersistentHeader(
          pinned: true,
          delegate: _WarningHeaderDelegate(
            child: BorderBox(
              child: ListTile(
                leading: Icon(Icons.warning),
                title: Text(
                  "Tap to view",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                subtitle: Text(
                  "${expiring.length} documents are expiring soon or expired",
                ),
                onTap:
                    () => Navigator.push(
                      context,
                      FolderViewPage.route(folder: _folder),
                    ),
              ),
            ),
          ),
        );
      },
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
