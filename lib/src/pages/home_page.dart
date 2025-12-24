import 'package:flutter/material.dart';
import 'package:my_documents/src/core/extensions/extensions.dart';
import 'package:my_documents/src/widgets/document_block.dart';
import 'package:my_documents/src/widgets/folders_block.dart';
import 'package:my_documents/src/widgets/warning_block.dart';
import '../features/settings/pages/settings_page.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: EdgeInsets.all(8),
      child: Column(
        spacing: 10,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.appTitle,
                    style: context.theme.textTheme.headlineLarge,
                  ),
                  Text(context.l10n.quickAccess),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.push(context, SettingsPage.route()),
                icon: Icon(Icons.settings),
              ),
            ],
          ),
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: DocumentsBlock()),
                const WarningBlock(),
                SliverToBoxAdapter(child: FoldersBlock()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
