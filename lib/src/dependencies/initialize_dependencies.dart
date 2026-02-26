import 'dart:async';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_documents/src/core/app_context.dart';
import 'package:my_documents/src/core/app_metadata.dart';
import 'package:my_documents/src/database/src/local_data_source.dart';
import 'package:my_documents/src/features/auth/auth_executor.dart';
import 'package:my_documents/src/features/documents/cubit/documents_cubit.dart';
import 'package:my_documents/src/features/folders/cubit/folders_cubit.dart';
import 'package:my_documents/src/features/settings/cubit/settings_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;

import '../core/environment.dart';
import '../sevices/notification/notification_service_singleton.dart';
import 'platform/initialization_vm.dart'
    // ignore: uri_does_not_exist
    if (dart.library.html) 'platform/initialization_js.dart';
import 'package:meta/meta.dart';

import 'dependencies.dart';

typedef _InitializationStep =
    FutureOr<void> Function(Dependencies dependencies);
@internal
mixin InitializeDependencies {
  @protected
  Future<Dependencies> $initializeDependencies({
    void Function(int progress, String message)? onProgress,
  }) async {
    final steps = _initializationSteps;
    final dependencies = Dependencies();
    final totalSteps = steps.length;
    for (var currentStep = 0; currentStep < totalSteps; currentStep++) {
      final step = steps[currentStep];
      final percent = (currentStep * 100 ~/ totalSteps).clamp(0, 100);
      onProgress?.call(percent, step.title);
      debugPrint(
        'Initialization | $currentStep/$totalSteps ($percent%) | "${step.title}"',
      );
      await step.call(dependencies);
    }
    return dependencies;
  }

  List<({String title, _InitializationStep call})> get _initializationSteps =>
      <({String title, _InitializationStep call})>[
        (title:'Platform pre-initialization', call: (_) => $platformInitialization()),
        (title:"AppContext initialization", call: (_){
          AppContext.instance.init(
            environment: Environment.from(
            "STAGING" 
             // String.fromEnvironment("ENV")
              ), 
            metadata: AppMetadata.fromPlatform(
              version: "1.0.0", 
              buildNumber: DateTime.now().millisecondsSinceEpoch.toString(),));
        }),
        (
          title: "Database initialization",
          call: (deps) async {
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
        (
          title: "Password storage initialization",
          call: (deps) async {
            final passwordStorage = FlutterSecureStorage();
            deps.authExecutor = AuthenticationExecutor(passwordStorage);
          },
        ),
        (
          title: "Local Storage initialization",
          call: (deps) async {
            final prefs = await SharedPreferences.getInstance();
            deps.settingsCubit = SettingsCubit(
              prefs: prefs,
              canUseBiometrics: await deps.authExecutor.canCheckBiometrics,
            );
          },
        ),
        (
          title: "Notification initialization",
          call: (_) async {
            await NotificationServiceSingleton.instance.init();
          },
        ),
        (
          title: "Documents initialization",
          call: (deps) async {
            deps.documentsCubit = DocumentsCubit(dataSource: deps.dataSource);
          },
        ),
        (
          title: "Folders initialization",
          call: (deps) async {
            deps.foldersCubit = FoldersCubit(dataSource: deps.dataSource);
          },
        ),
        (
          title: "Ready to use",
          call: (deps) async {
            await Future.delayed(const Duration(milliseconds: 500));
          },
        ),
      ];
}
