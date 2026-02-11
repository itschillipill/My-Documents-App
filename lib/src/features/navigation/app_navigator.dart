import 'package:flutter/material.dart';
import 'package:my_documents/src/sevices/message_service.dart';
import 'package:my_documents/src/sevices/observer.dart';

class AppNavigator extends StatelessWidget {
  AppNavigator({super.key, required this.pages})
    : assert(pages.isNotEmpty, "initialPages must not be empty");

  final List<Page<Object?>> pages;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: MessageService.navigatorKey,
      pages: pages,
      observers: [LoggingNavigatorObserver()],
      onDidRemovePage: (page) {},
    );
  }
}
