import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Tool to generate the new "R" app icon programmatically
/// Usage: dart run tools/generate_icon.dart
Future<void> main() async {
  // Initialize Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Create icons
  final icon = await createAppIcon();
  final iconAdaptive = await createAdaptiveIcon();
  final iconMac = await createMacIcon();

  // Save main icon
  final mainFile = File('assets/icons/app_icon.png');
  await mainFile.parent.create(recursive: true);
  final byteData = await icon.toByteData(format: ui.ImageByteFormat.png);
  await mainFile.writeAsBytes(byteData!.buffer.asUint8List());
  stdout.writeln('Main icon generated at ${mainFile.path}');

  // Save adaptive icon
  final adaptiveFile = File('assets/icons/app_icon_adaptive.png');
  final adaptiveByteData =
      await iconAdaptive.toByteData(format: ui.ImageByteFormat.png);
  await adaptiveFile.writeAsBytes(adaptiveByteData!.buffer.asUint8List());
  stdout.writeln('Adaptive icon generated at ${adaptiveFile.path}');

  // Save Mac icon
  final macFile = File('assets/icons/app_icon_mac.png');
  final macByteData = await iconMac.toByteData(format: ui.ImageByteFormat.png);
  await macFile.writeAsBytes(macByteData!.buffer.asUint8List());
  stdout.writeln('Mac icon generated at ${macFile.path}');

  // Generate additional sizes
  await generateSizeVariant(
      icon, 'assets/icons/generated/app_icon_1024.png', 1024);
  await generateSizeVariant(
      icon, 'assets/icons/generated/app_icon_512.png', 512);
  await generateSizeVariant(
      icon, 'assets/icons/generated/app_icon_256.png', 256);
  await generateSizeVariant(
      icon, 'assets/icons/generated/app_icon_128.png', 128);
  await generateSizeVariant(icon, 'assets/icons/generated/app_icon_64.png', 64);
  await generateSizeVariant(icon, 'assets/icons/generated/app_icon_32.png', 32);
  await generateSizeVariant(icon, 'assets/icons/generated/app_icon_16.png', 16);

  stdout.writeln('\nAll icons generated successfully!');
  stdout.writeln(
      'Run "flutter pub run flutter_launcher_icons" to update platform icons.');
}

Future<void> generateSizeVariant(ui.Image source, String path, int size) async {
  final file = File(path);
  await file.parent.create(recursive: true);

  // Create resized version
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final src =
      Rect.fromLTWH(0, 0, source.width.toDouble(), source.height.toDouble());
  final dst = Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble());
  final paint = Paint()..isAntiAlias = true;

  // Draw the image scaled
  canvas.drawImageRect(source, src, dst, paint);

  final picture = recorder.endRecording();
  final resizedImage = await picture.toImage(size, size);
  final byteData =
      await resizedImage.toByteData(format: ui.ImageByteFormat.png);
  await file.writeAsBytes(byteData!.buffer.asUint8List());

  stdout.writeln('  Generated: $path (${size}x$size)');
}

/// Main app icon with gradient background and white "R"
Future<ui.Image> createAppIcon() async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  const size = 1024.0;
  const cornerRadius = 220.0;

  // Create gradient (blue to teal to emerald)
  final gradient = ui.Gradient.linear(
    const Offset(0, 0),
    const Offset(size, size),
    [
      const Color(0xFF1E40AF), // Deep blue
      const Color(0xFF0891B2), // Cyan/teal
      const Color(0xFF10B981), // Emerald
    ],
    [0.0, 0.5, 1.0],
  );

  // Draw background with rounded corners
  final bgPaint = Paint()
    ..shader = gradient
    ..style = PaintingStyle.fill;
  final bgRRect = RRect.fromRectAndRadius(
    const Rect.fromLTWH(32, 32, 960, 960),
    const Radius.circular(cornerRadius),
  );
  canvas.drawRRect(bgRRect, bgPaint);

  // Draw "R" letter
  drawRLetter(canvas, size);

  // Draw red recording dot
  drawRecordingDot(canvas, size, hasBackground: true);

  final picture = recorder.endRecording();
  final image = await picture.toImage(1024, 1024);
  picture.dispose();

  return image;
}

