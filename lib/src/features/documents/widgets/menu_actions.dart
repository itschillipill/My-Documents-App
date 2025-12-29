import 'package:flutter/material.dart';

typedef MenuAction = (VoidCallback action, String title);

class MenuActions extends StatelessWidget {
  final List<MenuAction> actions;
  const MenuActions({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<MenuAction>(
      popUpAnimationStyle: AnimationStyle(curve: Curves.bounceInOut),
      icon: Icon(Icons.more_vert_rounded),
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onSelected: (action) => action.$1.call(),
      itemBuilder: (context) {
        return actions.map((action) {
          return PopupMenuItem(value: action, child: Text(action.$2));
        }).toList();
      },
    );
  }
}
