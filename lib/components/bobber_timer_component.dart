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
  double radius = 16;

  BobberTimerComponent({
    required this.totalTime,
    required this.remainingTime,
    this.baseSprite,
    this.speedMultiplier = 1.0,
  }) : super(size: Vector2.all(40), anchor: Anchor.center);

  @override
void render(Canvas canvas) {
  super.render(canvas);

  baseSprite?.render(canvas, size: size);

  double progress = remainingTime / totalTime;
  double sweepAngle = 2 * math.pi * progress;

  Color color;
  if (progress > 0.6) {
    color = Colors.green;
  } else if (progress > 0.3) {
    color = Colors.orange;
  } else {
    color = Colors.red;
  }

  arcPaint
    ..color = color.withOpacity(0.8)
    ..style = PaintingStyle.fill; // ✅ fill instead of stroke
  // remove strokeWidth

  // Draw the countdown filling
  canvas.drawArc(
    Rect.fromCircle(center: Offset(size.x / 2, size.y / 2), radius: radius),
    -math.pi / 2,
    sweepAngle,
    true, // ✅ fill inside
    arcPaint,
  );
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
