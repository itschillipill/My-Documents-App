import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_documents/src/core/constants.dart';
import 'package:my_documents/src/core/extensions/extensions.dart';
import 'package:my_documents/src/features/auth/auth_executor.dart';
import 'package:my_documents/src/features/folders/widgets/section_block.dart';
import 'package:my_documents/src/features/settings/widgets/action_tile.dart';
import 'package:my_documents/src/utils/sevices/message_service.dart';

import '../../../utils/page_transition/app_page_route.dart';
import '../../../utils/sevices/file_service.dart';

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
    final oldPin = await _showPinSheet(context.l10n.enterCurrentPIN);
    return oldPin != null &&
        oldPin.isNotEmpty &&
        await authExecutor.verifyPin(oldPin);
  }

  Future<void> _createOrChangePin(
    AuthenticationExecutor authExecutor, {
    bool verifyOld = false,
  }) async {
    if (verifyOld && !await _verifyOldPin(authExecutor)) return;
    final newPin = mounted ? await _showPinSheet(context.l10n.enterNewPIN) : "";
    if (newPin?.isNotEmpty ?? false) {
      await authExecutor.createOrChangePin(newPin!);
      if (mounted) {
        MessageService.showSnackBar(context.l10n.pinUpdated);
      }
    }
  }

  Future<void> _deletePin(AuthenticationExecutor authExecutor) async {
    final confirm = await MessageService.$confirmAction(
      title: context.l10n.deletePIN,
      message: context.l10n.deletePinConfirm,
    );

    if (confirm == true && await _verifyOldPin(authExecutor)) {
      debugPrint("deleting pin");
      Future.microtask(() async {
        await authExecutor.clearPin();
        if (mounted) MessageService.showSnackBar(context.l10n.pinDeleted);
      });
    }
  }

  Future<String?> _showPinSheet(String title) async {
    final controller = TextEditingController();
    final pin = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom:
                MediaQuery.of(ctx).viewInsets.bottom +
                MediaQuery.of(ctx).padding.bottom,
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
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: ctx.l10n.enterPIN,
                ),
              ),
              Row(
                spacing: 20,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(ctx.l10n.cancel),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, controller.text),
                      child: Text(ctx.l10n.ok),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
    controller.dispose();
    return pin;
  }

  @override
  Widget build(BuildContext context) {
    final authExecutor = context.deps.authExecutor;
    final settingCubit = context.deps.settingsCubit;
    final state = settingCubit.state;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n.settings,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              spacing: 20,
              children: [
                ValueListenableBuilder<bool>(
                  valueListenable: authExecutor.hasPasswordNotifier,
                  builder:
                      (context, hasPassword, _) => SectionBlock(
                        title: context.l10n.security,
                        children:
                            hasPassword
                                ? [
                                  settingsTile(
                                    icon: Icons.lock_rounded,
                                    title: context.l10n.changePIN,
                                    subtitle: context.l10n.updatePIN,
                                    onTap:
                                        () => _createOrChangePin(
                                          authExecutor,
                                          verifyOld: true,
                                        ),
                                  ),
                                  settingsTile(
                                    icon: Icons.delete_forever,
                                    iconColor: Colors.red,
                                    title: context.l10n.deletePIN,
                                    subtitle: context.l10n.removePIN,
                                    onTap: () => _deletePin(authExecutor),
                                  ),
                                  SwitchListTile.adaptive(
                                    value:
                                        settingCubit.canUseBiometrics
                                            ? state.useBiometrics
                                            : false,
                                    title: Text(
                                      context.l10n.biometricAuthentication,
                                    ),
                                    subtitle: Text(
                                      context.l10n.useBiometricsInfo,
                                    ),
                                    secondary: const Icon(
                                      Icons.fingerprint_rounded,
                                    ),
                                    onChanged: (v) {
                                      if (!settingCubit.canUseBiometrics) {
                                        MessageService.showErrorSnack(
                                          context.l10n.biometricNotAvailable,
                                        );
                                        return;
                                      }
                                        settingCubit
                                          .changeBiometricAuthentication(v);
                                          setState((){});
                                    },
                                  ),
                                ]
                                : [
                                  settingsTile(
                                    icon: Icons.lock_rounded,
                                    title: context.l10n.createPIN,
                                    onTap:
                                        () => _createOrChangePin(authExecutor),
                                  ),
                                ],
                      ),
                ),

                SectionBlock(
                  title: context.l10n.dataManagement,
                  children: [
                    settingsTile(
                      icon: Icons.file_upload_outlined,
                      title: context.l10n.exportData,
                      subtitle: context.l10n.backupDocuments,
                      onTap: () async => await FileService.exportData(context),
                    ),
                    settingsTile(
                      icon: Icons.file_download_outlined,
                      title: context.l10n.importData,
                      subtitle: context.l10n.restoreFromBackup,
                      onTap: () async => await FileService.importData(context),
                    ),
                  ],
                ),
                SectionBlock(
                  title: context.l10n.appearance,
                  children: [
                    ListTile(
                      title: Text(context.l10n.theme),
                      leading: Icon(Icons.dark_mode),
                      subtitle: Text(context.l10n.chooseAppTheme),
                      trailing: DropdownButton<ThemeMode>(
                        borderRadius: BorderRadius.circular(8),
                        underline: SizedBox.shrink(),
                        icon: Icon(Icons.arrow_drop_down),
                        onChanged: (value) {
                          if (value != null) {
                            settingCubit.changeThemeMode(value);
                          }
                        },
                        value: state.themeMode,
                        items:
                            ThemeMode.values
                                .map(
                                  (tm) => DropdownMenuItem(
                                    value: tm,
                                    child: Text(switch (tm) {
                                      ThemeMode.light =>
                                        context.l10n.themeLight,
                                      ThemeMode.dark => context.l10n.themeDark,
                                      ThemeMode.system =>
                                        context.l10n.themeSystem,
                                    }),
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                    ListTile(
                      title: Text(context.l10n.language),
                      leading: Icon(Icons.language),
                      subtitle: Text(context.l10n.chooseAppLanguage),
                      trailing: DropdownButton<Locale>(
                        borderRadius: BorderRadius.circular(8),
                        underline: SizedBox.shrink(),
                        icon: Icon(Icons.arrow_drop_down),
                        onChanged: (value) {
                          if (value != null) {
                            settingCubit.changeLocale(value);
                          }
                        },
                        value: state.locale,
                        items:
                            Constants.supportedLocales
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e.languageCode.toUpperCase()),
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                  ],
                ),
                SectionBlock(
                  title: context.l10n.about,
                  children: [
                    settingsTile(
                      icon: Icons.info,
                      title: context.l10n.appVersion,
                      subtitle: Constants.appVersion,
                    ),
                    settingsTile(
                      icon: Icons.star_rate_rounded,
                      title: context.l10n.rateApp,
                      subtitle: context.l10n.rateThisApp,
                    ),
                    settingsTile(
                      icon: Icons.grid_view_rounded,
                      title: context.l10n.otherProjects,
                      subtitle: context.l10n.moreProjects,
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () async {
                    final size =
                        await context.deps.documentsCubit.getAllDocumentsSize();

                    if (context.mounted) {
                      MessageService.showSnackBar(
                        "${context.l10n.allDocumentsSize}: ${(size / 1024 / 1024).toStringAsFixed(2)} MB",
                      );
                      await context.deps.documentsCubit.debugAllFiles();
                    }
                  },
                  child: Text(context.l10n.getAllDocumentsSize),
                ),
                if (kDebugMode)
                  ElevatedButton(
                    onPressed: settingCubit.resetFirstLaunch,
                    child: Text("reset first launch"),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
