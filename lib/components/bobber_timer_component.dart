import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class BobberTimerComponent extends PositionComponent {
  final double totalTime;
  double remainingTime;
  final double speedMultiplier;

  final Sprite? baseSprite;
  Paint arcPaint = Paint()
    ..style = PaintingStyle.stroke
    ..isAntiAlias = true
    ..strokeCap = StrokeCap.round;
  double radius = 19;

  BobberTimerComponent({
    required this.totalTime,
    required this.remainingTime,
    this.baseSprite,
    this.speedMultiplier = 1.0,
  }) : super(size: Vector2.all(40), anchor: Anchor.center);

 @override
void render(Canvas canvas) {
  super.render(canvas);

  // Ensure the sprite exists before rendering
  if (baseSprite == null) return;

  double progress = remainingTime / totalTime;
  double sweepAngle = 2 * math.pi * progress;

  // Bright neon colors
  Color color;
  if (progress > 0.6) {
    color = const Color(0xFF00FF7F); // bright neon green
  } else if (progress > 0.3) {
    color = const Color(0xFFFFD700); // bright gold
  } else {
    color = const Color(0xFFFF4C4C); // bright red
  }

  // Save the layer to apply masking
  canvas.saveLayer(Rect.fromLTWH(0, 0, size.x, size.y), Paint());

  // Step 1: Draw the base pixelated pie
  baseSprite!.render(canvas, size: size);

  // Step 2: Overlay color fill using SRC_IN mode to mask inside sprite
  final fillPaint = Paint()
    ..color = color.withOpacity(0.95)
    ..blendMode = BlendMode.srcIn; // ✅ Only colors inside the sprite's alpha

  // Step 3: Draw a pie-shaped filled region to match progress
  canvas.drawArc(
    Rect.fromCircle(center: Offset(size.x / 2, size.y / 2), radius: radius),
    -math.pi / 2,
    sweepAngle,
    true,
    fillPaint,
  );

  // Step 4: Restore canvas
  canvas.restore();
}



  @override
  void update(double dt) {
    super.update(dt);
    remainingTime -= dt * speedMultiplier;
    if (remainingTime <= 0) {
      removeFromParent();
    }
  }
}
