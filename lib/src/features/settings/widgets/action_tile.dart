import 'package:flutter/material.dart';

ListTile settingsTile({
  required IconData icon,
  required String title,
  String? subtitle,
  Color? iconColor,
  VoidCallback? onTap,
}) {
  return ListTile(
    leading: Icon(icon, color: iconColor),
    title: Text(title),
    subtitle: subtitle != null ? Text(subtitle) : null,
    trailing: const Icon(Icons.arrow_forward_ios_rounded),
    onTap: onTap,
  );
}
