import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_documents/src/core/constants.dart';
import 'dart:math' as math;
import 'package:my_documents/src/utils/theme/theme.dart';

class InitializationSplashScreen extends StatelessWidget {
  const InitializationSplashScreen({required this.progress, super.key});

  final ValueListenable<({int progress, String message})> progress;

  @override
  Widget build(BuildContext context) {
    final brightness = View.of(context).platformDispatcher.platformBrightness;
    final theme = brightness == Brightness.dark
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
                    CircularProgressWithIcon(
                      progress: value.progress / 100,
                      strokeWidth: 6,
                      backgroundColor: theme.colorScheme.primary.withValues(
                        alpha: 0.2,
                      ),
                      progressColor: theme.colorScheme.secondary,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage(Constants.appLogoAsset),
                      ),
                    ),
                    const SizedBox(height: 32),
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
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
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

class CircularProgressWithIcon extends StatelessWidget {
  const CircularProgressWithIcon({
    super.key,
    required this.progress,
    this.strokeWidth = 4,
    this.backgroundColor,
    this.progressColor,
    required this.child,
    this.startAngle = -90,
  });

  final double progress;
  final double strokeWidth;
  final Color? backgroundColor;
  final Color? progressColor;
  final Widget child;
  final double startAngle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressPaintColor = progressColor ?? theme.colorScheme.primary;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: EdgeInsets.all(strokeWidth / 2),
                child: SizedBox(
                  width: _getChildSize(child) + strokeWidth,
                  height: _getChildSize(child) + strokeWidth,
                  child: CustomPaint(
                    painter: _CircularProgressPainter(
                      backgroundColor:
                          backgroundColor ??
                          theme.colorScheme.primary.withValues(alpha: 0.2),
                      progress: progress,
                      color: progressPaintColor,
                      strokeWidth: strokeWidth,
                      startAngle: startAngle,
                    ),
                  ),
                ),
              ),
              child, // центрируем child
            ],
          ),
        );
      },
    );
  }

  // Вспомогательная функция, чтобы задать размер круга под child
  double _getChildSize(Widget child) {
    if (child is SizedBox && child.width != null) {
      return child.width!;
    } else if (child is CircleAvatar) {
      return child.radius! * 2;
    } else {
      return 50; // дефолтный размер, если не знаем
    }
  }
}

class _CircularProgressPainter extends CustomPainter {
  _CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
    required this.startAngle,
  });

  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;
  final double startAngle;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - strokeWidth / 2;

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,
      2 * math.pi,
      false,
      backgroundPaint,
    );

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle * math.pi / 180,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        color != oldDelegate.color ||
        backgroundColor != oldDelegate.backgroundColor ||
        strokeWidth != oldDelegate.strokeWidth;
  }
}
