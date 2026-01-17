import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_documents/src/core/constants.dart';
import 'package:my_documents/src/core/extensions/extensions.dart';
import 'package:my_documents/src/features/auth/auth_executor.dart';
import 'package:my_documents/src/features/documents/widgets/build_tile.dart';
import 'package:my_documents/src/utils/sevices/export_service.dart';
import 'package:my_documents/src/utils/sevices/import_service.dart';
import 'package:my_documents/src/utils/sevices/message_service.dart';
import 'package:my_documents/src/utils/page_transition/app_page_route.dart';
import 'package:my_documents/src/widgets/build_section.dart';

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
  Future<bool?> _verifyOldPin(AuthenticationExecutor authExecutor) async {
    final oldPin = await _showPinSheet(context.l10n.enterCurrentPIN);
    if (oldPin == null) return null;
    return oldPin.isNotEmpty && await authExecutor.verifyPin(oldPin);
  }

  Future<void> _createOrChangePin(
    AuthenticationExecutor authExecutor, {
    bool verifyOld = false,
  }) async {
    if (verifyOld) {
      final isValid = await _verifyOldPin(authExecutor);

      if (isValid == null) return;

      if (!isValid && mounted) {
        MessageService.showErrorSnack(context.l10n.wrongPIN);
        return;
      }
    }

    if (!mounted) return;
    final newPin = await _showPinSheet(context.l10n.enterNewPIN);
    if (newPin == null || newPin.isEmpty) return;
    await authExecutor.createOrChangePin(newPin);
    if (mounted) MessageService.showSnackBar(context.l10n.pinUpdated);
  }

  Future<void> _deletePin(AuthenticationExecutor authExecutor) async {
    final confirm = await MessageService.$confirmAction(
      title: context.l10n.deletePIN,
      message: context.l10n.deletePinConfirm,
    );

    if (confirm == true) {
      bool? verifyOldPin = await _verifyOldPin(authExecutor);
      if (verifyOldPin == null) return;
      verifyOldPin == true
          ? Future.microtask(() async {
              await authExecutor.clearPin();
              if (mounted) MessageService.showSnackBar(context.l10n.pinDeleted);
            })
          : {if (mounted) MessageService.showErrorSnack(context.l10n.wrongPIN)};
    }
  }

  Future<String?> _showPinSheet(String title) async {
    final pin = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final controller = TextEditingController();
        return Padding(
          padding: EdgeInsets.only(
            bottom:
                MediaQuery.of(ctx).viewInsets.bottom +
                MediaQuery.of(ctx).padding.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(ctx).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 20,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        ctx,
                      ).colorScheme.onSurface.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Text(
                    title,
                    style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      ctx,
                    ).textTheme.headlineSmall?.copyWith(letterSpacing: 8),
                    maxLength: 4,
                    decoration: InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(ctx).colorScheme.outline,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(ctx).colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 18,
                      ),
                      hintText: '••••',
                      hintStyle: Theme.of(ctx).textTheme.headlineSmall
                          ?.copyWith(
                            letterSpacing: 8,
                            color: Theme.of(
                              ctx,
                            ).colorScheme.onSurface.withValues(alpha: 0.3),
                          ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            ctx.l10n.cancel,
                            style: TextStyle(
                              color: Theme.of(ctx).colorScheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, controller.text),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(ctx).colorScheme.primary,
                            foregroundColor: Theme.of(
                              ctx,
                            ).colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            ctx.l10n.ok,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
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
    return pin;
  }

  @override
  Widget build(BuildContext context) {
    final authExecutor = context.deps.authExecutor;
    final settingCubit = context.deps.settingsCubit;
    final state = settingCubit.state;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n.settings,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              spacing: 20,
              children: [
                BuildSection(
                  title: context.l10n.security,
                  icon: Icons.security_rounded,
                  children: [
                    ValueListenableBuilder<bool>(
                      valueListenable: authExecutor.hasPasswordNotifier,
                      builder: (context, hasPassword, _) {
                        if (hasPassword) {
                          return Column(
                            children: [
                              BuildTile(
                                icon: Icons.lock_rounded,
                                title: context.l10n.changePIN,
                                subtitle: context.l10n.updatePIN,
                                onTap: () => _createOrChangePin(
                                  authExecutor,
                                  verifyOld: true,
                                ),
                              ),
                              _buildDivider(),
                              BuildTile(
                                icon: Icons.delete_forever_rounded,
                                title: context.l10n.deletePIN,
                                subtitle: context.l10n.removePIN,
                                onTap: () => _deletePin(authExecutor),
                                isDanger: true,
                              ),
                              _buildDivider(),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                child: Row(
                                  spacing: 10,
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: colorScheme.primary.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        Icons.fingerprint_rounded,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        context.l10n.biometricAuthentication,
                                        style: theme.textTheme.bodyLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                    ),
                                    Switch(
                                      value: settingCubit.canUseBiometrics
                                          ? state.useBiometrics
                                          : false,
                                      onChanged: (v) {
                                        if (!settingCubit.canUseBiometrics) {
                                          MessageService.showErrorSnack(
                                            context.l10n.biometricNotAvailable,
                                          );
                                          return;
                                        }
                                        settingCubit
                                            .changeBiometricAuthentication(v);
                                        setState(() {});
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        } else {
                          return BuildTile(
                            icon: Icons.lock_rounded,
                            title: context.l10n.createPIN,
                            subtitle: context.l10n.setUpPIN,
                            onTap: () => _createOrChangePin(authExecutor),
                          );
                        }
                      },
                    ),
                  ],
                ),
                BuildSection(
                  title: context.l10n.dataManagement,
                  icon: Icons.storage_rounded,
                  children: [
                    BuildTile(
                      icon: Icons.file_upload_rounded,
                      title: context.l10n.exportData,
                      subtitle: context.l10n.backupDocuments,
                      onTap: () async {
                        final result = await MessageService.showLoading(
                          timeout: Duration(seconds: 60),
                          message: context.l10n.exportData,
                          fn: () => ExportService.exportData(
                            documents:
                                context.deps.documentsCubit.documentsOrEmpty,
                          ),
                        );
                        result(
                          onSuccess: (_) => (),
                          onError: (err) => MessageService.showErrorSnack(
                            err.getMessage(context),
                          ),
                        );
                      },
                    ),
                    _buildDivider(),
                    BuildTile(
                      icon: Icons.file_download_rounded,
                      title: context.l10n.importData,
                      subtitle: context.l10n.restoreFromBackup,
                      onTap: () async {
                        final result = await ImportService.importAndReplace(
                          dataSource: context.deps.dataSource,
                        );
                        result(
                          onSuccess: (_) =>
                              context.deps.documentsCubit.refresh(),
                          onError: (error) => MessageService.showErrorSnack(
                            error.getMessage(context),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                BuildSection(
                  title: context.l10n.appearance,
                  icon: Icons.palette_rounded,
                  children: [
                    _buildOptionTile<ThemeMode>(
                      context,
                      icon: Icons.dark_mode_rounded,
                      title: context.l10n.theme,
                      subtitle: context.l10n.chooseAppTheme,
                      value: state.themeMode,
                      options: ThemeMode.values,
                      optionBuilder: (tm) => switch (tm) {
                        ThemeMode.light => context.l10n.themeLight,
                        ThemeMode.dark => context.l10n.themeDark,
                        ThemeMode.system => context.l10n.themeSystem,
                      },
                      onChanged: (value) {
                        if (value != null) {
                          settingCubit.changeThemeMode(value);
                          setState(() {});
                        }
                      },
                    ),
                    _buildDivider(),
                    _buildOptionTile<Locale>(
                      context,
                      icon: Icons.language_rounded,
                      title: context.l10n.language,
                      subtitle: context.l10n.chooseAppLanguage,
                      value: state.locale,
                      options: Constants.supportedLocales,
                      optionBuilder: (locale) =>
                          locale.languageCode.toUpperCase(),
                      onChanged: (value) {
                        if (value != null) {
                          settingCubit.changeLocale(value);
                        }
                      },
                    ),
                  ],
                ),
                BuildSection(
                  title: context.l10n.about,
                  icon: Icons.info_rounded,
                  children: [
                    BuildTile(
                      icon: Icons.verified_sharp,
                      title: context.l10n.version,
                      subtitle: Constants.appVersion,
                      onTap: null,
                    ),
                    _buildDivider(),
                    BuildTile(
                      icon: Icons.star_rate_rounded,
                      title: context.l10n.rateApp,
                      subtitle: context.l10n.rateThisApp,
                      onTap: () {},
                    ),
                    _buildDivider(),
                    BuildTile(
                      icon: Icons.grid_view_rounded,
                      title: context.l10n.otherProjects,
                      subtitle: context.l10n.moreProjects,
                      onTap: () {},
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.tonal(
                          onPressed: () async {
                            final size = await context.deps.documentsCubit
                                .getAllDocumentsSize();
                            if (context.mounted) {
                              MessageService.showSnackBar(
                                "${context.l10n.allDocumentsSize}: ${(size / 1024 / 1024).toStringAsFixed(2)} MB",
                              );
                              await context.deps.documentsCubit.debugAllFiles();
                            }
                          },
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            context.l10n.getAllDocumentsSize,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      if (kDebugMode) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: settingCubit.resetFirstLaunch,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(color: colorScheme.error),
                            ),
                            child: Text(
                              "Reset First Launch",
                              style: TextStyle(
                                color: colorScheme.error,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 5),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 56,
      endIndent: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
    );
  }

  Widget _buildOptionTile<T>(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required T value,
    required List<T> options,
    required String Function(T) optionBuilder,
    required ValueChanged<T?> onChanged,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButton<T>(
              value: value,
              onChanged: onChanged,
              items: options.map((option) {
                return DropdownMenuItem<T>(
                  value: option,
                  child: Text(
                    optionBuilder(option),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
              underline: const SizedBox(),
              icon: Icon(
                Icons.arrow_drop_down_rounded,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              borderRadius: BorderRadius.circular(12),
              dropdownColor: colorScheme.surface,
              elevation: 4,
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }
}
