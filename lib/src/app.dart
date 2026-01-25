import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_documents/src/core/constants.dart';
import 'package:my_documents/src/core/extensions/extensions.dart';
import 'package:my_documents/src/features/auth/widgets/auth_scope.dart';
import 'package:my_documents/src/features/settings/cubit/settings_cubit.dart';
import 'package:my_documents/src/pages/app_gate.dart';
import 'package:my_documents/src/utils/sevices/message_service.dart';
import 'package:my_documents/src/utils/theme/theme.dart';
import 'package:my_documents/l10n/app_localizations.dart';

import 'widgets/windows_scope.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      bloc: context.deps.settingsCubit,
      builder: (context, state) => MaterialApp(
        scaffoldMessengerKey: MessageService.messengerKey,
        navigatorKey: MessageService.navigatorKey,
        title: Constants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: state.themeMode,
        home: const AppGate(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.noScaling),
          child: WindowScope(
            title: context.l10n.appTitle,
            child: AuthScope(child: child ?? const SizedBox.shrink()),
          ),
        ),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        locale: state.locale,
        supportedLocales: Constants.supportedLocales,
      ),
    );
  }
}
