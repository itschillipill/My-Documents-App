import 'package:flutter/material.dart';
import 'package:my_documents/src/core/extensions/extensions.dart';
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
  List<BottomNavigationBarItem> navItems(BuildContext ctx) => [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: ctx.l10n.home),
    BottomNavigationBarItem(icon: Icon(Icons.search), label: ctx.l10n.search),
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
          selectedItemColor: Theme.of(context).colorScheme.secondary,
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
          items: navItems(context),
        ),
        floatingActionButton: _buildFAB(context),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  Widget? _buildFAB(BuildContext ctx) {
    if (_selectedIndex != 0) return null;

    return FloatingActionButton(
      onPressed: ()=> _showAddMenu(context),
      tooltip: ctx.l10n.addDocument,
      child: Icon(Icons.add),
    );
  }
}
void _showAddMenu(BuildContext context) async{
   await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              // Document button
              _buildMenuButton(
                context,
                icon: Icons.description_rounded,
                label: context.l10n.addDocument,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, AddDocumentScreen.route());
                },
              ),
              // Folder button
              _buildMenuButton(
                context,
                icon: Icons.folder_rounded,
                label: context.l10n.addFolder,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, AddFolderPage.route());
                },
              ),
              // Close button
              _buildMenuButton(
                context,
                icon: Icons.close_rounded,
                label: context.l10n.cancel,
                onTap: () => Navigator.pop(context),
                isCancel: true,
              ),
            ],
          ),
        );
      },
    );
  }
Widget _buildMenuButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isCancel = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Row(
            children: [
              Icon(
                icon,
                color: isCancel
                    ? colorScheme.onSurface.withValues(alpha: 0.6)
                    : colorScheme.primary,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: isCancel
                          ? colorScheme.onSurface.withValues(alpha: 0.6)
                          : colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }