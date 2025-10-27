import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_documents/src/app/features/folders/cubit/folders_cubit.dart';
import 'package:my_documents/src/app/widgets/border_box.dart';
import 'package:my_documents/src/utils/page_transition/app_page_route.dart';

import '../model/folder.dart';

class AddFolderPage extends StatefulWidget {
  static PageRoute route() => AppPageRoute.build(
    page: const AddFolderPage(),
    transition: PageTransitionType.fade,
  );

  const AddFolderPage({super.key});

  @override
  State<AddFolderPage> createState() => _AddFolderPageState();
}

class _AddFolderPageState extends State<AddFolderPage> {
  final TextEditingController _nameController = TextEditingController();
  bool isFavorite = false;

  void _saveFolder(BuildContext context) {
    final cubit = context.read<FoldersCubit>();
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter folder name")));
      return;
    }
    if ((cubit.state as FoldersLoaded).folders.any(
      (element) => element.name == name,
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("This folder already exists")),
      );
      return;
    }

    final folder = Folder(id: 0, name: name);

    cubit.addFolder(folder);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add Folder",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton(
              onPressed: () => _saveFolder(context),
              child: const Text("Save"),
            ),
          ),
        ],
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 20,
          children: [
            Text(
              "Folder Details",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            BorderBox(
              child: TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: "Folder Name",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
