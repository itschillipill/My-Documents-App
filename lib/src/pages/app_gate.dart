import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:my_documents/src/features/folders/pages/add_folder_page.dart';

import '../features/documents/pages/add_document_screen.dart';
import 'search_page.dart';
import 'home_page.dart';

class AppGate extends StatefulWidget {
  const AppGate({super.key});

  @override
  State<AppGate> createState() => _AppGateState();
}

class _AppGateState extends State<AppGate> {
  int _selectedIndex = 0;
  final PageController _controller = PageController(initialPage: 0);
  final List<Widget> pages = [MyHomePage(), SearchPage()];
  final List<BottomNavigationBarItem> navItems = [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
    BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _selectedIndex != 1,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _selectedIndex == 1) {
          setState(() {
            _selectedIndex = 0;
            _controller.animateToPage(
              0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.ease,
            );
          });
        }
      },
      child: Scaffold(
        body: PageView(
          controller: _controller,
          onPageChanged: (value) {
            setState(() {
              _selectedIndex = value;
            });
          },
          children: pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (value) {
            setState(() {
              _selectedIndex = value;
              _controller.animateToPage(
                value,
                duration: Duration(milliseconds: 200),
                curve: Curves.ease,
              );
            });
          },
          items: navItems,
        ),
        floatingActionButton: _buildFAB(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  Widget? _buildFAB() {
    if (_selectedIndex != 0) return null;

    return SpeedDial(
      icon: Icons.add,
      activeIcon: Icons.close,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      children: [
        SpeedDialChild(
          child: const Icon(Icons.upload_file_rounded),
          label: 'Add Document',
          onTap: () => Navigator.push(context, AddDocumentScreen.route()),
        ),
        SpeedDialChild(
          child: const Icon(Icons.create_new_folder),
          label: 'Add Folder',
          onTap: () => Navigator.push(context, AddFolderPage.route()),
        ),
      ],
    );
  }
}
