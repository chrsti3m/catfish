import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'dart:math' as math;

class BobberComponent extends SpriteComponent with HasGameRef, TapCallbacks {
  bool isWriggling = false;
  bool _hasBeenTapped = false;
  late TimerComponent _calmTimer;
  late TimerComponent _wriggleTimer;
  late Vector2 _originalPosition;

  final void Function()? onWriggleEnd;
  final void Function()? onTap; // ✅ notify game when catch succeeds
  
  BobberComponent({
    required Vector2 position,
    this.onWriggleEnd,
    this.onTap,
  }) : super(
          position: position + Vector2(-2, -10),
          size: Vector2(20, 20),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await gameRef.loadSprite('bobber.png');
    _originalPosition = position.clone();
    
    // Start with calm delay
    _startCalmDelay();
  }
  
  void _startCalmDelay() {
    _calmTimer = TimerComponent(
      period: 0.5,
      repeat: false,
      onTick: _startWriggleAnimation,
    );
    add(_calmTimer);
  }
  
  void _startWriggleAnimation() {
    if (_hasBeenTapped) return;
    
    isWriggling = true;
    _addWriggleEffects();
    
    // ✅ Set wriggle duration to 2.2s
    _wriggleTimer = TimerComponent(
      period: 2.2,
      repeat: false,
      onTick: _endWriggle,
    );
    add(_wriggleTimer);
  }
  
  void _addWriggleEffects() {
    final horizontalWriggle = SequenceEffect([
      MoveByEffect(Vector2(3, 0), EffectController(duration: 0.1)),
      MoveByEffect(Vector2(-6, 0), EffectController(duration: 0.2)),
      MoveByEffect(Vector2(3, 0), EffectController(duration: 0.1)),
    ], infinite: true);
    
    final verticalWriggle = SequenceEffect([
      MoveByEffect(Vector2(0, -2), EffectController(duration: 0.15)),
      MoveByEffect(Vector2(0, 4), EffectController(duration: 0.3)),
      MoveByEffect(Vector2(0, -2), EffectController(duration: 0.15)),
    ], infinite: true);
    
    final rotationWriggle = SequenceEffect([
      RotateEffect.by(0.1, EffectController(duration: 0.2)),
      RotateEffect.by(-0.2, EffectController(duration: 0.4)),
      RotateEffect.by(0.1, EffectController(duration: 0.2)),
    ], infinite: true);
    
    add(horizontalWriggle);
    add(verticalWriggle);
    add(rotationWriggle);
  }
  
  void onTapped() {
    if (isWriggling && !_hasBeenTapped) {
      _hasBeenTapped = true;
      isWriggling = false;
      
      // Stop wriggle + effects
      _wriggleTimer.removeFromParent();
      removeAllEffects();
      
      // Reset bobber
      position = _originalPosition.clone();
      angle = 0;
      
      // ✅ notify the game (success catch)
      onTap?.call();
    }
  }

  @override
void onTapDown(TapDownEvent event) {
  print("🎯 Bobber tapped during wriggle!");
  if (isWriggling) {
    onTapped();
  }
}
  void removeAllEffects() {
    children.whereType<Effect>().toList().forEach((effect) {
      effect.removeFromParent();
    });
  }

  void _endWriggle() {
    if (_hasBeenTapped) return;
    
    isWriggling = false;
    // Notify game wriggle ended without catch
    onWriggleEnd?.call();
    removeFromParent();
  }
}
