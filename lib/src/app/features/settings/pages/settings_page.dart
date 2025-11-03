import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_documents/src/app/features/auth/auth_executor.dart';
import 'package:my_documents/src/app/features/settings/cubit/settings_cubit.dart';
import 'package:my_documents/src/app/features/folders/widgets/section_block.dart';
import 'package:my_documents/src/utils/app_data.dart';
import 'package:my_documents/src/utils/sevices/message_service.dart';

import '../../../../utils/page_transition/app_page_route.dart';
import '../../../dependencies/widgets/dependencies_scope.dart';

class SettingsPage extends StatefulWidget {
  static PageRoute route() => AppPageRoute.build(
    page: SettingsPage(),
    transition: PageTransitionType.slideFromRight,
  );
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Future<bool> _verifyOldPin(AuthenticationExecutor authExecutor) async {
    final oldPin = await _showPinSheet("Enter current PIN");
    return oldPin != null &&
        oldPin.isNotEmpty &&
        await authExecutor.verefyPin(oldPin);
  }

  Future<void> _createOrChangePin(
    AuthenticationExecutor authExecutor, {
    bool verifyOld = false,
  }) async {
    if (verifyOld && !await _verifyOldPin(authExecutor)) return;

    final newPin = await _showPinSheet("Enter new PIN");
    if (newPin?.isNotEmpty ?? false) {
      await authExecutor.createOrChangePin(newPin!);
      if (mounted) {
        setState(() {});
        MessageService.showSnackBar("PIN updated successfully");
      }
    }
  }

  Future<void> _deletePin(AuthenticationExecutor authExecutor) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Delete PIN"),
            content: const Text("Are you sure you want to remove your PIN?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text("Delete"),
              ),
            ],
          ),
    );

    if (confirm == true && await _verifyOldPin(authExecutor)) {
      await authExecutor.clearPin();
      setState(() {});
      MessageService.showSnackBar("PIN deleted");
    }
  }

  Future<String?> _showPinSheet(String title) async {
    final controller = TextEditingController();
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
              Text(title, style: Theme.of(ctx).textTheme.titleLarge),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                obscureText: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter PIN",
                ),
              ),
              Row(
                spacing: 20,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("Cancel"),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, controller.text),
                      child: const Text("OK"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final authExecutor = DependenciesScope.of(context).authExecutor;
        return Scaffold(
          appBar: AppBar(
            title: Text(
              "Settings",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                spacing: 20,
                children: [
                  SizedBox(height: 1),
                  SectionBlock(
                    title: "Security",
                    children:
                        authExecutor.hasPassword
                            ? [
                              _buildTile(
                                icon: Icons.lock_rounded,
                                title: "Change PIN",
                                subtitle: "Update your security PIN",
                                onTap:
                                    () => _createOrChangePin(
                                      authExecutor,
                                      verifyOld: true,
                                    ),
                              ),
                              _buildTile(
                                icon: Icons.delete_forever,
                                iconColor: Colors.red,
                                title: "Delete PIN",
                                subtitle: "Remove your PIN protection",
                                onTap: () => _deletePin(authExecutor),
                              ),
                              SwitchListTile.adaptive(
                                value:
                                    context
                                            .read<SettingsCubit>()
                                            .canUseBiometrics
                                        ? state.useBiometrics
                                        : false,
                                title: const Text("Biometric Authentication"),
                                subtitle: const Text(
                                  "Use fingerprint or face ID",
                                ),
                                secondary: const Icon(
                                  Icons.fingerprint_rounded,
                                ),
                                onChanged: (v) {
                                  if (!context
                                      .read<SettingsCubit>()
                                      .canUseBiometrics) {
                                    MessageService.showErrorSnack(
                                      "Biometric Authentication is not available on this device",
                                    );
                                    return;
                                  }
                                  context
                                      .read<SettingsCubit>()
                                      .changeBiometricAuthentication(v);
                                },
                              ),
                            ]
                            : [
                              _buildTile(
                                icon: Icons.lock_rounded,
                                title: "Create PIN",
                                onTap: () => _createOrChangePin(authExecutor),
                              ),
                            ],
                  ),

                  SectionBlock(
                    title: "Data Management",
                    children: [
                      _buildTile(
                        icon: Icons.file_upload_outlined,
                        title: "Export Data",
                        subtitle: "Backup your documents",
                      ),
                      _buildTile(
                        icon: Icons.file_download_outlined,
                        title: "Import Data",
                        subtitle: "Restore from backup",
                      ),
                    ],
                  ),
                  SectionBlock(
                    title: "Appearance",
                    children: [
                      ListTile(
                        title: Text("Theme"),
                        leading: Icon(Icons.dark_mode),
                        subtitle: Text("Choose app theme"),
                        trailing: DropdownButton<ThemeMode>(
                          borderRadius: BorderRadius.circular(8),
                          underline: SizedBox.shrink(),
                          icon: Icon(Icons.arrow_drop_down),
                          onChanged: (value) {
                            if (value != null) {
                              context.read<SettingsCubit>().changeThemeMode(
                                value,
                              );
                            }
                          },
                          value: state.themeMode,
                          items: [
                            DropdownMenuItem(
                              value: ThemeMode.light,
                              child: Text("Light"),
                            ),
                            DropdownMenuItem(
                              value: ThemeMode.dark,
                              child: Text("Dark"),
                            ),
                            DropdownMenuItem(
                              value: ThemeMode.system,
                              child: Text("System"),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SectionBlock(
                    title: "About",
                    children: [
                      _buildTile(
                        icon: Icons.info,
                        title: "App Version",
                        subtitle: AppData.appVersion,
                      ),
                      _buildTile(
                        icon: Icons.star_rate_rounded,
                        title: "Rate App",
                        subtitle: "Rate this app",
                      ),
                      _buildTile(
                        icon: Icons.grid_view_rounded,
                        title: "Other projects",
                        subtitle: "More projects from our team!",
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

ListTile _buildTile({
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