/// Adaptive icon (transparent background, gradient "R")
Future<ui.Image> createAdaptiveIcon() async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  const size = 1024.0;

  // Create gradient for the "R"
  final gradient = ui.Gradient.linear(
    const Offset(0, 0),
    const Offset(size, size),
    [
      const Color(0xFF1E40AF), // Deep blue
      const Color(0xFF0891B2), // Cyan/teal
      const Color(0xFF10B981), // Emerald
    ],
    [0.0, 0.5, 1.0],
  );

  // Draw "R" letter with gradient
  drawRLetter(canvas, size, letterColor: const Color(0xFFFFFFFF));

  // Draw red recording dot
  drawRecordingDot(canvas, size, hasBackground: false);

  final picture = recorder.endRecording();
  final image = await picture.toImage(1024, 1024);
  picture.dispose();

  return image;
}

/// Mac icon (slightly different - typically without extra effects)
Future<ui.Image> createMacIcon() async {
  // Mac uses the same as main icon
  return createAppIcon();
}

void drawRLetter(Canvas canvas, double size, {Color? letterColor}) {
  const centerX = 512.0;
  const centerY = 512.0;
  const scale = 1.0;

  // "R" letter paint
  final paint = Paint()
    ..color = letterColor ?? const Color(0xFFFFFFFF)
    ..style = PaintingStyle.fill
    ..isAntiAlias = true;

  // Draw the "R" using a custom path
  final path = Path();
  final s = scale;

  // Vertical stem (left side of R)
  path.moveTo((centerX - 180) * s, (centerY - 260) * s);
  path.lineTo((centerX - 180) * s, (centerY + 260) * s);
  path.lineTo((centerX - 90) * s, (centerY + 260) * s);
  path.lineTo((centerX - 90) * s, (centerY + 30) * s);
  path.lineTo((centerX + 40) * s, (centerY + 30) * s);

  // Diagonal leg going down to right
  path.lineTo((centerX + 280) * s, (centerY + 260) * s);
  path.lineTo((centerX + 180) * s, (centerY + 260) * s);
  path.lineTo((centerX + 40) * s, (centerY + 30) * s);

  // Top of R (going right)
  path.lineTo((centerX + 40) * s, (centerY + 30) * s);
  path.arcTo(
    Rect.fromCenter(
        center: (centerX + 130) * s,
        centerY: (centerY - 115) * s,
        width: 180 * s,
        height: 230 * s),
    3.14159,
    -3.14159,
    false,
  );

  // Back to the stem (inner part of R)
  path.lineTo((centerX - 90) * s, (centerY - 230) * s);
  path.lineTo((centerX - 90) * s, (centerY - 260) * s);
  path.lineTo((centerX - 180) * s, (centerY - 260) * s);

  // Draw the outer R
  canvas.drawPath(path, paint);

  // Draw the inner cutout (the hole in the R)
  final innerPath = Path();
  innerPath.moveTo((centerX - 90) * s, (centerY + 30) * s);
  innerPath.lineTo((centerX + 40) * s, (centerY + 30) * s);
  innerPath.lineTo((centerX + 40) * s, (centerY - 50) * s);
  innerPath.arcTo(
    Rect.fromCenter(
        center: (centerX + 40) * s,
        centerY: (centerY - 80) * s,
        width: 120 * s,
        height: 120 * s),
    1.5708,
    3.14159,
    false,
  );
  innerPath.lineTo((centerX - 90) * s, (centerY - 160) * s);
  innerPath.lineTo((centerX - 90) * s, (centerY + 30) * s);

  // Create a "cutout" effect by using the background color
  // For adaptive icon, we use a blending approach
  if (letterColor == null) {
    // For icons with background, cut out using composite operation
    final cutoutPaint = Paint()
      ..color =
          const Color(0xFF1E40AF) // Use gradient start color as approximation
      ..blendMode = BlendMode.srcOut;
    canvas.drawPath(innerPath, cutoutPaint);
  } else {
    // For adaptive icon, draw over with transparency
    // Since we can't use srcOut without a layer, we'll draw the inner part
    // as part of the main path with proper fill
  }

  // Alternative: Draw the complete R shape properly
  // Let's redraw with a cleaner approach
  final rPath = Path();
  final centerX2 = 512.0;
  final centerY2 = 512.0;

  // Start at top-left of R
  rPath.moveTo((centerX2 - 180) * s, (centerY2 - 260) * s);
  rPath.lineTo((centerX2 - 180) * s, (centerY2 + 260) * s); // Down to bottom
  rPath.lineTo((centerX2 - 90) * s, (centerY2 + 260) * s); // Right a bit
  rPath.lineTo((centerX2 - 90) * s, (centerY2 + 30) * s); // Up to middle
  rPath.lineTo(
      (centerX2 + 40) * s, (centerY2 + 30) * s); // Right to start of diagonal

  // Draw the bowl of R
  rPath.lineTo(
      (centerX2 + 180) * s, (centerY2 + 260) * s); // Diagonal down-right
  rPath.lineTo((centerX2 + 280) * s, (centerY2 + 260) * s); // Right a bit more
  rPath.lineTo((centerX2 + 130) * s, (centerY2 + 10) * s); // Diagonal up-left

  // Top curve of R (counterclockwise for the inner cutout effect)
  final ovalRect = Rect.fromCenter(
    center: Offset((centerX2 + 90) * s, (centerY2 - 115) * s),
    width: 200 * s,
    height: 230 * s,
  );
  rPath.arcTo(ovalRect, 0, -3.14159, false); // Top arc

  rPath.lineTo((centerX2 - 90) * s, (centerY2 - 230) * s); // Left to stem
  rPath.lineTo((centerX2 - 90) * s, (centerY2 - 260) * s); // Up slightly
  rPath.lineTo((centerX2 - 180) * s, (centerY2 - 260) * s); // Left to start
  rPath.close();

  canvas.drawPath(rPath, paint);

  // Inner cutout using a separate path
  final cutoutPath = Path();
  cutoutPath.moveTo((centerX2 - 90) * s, (centerY2 + 30) * s);
  cutoutPath.lineTo((centerX2 + 40) * s, (centerY2 + 30) * s);

  final innerOval = Rect.fromCenter(
    center: Offset((centerX2 + 40) * s, (centerY2 - 80) * s),
    width: 100 * s,
    height: 130 * s,
  );
  cutoutPath.arcTo(innerOval, 1.5708, 3.14159, false);

  cutoutPath.lineTo((centerX2 - 90) * s, (centerY2 - 160) * s);
  cutoutPath.lineTo((centerX2 - 90) * s, (centerY2 + 30) * s);
  cutoutPath.close();

  // For cutout, we need to use the background gradient
  final cutoutPaint = Paint()..blendMode = BlendMode.srcOut;
  canvas.drawPath(cutoutPath, cutoutPaint);
}

void drawRecordingDot(Canvas canvas, double size,
    {required bool hasBackground}) {
  // Red recording dot at bottom right of the R
  final dotPaint = Paint()
    ..color = const Color(0xFFEF4444) // Red
    ..style = PaintingStyle.fill
    ..isAntiAlias = true;

  final dotX = 680.0;
  final dotY = 680.0;
  final dotRadius = 40.0;

  // Draw shadow for the dot
  final shadowPaint = Paint()
    ..color = const Color(0x33000000) // Semi-transparent black
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
  canvas.drawCircle(const Offset(dotX + 4, dotY + 4), dotRadius, shadowPaint);

  // Draw white stroke
  final strokePaint = Paint()
    ..color = const Color(0xFFFFFFFF)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 6
    ..isAntiAlias = true;
  canvas.drawCircle(const Offset(dotX, dotY), dotRadius, strokePaint);

  // Draw red fill
  canvas.drawCircle(const Offset(dotX, dotY), dotRadius - 3, dotPaint);
}
