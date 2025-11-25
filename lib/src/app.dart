import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_documents/src/core/constants.dart';
import 'package:my_documents/src/features/auth/widgets/auth_scope.dart';
import 'package:my_documents/src/features/auth/widgets/auth_screen.dart';
import 'package:my_documents/src/features/settings/cubit/settings_cubit.dart';
import 'package:my_documents/src/pages/app_gate.dart';
import 'package:my_documents/src/utils/sevices/message_service.dart';
import 'dependencies/widgets/dependencies_scope.dart';
import 'package:my_documents/src/utils/theme/theme.dart';

import 'widgets/windows_scope.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final deps = DependenciesScope.of(context);
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => deps.documentsCubit),
        BlocProvider(create: (_) => deps.foldersCubit),
        BlocProvider(create: (_) => deps.settingsCubit),
      ],
      child: BlocSelector<SettingsCubit, SettingsState, ThemeMode>(
        selector: (state) => state.themeMode,
        builder: (context, themeMode) {
          return MaterialApp(
            scaffoldMessengerKey: MessageService.messengerKey,
            navigatorKey: MessageService.navigatorKey,
            title: Constants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            home: AuthScope(
              authExecutor: deps.authExecutor,
              authScreenBuilder:
                  (executor) => VerefyPinScreen(
                    useBiometrics:
                        deps.settingsCubit.state.useBiometrics &&
                        deps.settingsCubit.canUseBiometrics,
                    onAuthByPIN: executor.authenticateByPIN,
                    onAuthByBiometrics: executor.authenticateByBiometrics,
                  ),
              child: const AppGate(),
            ),
            builder:
                (context, child) => MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: TextScaler.linear(1.0)),
                  child: WindowScope(
                    title: Constants.appName,
                    child: child ?? const SizedBox.shrink(),
                  ),
                ),
          );
        },
      ),
    );
  }
}
