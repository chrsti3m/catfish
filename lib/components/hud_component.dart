import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HudComponent extends PositionComponent {
  late TextComponent _weightText;
  late TextComponent _timerText;
  late RectangleComponent _fillBar;
  late TextComponent _levelText;


  int _goalWeight = 10; // default goal
  int _currentWeight = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final hudY = -190.0;
    final hudX = -450.0;
    final hudHeight = 60.0;
    final hudWidth = 360.0;

    // Wooden banner background
    final woodenBanner = RectangleComponent(
      size: Vector2(hudWidth, hudHeight),
      paint: Paint()
        ..color = const Color(0xFF8B4513)
        ..style = PaintingStyle.fill,
      anchor: Anchor.topLeft,
      position: Vector2(hudX, hudY),
    );
    add(woodenBanner);

    // Border
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
    // 🪧 LEVEL TITLE HEADER (Top Center of Screen)
// 🪧 LEVEL TITLE HEADER (Same line as HUD, but centered on screen)
_levelText = TextComponent(
  text: 'LEVEL 1',
  textRenderer: TextPaint(
    style: GoogleFonts.pressStart2p(
      color: const Color(0xFFFFFD8D),
      fontSize: 12,
      height: 1.2,
      shadows: const [
        Shadow(color: Colors.black, offset: Offset(0, 2), blurRadius: 0),
        Shadow(color: Colors.black, offset: Offset(0, -2), blurRadius: 0),
        Shadow(color: Colors.black, offset: Offset(2, 0), blurRadius: 0),
        Shadow(color: Colors.black, offset: Offset(-2, 0), blurRadius: 0),
      ],
    ),
  ),
  anchor: Anchor.center,
  position: Vector2(0, hudY + hudHeight / 2), // ✅ Centered horizontally, same vertical line as HUD
);
add(_levelText);


    // Grain lines
    add(RectangleComponent(
      size: Vector2(hudWidth - 12, 1),
      paint: Paint()..color = const Color(0xFFA0522D),
      anchor: Anchor.topLeft,
      position: Vector2(hudX + 6, hudY + 6),
    ));

    add(RectangleComponent(
      size: Vector2(hudWidth - 12, 1),
      paint: Paint()..color = const Color(0xFFA0522D),
      anchor: Anchor.topLeft,
      position: Vector2(hudX + 6, hudY + hudHeight - 6),
    ));

    add(RectangleComponent(
      size: Vector2(hudWidth - 20, 1),
      paint: Paint()..color = const Color(0xFF654321),
      anchor: Anchor.topLeft,
      position: Vector2(hudX + 10, hudY + hudHeight / 2),
    ));

    // Progress bar background sprite
    final progressBarWidth = hudWidth * 0.7;
    final progressBarHeight = 41.0;

    final progressBar = SpriteComponent(
      sprite: await Sprite.load('bar.png'),
      size: Vector2(progressBarWidth, progressBarHeight),
      anchor: Anchor.centerLeft,
      position: Vector2(hudX + 12, hudY + hudHeight / 2),
    );
    add(progressBar);

    final progressBarCenterX = hudX + 12 + progressBarWidth / 2;
    final progressBarCenterY = hudY + hudHeight / 2;

    // Green fill bar (starts empty)
    _fillBar = RectangleComponent(
      size: Vector2(0, progressBarHeight - 30),
      paint: Paint()..color = const Color(0xFF32CD32),
      anchor: Anchor.centerLeft,
      position: Vector2(progressBar.position.x + 20, progressBar.position.y - -1),
    );
    add(_fillBar);

    // Text paint
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

    const initialText = '0kg / 10kg';
    final textWidth = textPaint.format(initialText).metrics.width;
    const fishWidth = 20.0;
    const spacing = 4.0;
    final combinedWidth = fishWidth + spacing + textWidth;
    final startX = progressBarCenterX - combinedWidth / 2;

    // Fish icon
    final fishSprite = SpriteComponent(
      sprite: await Sprite.load('fish.png'),
      size: Vector2(fishWidth, 12),
      anchor: Anchor.centerLeft,
      position: Vector2(startX, progressBarCenterY),
    );
    add(fishSprite);

    // Weight text
    _weightText = TextComponent(
      text: initialText,
      textRenderer: textPaint,
      anchor: Anchor.centerLeft,
      position: Vector2(startX + fishWidth + spacing, progressBarCenterY),
    );
    add(_weightText);

    // Timer
    _timerText = TextComponent(
      text: '1:00',
      textRenderer: TextPaint(
        style: GoogleFonts.pressStart2p(
          color: const Color(0xFF00FF9D),
          fontSize: 14,
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

 /// Updates HUD with new weight
  void updatePlayerWeight(int currentWeight, int goalWeight) {
    _goalWeight = goalWeight;

    // clamp to not overshoot
    _currentWeight = currentWeight.clamp(0, _goalWeight);

    _weightText.text =
        '${_currentWeight}kg / ${_goalWeight}kg';

    updateFillProgress(_currentWeight / _goalWeight);
  }
  
  /// Updates the timer text
  void updateGameTimer(int seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    _timerText.text = '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  /// Updates progress bar fill
  void updateFillProgress(double progress) {
    final progressBarWidth = 360.0 * 0.7;
    const leftOffset = 20.0;
    const rightBuffer = 17.0;

    final maxFillWidth = progressBarWidth - leftOffset - rightBuffer;
    _fillBar.size.x = maxFillWidth * progress.clamp(0.0, 1.0);
  }

  /// Updates the level title
void updateLevelTitle(int levelNumber) {
  _levelText.text = 'LEVEL $levelNumber';
}

}
