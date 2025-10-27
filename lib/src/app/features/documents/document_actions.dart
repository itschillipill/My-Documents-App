import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../folders/pages/select_folder_page.dart';
import 'cubit/documents_cubit.dart';
import 'model/document.dart';
typedef DocumentActionHandler = Future<void> Function(
  BuildContext context,
  Document document,
);

enum DocumentMenuAction { 
  changeFolder(_changeFolder), 
  rename(_rename);
final DocumentActionHandler call;
const DocumentMenuAction(this.call);
 }
 
 Future<void> _rename(BuildContext context, Document document)async{
 }
 Future<void> _changeFolder(BuildContext context, Document document)async{
 final folder = await Navigator.push(
                      context,
                      SelectFolderPage.route(),
                    );
                    if (folder != null&&context.mounted) {
                      await context.read<DocumentsCubit>().updateDocument(
                        document.copyWith(folderId: folder.id),
                      );
                    }
 }