import 'package:flutter/material.dart';
import 'package:my_documents/src/core/app_context.dart';
import 'package:my_documents/src/core/environment.dart';

abstract class MyObserver {
  void onCreate(String name);
  void onClose(String name);
  void onError(
    String name,
    Object error,
    StackTrace stackTrace, {
    String? message,
  });
  void log(String name, String message);
}

enum LogLevel {
  verbose(0), 
  debug(1),  
  info(2),  
  warning(3),
  error(4),    
  fatal(5);    

  final int value;
  const LogLevel(this.value);

  bool operator >=(LogLevel other) => value >= other.value;
  bool operator <=(LogLevel other) => value <= other.value;
}

class LoggerConfig {
  final int bufferSize;
  final bool printToConsole;
  final LogLevel minLevel;
  final bool captureStackTraces;
  final bool enableAnalytics;
  final bool enableFileLogging;
  final bool enableCrashReporting;

  const LoggerConfig({
    required this.bufferSize,
    required this.printToConsole,
    required this.minLevel,
    required this.captureStackTraces,
    required this.enableAnalytics,
    required this.enableFileLogging,
    required this.enableCrashReporting,
  });

  factory LoggerConfig.fromEnv(Environment env) {
    return switch (env) {
      Environment.dev => _debugConfig,
      Environment.staging => _stagingConfig,
      Environment.prod => _prodConfig,
    };
  }

  static const LoggerConfig _debugConfig = LoggerConfig(
    bufferSize: 5000,           
    printToConsole: true,       
    minLevel: LogLevel.verbose, 
    captureStackTraces: true,   
    enableAnalytics: false,     
    enableFileLogging: true,   
    enableCrashReporting: false,
  );

  static const LoggerConfig _stagingConfig = LoggerConfig(
    bufferSize: 2000,
    printToConsole: true,
    minLevel: LogLevel.debug,  
    captureStackTraces: true,   
    enableAnalytics: true,     
    enableFileLogging: true,
    enableCrashReporting: true, 
  );

  static const LoggerConfig _prodConfig = LoggerConfig(
    bufferSize: 1000,
    printToConsole: false, 
    minLevel: LogLevel.warning, 
    captureStackTraces: false,  
    enableAnalytics: true,     
    enableFileLogging: true,    
    enableCrashReporting: true, 
  );
}
abstract class LogHandler {
  void handle(LogEntry entry);
}

class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final String category;
  final String message;
  final Object? error;
  final StackTrace? stackTrace;
  final Map<String, dynamic>? extra;

  LogEntry({
    required this.level,
    required this.category,
    required this.message,
    this.error,
    this.stackTrace,
    this.extra,
  }) : timestamp = DateTime.now();

   @override
  String toString() {
    final time = timestamp.toIso8601String();
    final levelStr = level.name.toUpperCase();
    final extraStr = extra != null && extra!.isNotEmpty 
        ? '\n${extra!.entries.map((e) => '${e.key}=${e.value}').join(',\n')}'
        : '';
    
    if (error != null) {
      final stack = stackTrace?.toString() ?? '';
      return '[$time][$levelStr] |$category| $message$extraStr -> $error\n$stack';
    }
    return '[$time][$levelStr] |$category| $message$extraStr';
  }
  }

class SessionLogger implements MyObserver {
  static SessionLogger? _instance;
  final LoggerConfig _config;
  final List<LogEntry> _logs = [];
  final List<LogHandler> _handlers = [];

  SessionLogger._internal(this._config);

  factory SessionLogger({
    LoggerConfig? config,
    List<LogHandler>? handlers,
  }) {
    _instance ??= SessionLogger._internal(
      config ?? LoggerConfig.fromEnv(AppContext.instance.config.environment),
    );
    
    if (handlers != null) {
      _instance!._handlers.addAll(handlers);
    }
    
    return _instance!;
  }

  static SessionLogger get instance {
    return _instance ??= SessionLogger();
  }

