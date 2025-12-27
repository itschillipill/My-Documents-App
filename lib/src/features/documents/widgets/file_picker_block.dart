import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_documents/src/core/extensions/extensions.dart';
import 'package:my_documents/src/utils/sevices/file_service.dart';
import 'package:path/path.dart' as p;

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.file_present_rounded,
                size: 20,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                "file",
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (path != null) ...[
            // Selected file
            _buildSelectedFile(context, path!, colorScheme),
            const SizedBox(height: 12),
            _buildRemoveButton(context, colorScheme),
          ] else  _buildSelectionGrid(context, colorScheme),
          
        ],
      ),
    );
  }

  Widget _buildSelectedFile(
    BuildContext context,
    String path,
    ColorScheme colorScheme,
  ) {
    final fileName = p.basename(path);
    final fileExtension = p.extension(path).toLowerCase();
    final isImage = ['.jpg', '.jpeg', '.png', '.gif', '.bmp']
        .contains(fileExtension);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          // Optional: Show file preview or details
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.primary.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isImage ? Icons.image_rounded : Icons.description_rounded,
                  size: 24,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatFileSize(path),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.check_circle_rounded,
                color: Colors.green,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRemoveButton(BuildContext context, ColorScheme colorScheme) {
    return SizedBox(
      height: 48,
      child: OutlinedButton.icon(
        onPressed: () => onSelected(null),
        icon: const Icon(Icons.close_rounded),
        label: Text(context.l10n.removeFile),
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.error,
          side: BorderSide(color: colorScheme.error.withOpacity(0.3)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionGrid(BuildContext context, ColorScheme colorScheme) {
    return Column(
      children: [
        // Camera and Gallery row
        Row(
          children: [
            Expanded(
              child: _buildSelectionOption(
                context: context,
                icon: Icons.camera_alt_rounded,
                label: context.l10n.takePhoto,
                colorScheme: colorScheme,
                onTap: () => FileService.pickFile(
                  context,
                  imageSource: ImageSource.camera,
                  onSelected: onSelected,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSelectionOption(
                context: context,
                icon: Icons.photo_library_rounded,
                label: context.l10n.fromGallery,
                colorScheme: colorScheme,
                onTap: () => FileService.pickFile(
                  context,
                  imageSource: ImageSource.gallery,
                  onSelected: onSelected,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // File picker
        _buildSelectionOption(
          context: context,
          icon: Icons.folder_open_rounded,
          label: context.l10n.chooseFile,
          colorScheme: colorScheme,
          onTap: () => FileService.pickFile(
            context,
            onSelected: onSelected,
          ),
          isFullWidth: true,
        ),
      ],
    );
  }

  Widget _buildSelectionOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required ColorScheme colorScheme,
    required VoidCallback onTap,
    bool isFullWidth = false,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: isFullWidth ? double.infinity : null,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatFileSize(String path) {
    // This is a placeholder - you'll need to implement actual file size reading
    // For now, we'll return the file extension
    final extension = p.extension(path).toUpperCase();
    return extension.isNotEmpty ? extension.substring(1) : 'File';
  }
}