import 'package:my_documents/src/app/features/auth/auth_executor.dart';
import 'package:my_documents/src/app/features/documents/cubit/documents_cubit.dart';
import 'package:my_documents/src/app/features/folders/cubit/folders_cubit.dart';
import 'package:my_documents/src/app/features/settings/cubit/settings_cubit.dart';
import 'package:my_documents/src/app/data/data_sourse.dart';

abstract interface class Dependencies {
  late DataSource dataSource;

  late DocumentsCubit documentsCubit;

  late FoldersCubit foldersCubit;

  late SettingsCubit settingsCubit;

  late AuthenticationExecutor authExecutor;
}
