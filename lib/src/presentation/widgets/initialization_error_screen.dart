part of 'package:my_documents/main.dart';

void $initializationErrorHandler(Object error, StackTrace stackTrace) async {
  SessionLogger.instance.onError("Initialization", error, stackTrace);
  ThemeMode themeMode =
      ThemeMode.values[(await SharedPreferences.getInstance()).getInt(
            Constants.themeModeKey,
          ) ??
          0];
  runApp(
    MaterialApp(
      title: Constants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: InitializationErrorScreen(
        error: error,
        stackTrace: stackTrace,
        onRetry: main,
      ),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(1.0)),
        child: WindowScope(
          title: Constants.appName,
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    ),
  );
}

class InitializationErrorScreen extends StatelessWidget {
  final Object error;
  final StackTrace stackTrace;
  final VoidCallback onRetry;

  const InitializationErrorScreen({
    super.key,
    required this.error,
    required this.stackTrace,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error, size: 80, color: Colors.white),
              const SizedBox(height: 16),
              const Text(
                "Произошла ошибка при запуске",
                style: TextStyle(color: Colors.white, fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              SelectableText(
                error.toString(),
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text("Попробовать снова"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
