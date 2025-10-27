import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_documents/src/utils/sevices/file_service.dart';
import 'build_card.dart';

class FilePickerBlock extends StatelessWidget {
  final void Function(String? path) onSelected;
  const FilePickerBlock({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return BuildSection(
                    children: [
                      Text(
                        "Choose Method",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Row(
                        spacing: 10,
                        children: [
                          Expanded(
                            child: BuildCard(
                              text: "Take a photo",
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
                              text: "From Gallery",
                              icon: Icons.photo_size_select_actual,
                              onTap:
                                  () => FileService.pickFile(
                                    context,
                                    imageSource: ImageSource.gallery,
                                    onSelected: onSelected
                                  ),
                            ),
                          ),
                        ],
                      ),
                      BuildCard(
                        text: "Choose a file",
                        icon: Icons.file_present_outlined,
                        onTap:
                            () => FileService.pickFile(
                              context,
                              onSelected: onSelected
                            ),
                      ),
                    ],
                  );
  }
}
