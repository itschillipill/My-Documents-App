part of 'package:my_documents/main.dart';

void _initializationErrorHandler(Object error, StackTrace stackTrace) {
  debugPrint("Initialization error: $error");
  debugPrintStack(stackTrace: stackTrace);
  runApp(
    MaterialApp(
      title: AppData.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: InitializationErrorScreen(
        error: error,
        stackTrace: stackTrace,
        onRetry: () {
          main();
        },
      ),
      builder:
          (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0),),
            child: WindowScope(
              title: AppData.appName,
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
      backgroundColor: Colors.red[900],
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
