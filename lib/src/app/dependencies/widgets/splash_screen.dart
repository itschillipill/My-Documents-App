import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_documents/src/utils/theme/theme.dart';

class InitializationSplashScreen extends StatelessWidget {
  const InitializationSplashScreen({required this.progress, super.key});

  final ValueListenable<({int progress, String message})> progress;

  @override
  Widget build(BuildContext context) {
    final brightness = View.of(context).platformDispatcher.platformBrightness;
    final theme =
        brightness == Brightness.dark
            ? AppTheme.darkTheme
            : AppTheme.lightTheme;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: SafeArea(
          child: Center(
            child: ValueListenableBuilder<({String message, int progress})>(
              valueListenable: progress,
              builder: (context, value, _) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 600),
                      child: Icon(
                        Icons.donut_large_rounded,
                        key: ValueKey(value.progress),
                        size: 96,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: LinearProgressIndicator(
                          value: value.progress / 100,
                          minHeight: 10,
                          backgroundColor: theme.colorScheme.primary
                              .withValues(alpha: 0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    Text(
                      "${value.progress}%",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        value.message,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
