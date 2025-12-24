import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_documents/src/core/extensions/extensions.dart';
import 'package:my_documents/src/features/folders/cubit/folders_cubit.dart';
import 'package:my_documents/src/features/folders/model/folder.dart';
import 'package:my_documents/src/widgets/border_box.dart';
import 'package:my_documents/src/utils/page_transition/app_page_route.dart';
import 'add_folder_page.dart';

class SelectFolderPage extends StatelessWidget {
  static final Folder _noFolder = Folder.noFolder;
  static Route<Folder> route() => AppPageRoute.build(
    page: SelectFolderPage(),
    transition: PageTransitionType.slideFromLeft,
  );
  const SelectFolderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FoldersCubit, FoldersState>(
      listener: (context, state) {},
      buildWhen: (previous, current) => current is FoldersLoaded,
      builder: (context, state) {
        final folders = (state as FoldersLoaded).folders;
        return Scaffold(
          appBar: AppBar(
            title: Text(
              "Select Folder",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          body: SafeArea(
            minimum: EdgeInsets.all(8),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: BorderBox(
                    child: ListTile(
                      leading: Icon(Icons.folder_off_outlined),
                      title: Text(_noFolder.name),
                      onTap: () => Navigator.pop(context, _noFolder),
                      trailing: Icon(Icons.arrow_forward_ios_rounded),
                    ),
                  ),
                ),
                Expanded(
                  child:
                      folders.isNotEmpty
                          ? ListView.builder(
                            itemCount: folders.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                child: BorderBox(
                                  child: ListTile(
                                    leading: Icon(Icons.folder_rounded),
                                    title: Text(folders[index].name),
                                    onTap:
                                        () => Navigator.pop(
                                          context,
                                          folders[index],
                                        ),
                                    trailing: Icon(
                                      Icons.arrow_forward_ios_rounded,
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                          : Center(
                            child: Text(
                              context.l10n.noFoldersFound,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await Navigator.push(context, AddFolderPage.route());
            },
            child: Icon(Icons.add),
          ),
        );
      },
    );
  }
}
