import 'dart:io' show File;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:my_documents/src/core/extensions/extensions.dart';

class DocumentPreviewer extends StatelessWidget {
  final String path;
  final bool isImage;
  const DocumentPreviewer({
    super.key,
    required this.path,
    required this.isImage,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return isImage
            ? GestureDetector(
                onTap: () async {
                  if (isImage) await _openFullScreenViewer(context);
                },
                child: OptimizedImageFromFile(filePath: path),
              )
            : AspectRatio(
                aspectRatio: 4 / 2,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.transparent,
                  ),
                  child: Center(
                    child: Text(
                      context.l10n.noPreview,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                ),
              );
      },
    );
  }

  Future<void> _openFullScreenViewer(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text(context.l10n.preview)),
          body: Container(
            color: Colors.black,
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 3.0,
              child: Center(child: OptimizedImageFromFile(filePath: path)),
            ),
          ),
        ),
      ),
    );
  }
}

class OptimizedImageFromFile extends StatefulWidget {
  final String filePath;

  const OptimizedImageFromFile({super.key, required this.filePath});

  @override
  OptimizedImageFromFileState createState() => OptimizedImageFromFileState();
}

class OptimizedImageFromFileState extends State<OptimizedImageFromFile> {
  ui.Image? _image;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOptimizedImage();
  }

  Future<void> _loadOptimizedImage() async {
    try {
      final file = File(widget.filePath);
      final bytes = await file.readAsBytes();

      // Декодируем оригинальное изображение
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final originalImage = frame.image;

      final originalWidth = originalImage.width;
      final originalHeight = originalImage.height;
      if (mounted) {
        // Оптимальный размер по ширине экрана
        final screenWidth = MediaQuery.sizeOf(context).width;
        final optimalWidth =
            (screenWidth * MediaQuery.devicePixelRatioOf(context))
                .round()
                .clamp(500, 500); // Можно настроить минимальный размер

        // Если изображение уже маленькое, оставляем как есть
        if (originalWidth <= optimalWidth) {
          setState(() {
            _image = originalImage;
            _isLoading = false;
          });
          return;
        }

        final scaleFactor = optimalWidth / originalWidth;
        final optimalHeight = (originalHeight * scaleFactor).round();

        // Рисуем уменьшенную копию
        final recorder = ui.PictureRecorder();
        final canvas = ui.Canvas(recorder);
        final paint = ui.Paint()..filterQuality = ui.FilterQuality.medium;

        canvas.drawImageRect(
          originalImage,
          ui.Rect.fromLTWH(
            0,
            0,
            originalWidth.toDouble(),
            originalHeight.toDouble(),
          ),
          ui.Rect.fromLTWH(
            0,
            0,
            optimalWidth.toDouble(),
            optimalHeight.toDouble(),
          ),
          paint,
        );

        final picture = recorder.endRecording();
        final resizedImage = await picture.toImage(optimalWidth, optimalHeight);
        originalImage.dispose();

        _image = resizedImage;
      }
    } catch (e) {
      /// ....
    } finally {
      _isLoading = false;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _image?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_image == null) {
      return const Center(child: Text('Ошибка загрузки'));
    }

    return RawImage(
      image: _image,
      fit: BoxFit.contain,
      width: _image!.width.toDouble() / MediaQuery.devicePixelRatioOf(context),
      height:
          _image!.height.toDouble() / MediaQuery.devicePixelRatioOf(context),
    );
  }
}
