import 'environment.dart';

class AppConfig {
  const AppConfig({
    required this.environment,
    this.showLogs = true,
  });

  final bool showLogs;
  final Environment environment;

  bool get isDev => environment == Environment.dev;
  bool get isStaging => environment == Environment.staging;
  bool get isProd => environment == Environment.prod;
  
  factory AppConfig.forEnvironment(Environment env) {
    return switch (env) {
      Environment.dev => AppConfig(
        environment: env,
      ),
      Environment.staging => AppConfig(
        environment: env,
      ),
      Environment.prod => AppConfig(
        environment: env,
        showLogs: false,
      ),
    };
  }
}