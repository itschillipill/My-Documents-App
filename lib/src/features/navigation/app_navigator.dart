import 'package:flutter/material.dart';
import 'package:my_documents/src/sevices/message_service.dart';

class AppNavigator extends StatefulWidget {
  final List<Page<Object?>> initialPages;
  
  const AppNavigator({super.key, required this.initialPages});

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  late List<Page<Object?>> _pages;

  @override
  void initState() {
    super.initState();
    _pages = List.from(widget.initialPages);
  }

  @override
  void didUpdateWidget(covariant AppNavigator oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.initialPages.length != oldWidget.initialPages.length ||
        widget.initialPages.map((p) => p.key).join() != 
        oldWidget.initialPages.map((p) => p.key).join()) {
      
      setState(() {
        _pages = List.from(widget.initialPages);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) {
        debugPrint("onPopInvoked called, didPop: $didPop");
        if (!didPop) {
          if (_pages.length > 1) {
            setState(() {
              _pages.removeLast();
            });
          }
        }
      },
      child: Navigator(
        key: MessageService.navigatorKey,
        pages: _pages,
        onDidRemovePage: (page) {
          debugPrint("onDidRemovePage called for page: ${page.key}");
          if (mounted) {
            setState(() {
              _pages.removeWhere((p) => p.key == page.key);
            });
          }
        },
      ),
    );
  }
}