import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_documents/src/utils/sevices/message_service.dart';

class AppNavigator extends StatefulWidget {
  AppNavigator({super.key, required this.initialPages})
    : assert(initialPages.isNotEmpty, "initialPages must not be empty");

  final List<Page<Object?>> initialPages;

  static void change(
    BuildContext context,
    List<Page<Object?>> Function(List<Page<Object?>> pages) fn,
  ) => context.findAncestorStateOfType<_AppNavigatorState>()?.change(fn);

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  List<Page<Object?>> _pages = <Page<Object?>>[];
  @override
  void initState() {
    super.initState();
    _pages.addAll(widget.initialPages);
  }

  void change(List<Page<Object?>> Function(List<Page<Object?>> pages) fn) {
    if (!mounted) return;
    final pages = fn(_pages);
    if (identical(pages, _pages) ||
        pages.isEmpty ||
        listEquals(pages, _pages)) {
      return;
    }
    setState(() {
      _pages = pages;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: MessageService.navigatorKey,
      pages: _pages,
      onDidRemovePage: (page) {},
    );
  }
}

class AppNavigatorNew extends StatelessWidget {
  AppNavigatorNew({super.key, required this.pages})
    : assert(pages.isNotEmpty, "initialPages must not be empty");

  final List<Page<Object?>> pages;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: MessageService.navigatorKey,
      pages: pages,
      onDidRemovePage: (page) {},
    );
  }
}
