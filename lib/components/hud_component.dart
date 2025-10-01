import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HudComponent extends PositionComponent {
  late TextComponent _weightText;
  late TextComponent _timerText;
  late RectangleComponent _fillBar;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Position HUD at top-left corner of the world
    final hudY = -190.0; 
    final hudX = -450.0; 
    final hudHeight = 60.0; 
    final hudWidth = 360.0; 
    
    // Wooden plank banner background
    final woodenBanner = RectangleComponent(
      size: Vector2(hudWidth, hudHeight),
      paint: Paint()
        ..color = const Color(0xFF8B4513)
        ..style = PaintingStyle.fill,
      anchor: Anchor.topLeft,
      position: Vector2(hudX, hudY),
    );
    add(woodenBanner);
    
    // Thick dark brown outline
    final woodBorder = RectangleComponent(
      size: Vector2(hudWidth, hudHeight),
      paint: Paint()
        ..color = const Color(0xFF1A1008)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
      anchor: Anchor.topLeft,
      position: Vector2(hudX, hudY),
    );
    add(woodBorder);
    
    // Inner wood texture
    final topGrain = RectangleComponent(
      size: Vector2(hudWidth - 12, 1),
      paint: Paint()..color = const Color(0xFFA0522D),
      anchor: Anchor.topLeft,
      position: Vector2(hudX + 6, hudY + 6),
    );
    add(topGrain);
    
    final bottomGrain = RectangleComponent(
      size: Vector2(hudWidth - 12, 1),
      paint: Paint()..color = const Color(0xFFA0522D),
      anchor: Anchor.topLeft,
      position: Vector2(hudX + 6, hudY + hudHeight - 6),
    );
    add(bottomGrain);
    
    final middleGrain = RectangleComponent(
      size: Vector2(hudWidth - 20, 1),
      paint: Paint()..color = const Color(0xFF654321),
      anchor: Anchor.topLeft,
      position: Vector2(hudX + 10, hudY + hudHeight / 2),
    );
    add(middleGrain);

   // CENTER: Main progress bar (taller for overlay inside it)
final progressBarWidth = hudWidth * 0.7;
final progressBarHeight = 41.0; // increased for space inside

final progressBar = SpriteComponent(
  sprite: await Sprite.load('bar.png'),
  size: Vector2(progressBarWidth, progressBarHeight),
  anchor: Anchor.centerLeft,
  position: Vector2(hudX + 12, hudY + hudHeight / 2),
);
add(progressBar);

// Calculate center of the progress bar
final progressBarCenterX = hudX + 12 + progressBarWidth / 2;
final progressBarCenterY = hudY + hudHeight / 2;

// Green fill bar for progress
_fillBar = RectangleComponent(
  size: Vector2(0, progressBarHeight - 50), // Start with 0 width
  paint: Paint()..color = const Color(0xFF32CD32), // Lime green
  anchor: Anchor.centerLeft,
  position: Vector2(progressBar.position.x + 20, progressBar.position.y + -8),
);
add(_fillBar);

// Create text paint so we can measure width
final textPaint = TextPaint(
  style: GoogleFonts.pressStart2p(
    color: const Color(0xFFFFFD8D),
    fontSize: 8,
    height: 1.2,
    shadows: const [
      Shadow(color: Colors.black, offset: Offset(0, 2), blurRadius: 0),
      Shadow(color: Colors.black, offset: Offset(0, -2), blurRadius: 0),
      Shadow(color: Colors.black, offset: Offset(2, 0), blurRadius: 0),
      Shadow(color: Colors.black, offset: Offset(-2, 0), blurRadius: 0),
    ],
  ),
);

const currentText = '0kg / 10kg';
// Measure text width using the correct Flame API
final textWidth = textPaint.format(currentText).metrics.width;
final fishWidth = 20.0;
final spacing = 4.0; // small gap between fish and text

// Combined width of fish + spacing + text
final combinedWidth = fishWidth + spacing + textWidth;

// Starting X so the group is centered in bar
final startX = progressBarCenterX - combinedWidth / 2;

// Overlay: Fish icon
final fishSprite = SpriteComponent(
  sprite: await Sprite.load('fish.png'),
  size: Vector2(fishWidth, 12),
  anchor: Anchor.centerLeft,
  position: Vector2(startX, progressBarCenterY),
);
add(fishSprite);

// Overlay: Weight text
_weightText = TextComponent(
  text: currentText,
  textRenderer: textPaint,
  anchor: Anchor.centerLeft,
  position: Vector2(startX + fishWidth + spacing, progressBarCenterY),
);
add(_weightText);


    // Right side: Digital timer
    _timerText = TextComponent(
      text: '1:00',
      textRenderer: TextPaint(
        style: GoogleFonts.pressStart2p(
          color: const Color(0xFF00FF9D),
          fontSize: 14, // slight bump to balance weight text
          height: 1.1,
          shadows: const [
            Shadow(color: Colors.black, offset: Offset(0, 2), blurRadius: 0),
            Shadow(color: Colors.black, offset: Offset(0, -2), blurRadius: 0),
            Shadow(color: Colors.black, offset: Offset(2, 0), blurRadius: 0),
            Shadow(color: Colors.black, offset: Offset(-2, 0), blurRadius: 0),
          ],
        ),
      ),
      anchor: Anchor.centerRight,
      position: Vector2(hudX + hudWidth - 20, hudY + hudHeight / 2),
    );
    add(_timerText);
  }

  void updatePlayerWeight(double currentWeight, double goalWeight) {
    _weightText.text = '${currentWeight.toStringAsFixed(1)}kg / ${goalWeight.toStringAsFixed(1)}kg';
  }

  void updateGameTimer(int seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    _timerText.text = '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

 void updateFillProgress(double progress) {
  final progressBarWidth = 360.0 * 0.7;
  final leftOffset = 20.0;
  final rightBuffer = 17; // prevents visual spill

  final maxFillWidth = progressBarWidth - leftOffset - rightBuffer;
  _fillBar.size.x = maxFillWidth * progress.clamp(0.0, 1.0);
}
}
