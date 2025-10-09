import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:cat_fish/components/bobber_timer_component.dart';

class BobberComponent extends SpriteComponent with HasGameRef, TapCallbacks {
  bool isWriggling = false;
  bool _hasBeenTapped = false;
  late TimerComponent _calmTimer;
  late TimerComponent _wriggleTimer;
  late Vector2 _originalPosition;
  BobberTimerComponent? _timer;

  final void Function(bool success)? onTap;
  final void Function()? onWriggleEnd;

  bool get isReadyToCatch => isWriggling;

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

    // 🕒 Start with randomized calm delay before wriggling
    _startCalmDelay();
  }

  void _startCalmDelay() {
    // ✅ Use Random() here so dart:math is actually used
    final calmDelay = 1.9 + Random().nextDouble() * (2.5 - 1.9); // 1.9–2.5s
    _calmTimer = TimerComponent(
      period: calmDelay,
      repeat: false,
      onTick: _startWriggleAnimation,
    );
    add(_calmTimer);
  }

  void _startWriggleAnimation() async {
    if (_hasBeenTapped) return;

    isWriggling = true;
    FlameAudio.play('splash.wav', volume: 0.5);
    _addWriggleEffects();

    final pieSprite = await gameRef.loadSprite('pie.png');
    _timer = BobberTimerComponent(
      totalTime: 2.9 + Random().nextDouble() * (3.5 - 2.9), // ✅ 2.9–3.5s range
      remainingTime: 2.9,
      baseSprite: pieSprite,
    )..priority = 1000;

    _timer!.position = _originalPosition + Vector2(0, -40);
    parent?.add(_timer!);

    _wriggleTimer = TimerComponent(
      period: _timer!.totalTime, // match the random wriggle duration
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
      _wriggleTimer.removeFromParent();
      removeAllEffects();
      _timer?.removeFromParent();
      _timer = null;
      position = _originalPosition.clone();
      angle = 0;
      onTap?.call(true);
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!_hasBeenTapped) {
      if (isWriggling) {
        print("🎯 Bobber tapped during wriggle!");
        onTapped();
      } else {
        print("⏰ Too early! Fish hasn’t bitten yet!");
        onTap?.call(false);
        removeFromParent();
      }
    }
  }

  void removeAllEffects() {
    children.whereType<Effect>().toList().forEach((e) => e.removeFromParent());
  }

  void _endWriggle() {
    if (_hasBeenTapped) return;
    isWriggling = false;
    _timer?.removeFromParent();
    _timer = null;
    onWriggleEnd?.call();
    removeFromParent();
  }
}
