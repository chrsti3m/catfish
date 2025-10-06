import 'dart:math';
import 'dart:async' as async; // ✅ for the real Dart Timer
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

  SpriteComponent? _rod; // ✅ keep rod as a field

  // Game state
  int _currentLevel = 1;
  int _playerWeight = 0;
  double _rodSuccessChance = 0.50;
  final Random _random = Random();
  bool _isBobberActive = false;

  // Map of level goals  
final Map<int, int> _levelGoals = {
  1: 10, // Level 1 requires 10kg
  2: 15, // Level 2 requires 15kg
  3: 20, // Level 3 requires 20kg
  4: 25, // Level 4 requires 25kg
  5: 30, // Level 5 requires 30kg

};

// Getter → always gives the right target for the current level
int get _levelGoal => _levelGoals[_currentLevel] ?? 10;


  // Map of rod configs per level
final Map<int, Map<String, dynamic>> _rodConfigs = {
  1: { "sprite": "ROD1.png", "chance": 0.50 },
  2: { "sprite": "ROD2.png", "chance": 0.60 },
  3: { "sprite": "ROD3.png", "chance": 0.70 },
  4: { "sprite": "ROD4.png", "chance": 0.75 },
  5: { "sprite": "ROD5.png", "chance": 0.80 },
};


  // Timer & Game state
  async.Timer? _countdownTimer;
  int _timeLeft = 60;
  bool _isGameRunning = false;

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

    //  Load rod based on current level
    await _loadRodForLevel(_currentLevel);


    // Add persistent shadow
    await _createPersistentShadow();

    // HUD
    _hud = HudComponent();
    _world.add(_hud!);

    // ✅ Show Start overlay at beginning
    overlays.add('StartMenu');
  }

  void startGame() {
    _isGameRunning = true;
    _timeLeft = 60;

    // ✅ Reset player progress
    _playerWeight = 0;
    _hud?.updatePlayerWeight(_playerWeight, _levelGoal);
    _hud?.updateFillProgress(0.0);
    _hud?.updateGameTimer(_timeLeft);

    // ✅ Reset rod to initial state
    _rod?.position = Vector2(-145, 71);
    _rod?.angle = -0.8;

    // ✅ Cancel any old timer
    _countdownTimer?.cancel();

    // ✅ Start countdown again
    _countdownTimer = async.Timer.periodic(const Duration(seconds: 1), (timer) {
      _timeLeft--;
      _hud?.updateGameTimer(_timeLeft);

      if (_timeLeft <= 0) {
        timer.cancel();
        _endGame();
      }
    });
  }

  // ✅ Handle game end
  void _endGame() {
    _isGameRunning = false;
    if (_playerWeight < _levelGoal) {
      overlays.add('FailMenu'); // show fail modal
    }
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
    if (!_isGameRunning) return;
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
        if (!_isGameRunning) return;

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

        if (_random.nextDouble() < _rodSuccessChance) {
          final fishWeight = _generateFishWeight();
          _playerWeight += fishWeight;

          // Cap to level goal
          if (_playerWeight > _levelGoal) {
            _playerWeight = _levelGoal;
          }

          _hud?.updatePlayerWeight(_playerWeight, _levelGoal);
          _hud?.updateFillProgress(_playerWeight / _levelGoal);
          print("✅ SUCCESS! Caught a fish! Weight: ${fishWeight}kg. Total: ${_playerWeight}kg");
          _persistentShadow?.showFeedback(true, fishWeight.toDouble());

          // ✅ Step 2: Check if level goal is reached
          if (_playerWeight >= _levelGoal) {
            print("🏆 Level $_currentLevel Complete!");
            _countdownTimer?.cancel();   // stop timer
            _isGameRunning = false;      // stop game loop
            overlays.add('NextLevelMenu'); // show next level overlay
            return;
          }

        } else {
          print("❌ FAILED! The fish got away!");
          _persistentShadow?.showFeedback(false);
        }
      }


   /// ✅ Fish weight generation balanced for Level 1 rod (50% success rate).
  /// 65% chance → 1kg, 25% → 2kg, 10% → 3kg
 int _generateFishWeight() {
  final remainingWeight = _levelGoal - _playerWeight;
  if (remainingWeight <= 0) return 0;

  final roll = _random.nextDouble();
  int fishWeight = 1;

  // 🎣 Define weight distributions per level
  final distributions = {
    1: [0.65, 0.25, 0.10],        // 65% 1kg, 25% 2kg, 10% 3kg
    2: [0.50, 0.35, 0.10, 0.05], // 50% 1kg, 35% 2kg, 10% 3kg, 5% 4kg
    3: [0.40, 0.35, 0.15, 0.10],
    4: [0.30, 0.30, 0.25, 0.10, 0.05],
    5: [0.20, 0.25, 0.25, 0.20, 0.10],
  };

  // 🧭 Print debug info when this function runs
  print('🎮 --- Fish Weight Debug ---');
  print('🎣 Level: $_currentLevel');
  print('📊 Fish Weight Distribution: ${distributions[_currentLevel]}');
  print('🎲 Roll value: ${roll.toStringAsFixed(3)}');

  // Use distribution for current level or fallback
  final dist = distributions[_currentLevel] ?? distributions[1]!;

  double cumulative = 0;
  for (int i = 0; i < dist.length; i++) {
    cumulative += dist[i];
    if (roll < cumulative) {
      fishWeight = i + 1; // weight = index + 1
      break;
    }
  }

  // 🚫 Prevent overshoot beyond goal
  if (fishWeight > remainingWeight) {
    fishWeight = remainingWeight;
  }

  // ✅ Print result for clarity
  print('🐟 Generated fish weight: $fishWeight kg for Level $_currentLevel');
  print('---------------------------');

  return fishWeight;
}



  Future<void> startNextLevel() async {
    _currentLevel++; // move to next level
    _playerWeight = 0;
    _timeLeft = 60;
    _isGameRunning = true;

     await _loadRodForLevel(_currentLevel);

    // Reset HUD
    _hud?.updatePlayerWeight(_playerWeight, _levelGoal);
    _hud?.updateFillProgress(0.0);
    _hud?.updateGameTimer(_timeLeft);

    // Reset rod
    _rod?.position = Vector2(-145, 71);
    _rod?.angle = -0.8;

    // Cancel any old timer
    _countdownTimer?.cancel();

    // Restart countdown
    _countdownTimer = async.Timer.periodic(const Duration(seconds: 1), (timer) {
      _timeLeft--;
      _hud?.updateGameTimer(_timeLeft);

      if (_timeLeft <= 0) {
        timer.cancel();
        _endGame();
      }
    });

    print("🚀 Level $_currentLevel Started!");
  }

  Future<void> _loadRodForLevel(int level) async {
  final config = _rodConfigs[level] ?? _rodConfigs[1]!; // fallback to lvl1

  _rodSuccessChance = config["chance"];

  // If rod already exists, remove it
  _rod?.removeFromParent();

  // Create new rod sprite
  _rod = SpriteComponent(
    sprite: await loadSprite(config["sprite"]),
    size: Vector2(90, 80),
    anchor: Anchor.center,
    position: Vector2(-145, 71),
    angle: -0.8,
  );

  _world.add(_rod!);
}


}
