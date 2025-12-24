import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_documents/src/core/extensions/extensions.dart';
import 'package:my_documents/src/utils/sevices/file_service.dart';
import 'package:path/path.dart' as p;
import 'build_card.dart';

class FilePickerBlock extends StatelessWidget {
  final void Function(String? path) onSelected;
  final String? path;
  const FilePickerBlock({
    super.key,
    required this.onSelected,
    required this.path,
  });

  @override
  Widget build(BuildContext context) {
    if (path != null) {
      return BuildSection(
        children: [
          BuildCard(
            text: p.basename(path!),
            icon: Icons.insert_drive_file,
            onTap: () {},
          ),
          ElevatedButton(
            onPressed: () => onSelected(null),
            child: Text(context.l10n.removeFile),
          ),
        ],
      );
    }
    return BuildSection(
      children: [
        Text(context.l10n.chooseMethod, style: Theme.of(context).textTheme.bodyLarge),
        Row(
          spacing: 10,
          children: [
            Expanded(
              child: BuildCard(
                text: context.l10n.takePhoto,
                icon: Icons.camera_alt,
                onTap:
                    () async => FileService.pickFile(
                      context,
                      imageSource: ImageSource.camera,
                      onSelected: onSelected,
                    ),
              ),
            ),
            Expanded(
              child: BuildCard(
                text: context.l10n.fromGallery,
                icon: Icons.photo_size_select_actual,
                onTap:
                    () => FileService.pickFile(
                      context,
                      imageSource: ImageSource.gallery,
                      onSelected: onSelected,
                    ),
              ),
            ),
          ],
        ),
        BuildCard(
          text: context.l10n.chooseFile,
          icon: Icons.file_present_outlined,
          onTap: () => FileService.pickFile(context, onSelected: onSelected),
        ),
      ],
    );
  }
}