  void _log(LogEntry entry) {
    if (entry.level.index < _config.minLevel.index) {
      return;
    }

    if (_logs.length >= _config.bufferSize) {
      _logs.removeAt(0);
    }
    _logs.add(entry);

    if (_config.printToConsole) {
      debugPrint(entry.toString());
    }

    for (final handler in _handlers) {
      try {
        handler.handle(entry);
      } catch (e) {
        debugPrint('Error in log handler: $e');
      }
    }
  }

  @override
  void onCreate(String name) {
    _log(LogEntry(
      level: LogLevel.info,
      category: 'LIFECYCLE',
      message: 'Created',
      extra: {'name': name},
    ));
  }

  @override
  void onClose(String name) {
    _log(LogEntry(
      level: LogLevel.info,
      category: 'LIFECYCLE',
      message: 'Closed',
      extra: {'name': name},
    ));
  }

  @override
  void onError(
    String name,
    Object error,
    StackTrace stackTrace, {
    String? message,
  }) {
    _log(LogEntry(
      level: LogLevel.error,
      category: name,
      message: message ?? 'Error occurred',
      error: error,
      stackTrace: _config.captureStackTraces ? stackTrace : null,
    ));
  }

  @override
  void log(String name, String message) {
    _log(LogEntry(
      level: LogLevel.debug,
      category: name,
      message: message,
    ));
  }

  void debug(String category, String message, {Map<String, dynamic>? extra}) {
    _log(LogEntry(
      level: LogLevel.debug,
      category: category,
      message: message,
      extra: extra,
    ));
  }

  void info(String category, String message, {Map<String, dynamic>? extra}) {
    _log(LogEntry(
      level: LogLevel.info,
      category: category,
      message: message,
      extra: extra,
    ));
  }

  void warning(String category, String message, {Object? error}) {
    _log(LogEntry(
      level: LogLevel.warning,
      category: category,
      message: message,
      error: error,
    ));
  }

  void error(String category, String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogEntry(
      level: LogLevel.error,
      category: category,
      message: message,
      error: error,
      stackTrace: stackTrace,
    ));
  }

  // Для BLoC
  void onTransition<T>(String name, T oldState, T newState) {
    _log(LogEntry(
      level: LogLevel.debug,
      category: name,
      message: 'State changed',
      extra: {
        'oldState': oldState.toString(),
        'newState': newState.toString(),
      },
    ));
  }

  // Управление логами
  List<LogEntry> getLogs() => List.unmodifiable(_logs);
  
  List<LogEntry> getLogsByLevel(LogLevel level) =>
      _logs.where((log) => log.level == level).toList();
  
  List<LogEntry> getLogsByCategory(String category) =>
      _logs.where((log) => log.category == category).toList();

  void clearLogs() => _logs.clear();

  void addHandler(LogHandler handler) => _handlers.add(handler);
  void removeHandler(LogHandler handler) => _handlers.remove(handler);
}


class LoggingNavigatorObserver extends NavigatorObserver {
  final SessionLogger logger;

  LoggingNavigatorObserver({SessionLogger? logger})
      : logger = logger ?? SessionLogger.instance;

  String _routeName(Route<dynamic>? route) {
    return route?.settings.name ?? route.runtimeType.toString();
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    final name = _routeName(route);
    logger.info('NAVIGATION', 'Screen pushed',
      extra: {
        'screen': name,
        'previous': _routeName(previousRoute),
        'action': 'push',
      },
    );
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    final name = _routeName(route);
    logger.info('NAVIGATION', 'Screen popped',
      extra: {
        'screen': name,
        'previous': _routeName(previousRoute),
        'action': 'pop',
      },
    );
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    logger.info('NAVIGATION', 'Screen replaced',
      extra: {
        'oldScreen': _routeName(oldRoute),
        'newScreen': _routeName(newRoute),
        'action': 'replace',
      },
    );
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    logger.info('NAVIGATION', 'Screen removed',
      extra: {
        'screen': _routeName(route),
        'action': 'remove',
      },
    );
  }
}