import 'package:flutter/foundation.dart' show kReleaseMode;

enum Environment {
  dev._('DEV'),
  staging._('STAGING'),
  prod._('PROD');
  
  final String value;
  const Environment._(this.value);
  
  static Environment from(String? value) => switch (value) {
    'DEV' => Environment.dev,
    'STAGING' => Environment.staging,
    'PROD' => Environment.prod,
    _ => kReleaseMode ? Environment.prod : Environment.dev,
  };
}