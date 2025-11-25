import 'dart:io' show File;

import 'package:flutter/material.dart';

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
    return AspectRatio(
      aspectRatio: 4 / 2,
      child: GestureDetector(
        onTap: () async {
          if (isImage) await _openFullScreenViewer(context);
        },
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.blueGrey,
            image:
                isImage
                    ? DecorationImage(
                      image: FileImage(File(path)),
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      onError:
                          (exception, stackTrace) => debugPrint(
                            "coudn't load image $exception-$stackTrace",
                          ),
                    )
                    : null,
          ),
          child:
              !isImage
                  ? Center(
                    child: Text("Preview is not available for this document"),
                  )
                  : null,
        ),
      ),
    );
  }

  Future<void> _openFullScreenViewer(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              appBar: AppBar(title: Text('Image Viewer')),
              body: Container(
                color: Colors.black,
                child: InteractiveViewer(
                  boundaryMargin: EdgeInsets.all(20.0),
                  minScale: 0.5,
                  maxScale: 3.0,
                  child: Center(
                    child: Image.file(File(path), fit: BoxFit.contain),
                  ),
                ),
              ),
            ),
      ),
    );
  }
}
