import 'dart:math';

import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/camera.dart';
import 'package:flame/extensions.dart';
import 'components/shadow_component.dart';
import 'components/bobber_component.dart';
import 'components/hud_component.dart';
import 'package:google_fonts/google_fonts.dart';
import 'components/user_feedback.dart';

class CatFish extends FlameGame with HasCollisionDetection {
  late final World _world;
  late final CameraComponent _camera;
  BobberComponent? _currentBobber;
  HudComponent? _hud;
  ShadowComponent? _persistentShadow;

  // ✅ keep rod as a field so you can manipulate it later
  SpriteComponent? _rod;

  // Game state
  double _playerWeight = 0.0;
  final double _levelGoal = 10.0;
  final double _rodSuccessChance = 0.50;
  final Random _random = Random();
  bool _isBobberActive = false;

    

  bool _showModal = true;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

 

    // Preload font
    await GoogleFonts.pendingFonts([GoogleFonts.pressStart2p()]);

    _world = World();
    add(_world);

    _camera = CameraComponent.withFixedResolution(
      world: _world,
      width: 1024,
      height: 421,
    );
    _camera.viewfinder.anchor = Anchor.center;
    add(_camera);

    // Background
    final bg = SpriteComponent(
      sprite: await loadSprite('BACKGROUND.png'),
      size: Vector2(1024, 421),
      anchor: Anchor.center,
      position: Vector2.zero(),
    );
    _world.add(bg);

    // Character
    final character = SpriteComponent(
      sprite: await loadSprite('cat.png'),
      size: Vector2(70, 40),
      anchor: Anchor.center,
      position: Vector2(-205, 90),
    );
    _world.add(character);

    // ✅ Rod (store in class field)
    _rod = SpriteComponent(
      sprite: await loadSprite('ROD1.png'),
      size: Vector2(90, 80),
      anchor: Anchor.center,
      position: Vector2(-145, 71), // initial position
      angle: -0.8,                 // initial angle
    );
    _world.add(_rod!);

    // Add persistent shadow
    await _createPersistentShadow();

    // HUD
    _hud = HudComponent();
    _world.add(_hud!);
  }

  Future<void> _createPersistentShadow() async {
    _persistentShadow = ShadowComponent(
      sprite: await loadSprite('shadow.png'),
      size: Vector2(100, 45),
      position: Vector2(150, 150),
      onTap: (tapPosition, shadowComponent) => _onShadowTapped(tapPosition, shadowComponent),
    );
    _world.add(_persistentShadow!);
  }

  void _onShadowTapped(Vector2 tapPosition, ShadowComponent shadow) {
    if (_isBobberActive) {
      print("⏳ Wait for the current bobber to finish!");
      return;
    }

    _isBobberActive = true;
    _currentBobber?.removeFromParent();

    _currentBobber = BobberComponent(
      position: shadow.position,
      onWriggleEnd: () {
        _currentBobber = null;
        _isBobberActive = false;

        // ✅ Reset rod back to initial
        _rod?.position = Vector2(-145, 71);
        _rod?.angle = -0.8;

        print("🐟 Bobber stopped wriggling");
        _persistentShadow?.showFeedback(false);
      },
      onTap: _attemptCatch,
    );
    _world.add(_currentBobber!);

    // ✅ Change rod pose when bobber is active
    _rod?.position = Vector2(-135, 78);
    _rod?.angle = -0.3;
  }

  void _attemptCatch() {
    if (_currentBobber == null) {
      print("❌ Bobber doesn't exist!");
      return;
    }

    print("🎣 Attempting to catch fish...");
    _currentBobber?.removeFromParent();
    _currentBobber = null;
    _isBobberActive = false;

    // ✅ Reset rod after catch attempt
    _rod?.position = Vector2(-145, 71);
    _rod?.angle = -0.8;

    // In _attemptCatch method
     if (_random.nextDouble() < _rodSuccessChance) {
  final fishWeight = _generateFishWeight();
  _playerWeight += fishWeight;
  _hud?.updatePlayerWeight(_playerWeight, _levelGoal);
  _hud?.updateFillProgress(_playerWeight / _levelGoal);
  print("✅ SUCCESS! Caught a fish! Weight: ${fishWeight.toStringAsFixed(1)}kg. Total: ${_playerWeight.toStringAsFixed(1)}kg");
  _persistentShadow?.showFeedback(true, fishWeight); // Pass fish weight here
} else {
  print("❌ FAILED! The fish got away!");
  _persistentShadow?.showFeedback(false);
}

  }

  double _generateFishWeight() {
  final remainingWeight = _levelGoal - _playerWeight;
  
  // If remaining weight is very small, just return it to reach exactly 10.0kg
  if (remainingWeight <= 0.1) {
    return 0.0; // Or return remainingWeight if you want to be precise
  }

  double fishWeight;
  final roll = _random.nextDouble();
  
  if (remainingWeight <= 0.5) {
    // If we're very close, just return the remaining weight
    return remainingWeight;
  } else if (remainingWeight <= 3.0) {
    // If remaining weight is small, generate smaller fish
    fishWeight = _random.nextDouble() * (remainingWeight * 0.8) + (remainingWeight * 0.2);
  } else {
    // Normal fish generation
    if (roll < 0.5) {
      fishWeight = _random.nextDouble() * 0.7 + 0.5; // 0.5 - 1.2kg
    } else if (roll < 0.9) {
      fishWeight = _random.nextDouble() * 1.2 + 1.3; // 1.3 - 2.5kg
    } else {
      fishWeight = _random.nextDouble() * 1.5 + 3.0; // 3.0 - 4.5kg
    }
    
    // If this fish would put us over the limit, cap it
    if (_playerWeight + fishWeight > _levelGoal) {
      fishWeight = _levelGoal - _playerWeight;
    }
  }

  return double.parse(fishWeight.toStringAsFixed(2)); // Round to 2 decimal places
}
}
