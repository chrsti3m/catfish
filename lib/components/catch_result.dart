import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CatchResult extends PositionComponent with HasGameRef {
  final double fishWeight;

  CatchResult({
    required Vector2 position,
    required this.fishWeight,
  }) : super(
          position: position,
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Create a container that will manage opacity for both elements
    final container = _FadeContainer(
      position: position + Vector2(0, -40), // Position above the shadow
    );

    // Fish sprite
    final fish = SpriteComponent(
      sprite: await gameRef.loadSprite('fish.png'),
      size: Vector2(60, 30),
      anchor: Anchor.center,
    );
    container.add(fish);

    // Weight text
    final text = TextComponent(
      text: "+${fishWeight.toStringAsFixed(1)}kg",
      textRenderer: TextPaint(
        style: GoogleFonts.pressStart2p(
          fontSize: 12,
          color: Colors.white,
        ),
      ),
      anchor: Anchor.centerLeft,
      position: Vector2(40, 0),
    );
    container.add(text);

    // Add the container to the parent
    parent?.add(container);

    // Start fade out sequence after delay
    container.startFadeOut();
  }
}

class _FadeContainer extends PositionComponent with HasGameRef {
  double opacity = 1.0;

  _FadeContainer({
    required Vector2 position,
  }) : super(
          position: position,
          anchor: Anchor.center,
        );

  @override
  void render(Canvas canvas) {
    canvas.saveLayer(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()..color = Colors.white.withOpacity(opacity),
    );
    super.render(canvas);
    canvas.restore();
  }

  void startFadeOut() {
    add(
      TimerComponent(
        period: 0.5, // Wait for NICE to fade out first
        removeOnFinish: true,
        onTick: () {
          add(
            TimerComponent(
              period: 0.05,
              repeat: true,
              onTick: () {
                opacity -= 0.05;
                if (opacity <= 0) {
                  opacity = 0;
                  removeFromParent();
                }
              },
            ),
          );
        },
      ),
    );
  }
}
