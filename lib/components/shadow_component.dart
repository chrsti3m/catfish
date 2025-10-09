import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flame/collisions.dart';
// Add this at the top of shadow_component.dart
import 'package:cat_fish/components/user_feedback.dart';

class ShadowComponent extends SpriteComponent
    with HoverCallbacks, TapCallbacks, HasGameRef, HasCollisionDetection {
  final Function(Vector2 position, ShadowComponent component)? onTap;

  ShadowComponent({
    required Sprite sprite,
    required Vector2 position,
    required Vector2 size,
    this.onTap,
  }) : super(
          sprite: sprite,
          position: position,
          size: size,
          anchor: Anchor.center,
        ) {
    // Add a hitbox so hover/tap can work
    add(RectangleHitbox());
  }

  bool _isHovered = false;
  late Paint _outlinePaint;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Initialize the outline paint with a glow effect
    _outlinePaint = Paint()
      ..color = Colors.yellow.withOpacity(0.8)
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 3.0);
  }

  @override
  void onHoverEnter() {
    _isHovered = true;
  }

  @override
  void onHoverExit() {
    _isHovered = false;
  }

  @override
  void render(Canvas canvas) {
    // Draw outline effect first (behind the sprite) if hovered
    if (_isHovered && sprite != null) {
      // Create outline by drawing the sprite multiple times with offsets
      final outlineOffsets = [
        Vector2(-3, -3), Vector2(-3, 0), Vector2(-3, 3),
        Vector2(0, -3),                   Vector2(0, 3),
        Vector2(3, -3),  Vector2(3, 0),  Vector2(3, 3),
        Vector2(-2, -2), Vector2(-2, 0), Vector2(-2, 2),
        Vector2(0, -2),                   Vector2(0, 2),
        Vector2(2, -2),  Vector2(2, 0),  Vector2(2, 2),
      ];
      
      // Create outline paint with transparency for layering effect
      final outlinePaint = Paint()
        ..color = Colors.yellow.withOpacity(0.6)
        ..colorFilter = const ColorFilter.mode(Colors.white, BlendMode.srcATop);
      
      // Draw each offset copy to create the outline
      for (final offset in outlineOffsets) {
        canvas.save();
        canvas.translate(offset.x, offset.y);
        sprite!.render(canvas, size: size, overridePaint: outlinePaint);
        canvas.restore();
      }
    }
    
    // Draw the main sprite on top
    super.render(canvas);
  }

  @override
  void onTapDown(TapDownEvent event) {
    // When tapped, notify the parent about the tap
    if (onTap != null) {
      onTap!(position, this);
    }
  }

 // In shadow_component.dart
void showFeedback(bool isSuccess, [double? fishWeight]) {
  if (isSuccess) {
    final success = UserFeedback.success(
      position: position + Vector2(0, -size.y/2 - 30),
      fishWeight: fishWeight ?? 0.0,
    );
    parent?.add(success);
  } else {
    final miss = UserFeedback.miss(position: position + Vector2(0, -size.y/2 - 30));
    parent?.add(miss);
  }
}
 bool get isParentMounted => parent != null && !parent!.isRemoved;
} 
