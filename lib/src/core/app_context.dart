import 'app_config.dart';
import 'app_metadata.dart';
import 'environment.dart';

class AppContext {
  AppContext._internal();

  static final AppContext _instance = AppContext._internal();
  static AppContext get instance => _instance;

  late final Environment environment;
  late final AppConfig config;
  late final AppMetadata metadata;

  bool _initialized = false;

  void init({
    required Environment environment,
    required AppMetadata metadata,
  }) {
    if (_initialized) return;

    this.environment = environment;
    config = AppConfig.forEnvironment(environment);
    this.metadata = metadata;

    _initialized = true;
  }
}
