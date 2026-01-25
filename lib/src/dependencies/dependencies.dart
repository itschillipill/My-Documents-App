import 'package:my_documents/src/features/auth/auth_executor.dart';
import 'package:my_documents/src/features/documents/cubit/documents_cubit.dart';
import 'package:my_documents/src/features/folders/cubit/folders_cubit.dart';
import 'package:my_documents/src/features/settings/cubit/settings_cubit.dart';

import '../database/database.dart';

class Dependencies {
  late final DataSource dataSource;

  late final DocumentsCubit documentsCubit;

  late final FoldersCubit foldersCubit;

  late final SettingsCubit settingsCubit;

  late final AuthenticationExecutor authExecutor;
}
