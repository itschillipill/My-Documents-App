import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';

class DocumentErrorPage extends StatelessWidget {
  final VoidCallback? getErrorInfo;
  const DocumentErrorPage({super.key, this.getErrorInfo});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: Column(
          spacing: 12,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Something went wrong!"),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Go Back"),
            ),
            if (kDebugMode)
              ElevatedButton(onPressed: getErrorInfo, child: Text("Get info")),
          ],
        ),
      ),
    );
  }
}
