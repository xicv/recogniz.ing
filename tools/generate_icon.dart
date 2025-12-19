import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

/// Tool to generate app icon programmatically
Future<void> main() async {
  // Initialize Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Create icon
  final icon = await createAppIcon();

  // Save as PNG
  final file = File('assets/icons/app_icon.png');
  await file.parent.create(recursive: true);
  final byteData = await icon.toByteData(format: ui.ImageByteFormat.png);
  await file.writeAsBytes(byteData!.buffer.asUint8List());

  print('Icon generated at ${file.path}');
}

Future<ui.Image> createAppIcon() async {
  // Create a picture recorder
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  const size = 1024.0;
  const center = Offset(512, 512);

  // Background
  final bgPaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.fill;
  canvas.drawRect(const Rect.fromLTWH(0, 0, size, size), bgPaint);

  // Create gradient for sound waves
  final gradient = LinearGradient(
    colors: [
      const Color(0xFF2196F3), // Blue
      const Color(0xFF00BCD4), // Cyan
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Draw sound waves (left side)
  final wavePaint = Paint()
    ..shader = gradient.createShader(
      const Rect.fromLTWH(100, 200, 400, 624),
    )
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 20;

  // Wave 1
  final path1 = Path();
  path1.moveTo(150, 400);
  path1.quadraticBezierTo(250, 300, 350, 400);
  path1.quadraticBezierTo(450, 500, 450, 512);
  canvas.drawPath(path1, wavePaint);

  // Wave 2
  final path2 = Path();
  path2.moveTo(150, 512);
  path2.quadraticBezierTo(250, 600, 350, 512);
  path2.quadraticBezierTo(450, 400, 450, 624);
  canvas.drawPath(path2, wavePaint);

  // Draw text lines (right side)
  final textPaint = Paint()
    ..color = const Color(0xFF424242)
    ..style = PaintingStyle.fill;

  const lineHeight = 8.0;
  const lineSpacing = 20.0;
  const startY = 350.0;

  // Draw 4 horizontal lines representing text
  for (int i = 0; i < 4; i++) {
    final y = startY + (i * lineSpacing);
    canvas.drawRect(
      Rect.fromLTWH(550, y, 300, lineHeight),
      textPaint,
    );
  }

  // Draw subtle transformation arrow
  final arrowPaint = Paint()
    ..color = const Color(0xFF757575)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4
    ..strokeCap = StrokeCap.round;

  canvas.drawLine(
    const Offset(450, 512),
    const Offset(520, 512),
    arrowPaint,
  );

  // Draw arrow head
  final arrowPath = Path();
  arrowPath.moveTo(520, 512);
  arrowPath.lineTo(510, 505);
  arrowPath.moveTo(520, 512);
  arrowPath.lineTo(510, 519);
  canvas.drawPath(arrowPath, arrowPaint);

  // End recording
  final picture = recorder.endRecording();

  // Convert to image
  final image = await picture.toImage(1024, 1024);
  picture.dispose();

  return image;
}