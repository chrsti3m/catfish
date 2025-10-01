// lib/components/user_feedback.dart
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'catch_result.dart';

class UserFeedback extends SpriteComponent with HasGameRef {
  final String type; // 'miss' or 'success'
  final double fishWeight; // Store fish weight
  
  UserFeedback._({
    required Vector2 position,
    required this.type,
    this.fishWeight = 0.0, // Add fishWeight with default value
  }) : super(
          position: position,
          size: Vector2(100, 40),
          anchor: Anchor.center,
        );

  factory UserFeedback.miss({required Vector2 position}) {
    return UserFeedback._(position: position, type: 'miss');
  }

  factory UserFeedback.success({
    required Vector2 position,
    required double fishWeight,
  }) {
    return UserFeedback._(
      position: position,
      type: 'success',
      fishWeight: fishWeight,
    );
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Load different sprites based on feedback type
    final imagePath = type == 'miss' ? 'MISS.png' : 'NICE.png';
    sprite = await gameRef.loadSprite(imagePath);

    // Adjust size based on the sprite's aspect ratio
    if (sprite != null) {
      final imageSize = sprite!.originalSize;
      size = imageSize * 0.8;
    }

    // Bounce effect
    add(SequenceEffect(
      [
        MoveEffect.by(
          Vector2(0, -30),
          EffectController(duration: 0.2, curve: Curves.easeOut),
        ),
        MoveEffect.by(
          Vector2(0, 10),
          EffectController(duration: 0.1, curve: Curves.easeIn),
        ),
        MoveEffect.by(
          Vector2(0, -10),
          EffectController(duration: 0.1, curve: Curves.easeOut),
        ),
      ],
      onComplete: () {
        if (type == 'miss') {
          // MISS just fades out
          add(OpacityEffect.fadeOut(
            LinearEffectController(1.0),
            onComplete: removeFromParent,
          ));
        } else {
          // NICE: fade out then show CatchResult
          add(OpacityEffect.fadeOut(
            LinearEffectController(0.5),
            onComplete: () {
              removeFromParent();
              // Show fish + weight result under the NICE
              parent?.add(
                CatchResult(
                  position: position + Vector2(0, 40),
                  fishWeight: fishWeight, // Use the stored fishWeight
                ),
              );
            },
          ));
        }
      },
    ));
  }
}