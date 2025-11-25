import 'dart:async';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_documents/src/app/features/auth/auth_executor.dart';
import 'package:my_documents/src/app/features/documents/cubit/documents_cubit.dart';
import 'package:my_documents/src/app/features/folders/cubit/folders_cubit.dart';
import 'package:my_documents/src/app/features/settings/cubit/settings_cubit.dart';
import 'package:my_documents/src/app/data/data_sourse.dart';
import 'package:my_documents/src/app/data/local_data_sourse.dart';
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;

import 'platform/initialization_vm.dart'
    // ignore: uri_does_not_exist
    if (dart.library.html) 'platform/initialization_js.dart';
import 'package:meta/meta.dart';

import 'dependencies.dart';

typedef _InitializationStep =
    FutureOr<void> Function(MutableDependencies dependencies);

class MutableDependencies implements Dependencies {
  @override
  late DataSource dataSource;
  @override
  late DocumentsCubit documentsCubit;
  @override
  late FoldersCubit foldersCubit;
  @override
  late SettingsCubit settingsCubit;
  @override
  late AuthenticationExecutor authExecutor;
}

@internal
mixin InitializeDependencies {
  @protected
  Future<Dependencies> $initializeDependencies({
    void Function(int progress, String message)? onProgress,
  }) async {
    final steps = _initializationSteps;
    final dependencies = MutableDependencies();
    final totalSteps = steps.length;
    for (var currentStep = 0; currentStep < totalSteps; currentStep++) {
      final step = steps[currentStep];
      final percent = (currentStep * 100 ~/ totalSteps).clamp(0, 100);
      onProgress?.call(percent, step.$1);
      debugPrint(
        'Initialization | $currentStep/$totalSteps ($percent%) | "${step.$1}"',
      );
      await step.$2(dependencies);
    }
    return dependencies;
  }

  List<(String, _InitializationStep)> get _initializationSteps =>
      <(String, _InitializationStep)>[
        // 1. Инициализация платформы
        ('Platform pre-initialization', (_) => $platformInitialization()),
        // 2. Инициализация базы данных
        (
          "database initialization",
          (deps) async {
            try {
              final localDataSource = LocalDataSource();
              await localDataSource.init();
              deps.dataSource = localDataSource;
            } catch (e, _) {
              debugPrint("Database init failed: $e");
              rethrow;
            }
          },
        ),
        // 3. Инициализация app dependencies
        (
          "Initialization",
          (deps) async {
            final prefs = await SharedPreferences.getInstance();
            final passwordStorage = FlutterSecureStorage();
            deps.authExecutor = AuthenticationExecutor(passwordStorage);
            deps.settingsCubit = SettingsCubit(
              prefs: prefs,
              canUseBiometrics: await deps.authExecutor.canCheckBiometrics,
            );
            deps.documentsCubit = DocumentsCubit(dataSource: deps.dataSource);
            deps.foldersCubit = FoldersCubit(dataSource: deps.dataSource);

            await Future.delayed(const Duration(milliseconds: 500));
          },
        ),
      ];
}
