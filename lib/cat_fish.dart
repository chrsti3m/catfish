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
import 'package:flame_audio/flame_audio.dart';
import 'package:flame/effects.dart';


class CatFish extends FlameGame with HasCollisionDetection {
  late final World _world;
  late final CameraComponent _camera;
  BobberComponent? _currentBobber;
  HudComponent? _hud;
  ShadowComponent? _persistentShadow;
  ShadowComponent? _bonusShadow; //  Extra high-chance shadow

  SpriteComponent? _rod; // ✅ keep rod as a field

  // Game state
  int _currentLevel = 1;
  int get currentLevel => _currentLevel;
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
  Map<int, int> get levelGoals => _levelGoals;

  // Getter → always gives the right target for the current level
  int get _levelGoal => _levelGoals[_currentLevel] ?? 10;

  // 🎣 Rod configurations: defines sprite, success chance, and fish weight range per level
  final Map<int, Map<String, dynamic>> _rodConfigs = {
    1: {
      "sprite": "ROD1.png",
      "chance": 0.50,
      "minW": 1,
      "maxW": 3,
      "speedMultiplier": 1.2,
    },
    2: {
      "sprite": "ROD2.png",
      "chance": 0.60,
      "minW": 1,
      "maxW": 4,
      "speedMultiplier": 1.1,
    },
    3: {
      "sprite": "ROD3.png",
      "chance": 0.70,
      "minW": 2,
      "maxW": 4,
      "speedMultiplier": 1.0,
    },
    4: {
      "sprite": "ROD5.png",
      "chance": 0.75,
      "minW": 3,
      "maxW": 5,
      "speedMultiplier": 0.9,
    },
    5: {
      "sprite": "ROD4.png",
      "chance": 0.80,
      "minW": 3,
      "maxW": 5,
      "speedMultiplier": 0.8,
    },
  };
  Map<int, Map<String, dynamic>> get rodConfigs => _rodConfigs;

  // Timer & Game state
  async.Timer? _countdownTimer;
  int _timeLeft = 60;
  bool _isGameRunning = false;
  bool _audioInitialized = false;

    


  bool get isGameRunning => _isGameRunning;

void pauseGameForOverlay() {
  if (!_isGameRunning) return;

  _countdownTimer?.cancel();
  _isGameRunning = false;

  overlays.add('LevelIntroOverlay');
  print("⏸️ Game paused, showing overlay");
}

void resumeGame() {
  if (_isGameRunning) return;

  _isGameRunning = true;

  _countdownTimer = async.Timer.periodic(const Duration(seconds: 1), (timer) {
    _timeLeft--;
    _hud?.updateGameTimer(_timeLeft);
    if (_timeLeft <= 0) {
      timer.cancel();
      _endGame();
    }
  });

  print("▶️ Game resumed");
}

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Preload font
    await GoogleFonts.pendingFonts([GoogleFonts.pressStart2p()]);

    // Preload audio clips
    await FlameAudio.audioCache.loadAll([
      'bloop.wav',
      'splash.wav',
      'BGMM.mp3',
    ]);

    // Initialize background music but don't play yet (web browsers require user interaction)
    FlameAudio.bgm.initialize();

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
    await _createBonusShadow(); //  Lucky shadow

    // HUD
    _hud = HudComponent();
    _world.add(_hud!);

  


    // ✅ Show Start overlay at beginning
    overlays.add('StartMenu');
  }
  // 🐟 Fish rain state tracking
  final List<async.Timer> _fishRainTimers = [];
  bool _isFishRainActive = false;
  

  @override
  void onRemove() {
    // Stop background music when game is disposed
    FlameAudio.bgm.stop();
    super.onRemove();
  }

  // Note: Game pause/resume hooks differ per platform; remove unsupported overrides.

  void startGame() {
    // Initialize audio on first user interaction (required for web browsers)
    _initializeAudioIfNeeded();

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

  // ✅ Initialize audio on first user interaction (required for web browsers)
  void _initializeAudioIfNeeded() {
    if (!_audioInitialized) {
      _audioInitialized = true;
      // Start background music after user interaction
      FlameAudio.bgm.play('BGMM.mp3', volume: 0.15);
    }
  }

  Future<void> _createPersistentShadow() async {
    _persistentShadow = ShadowComponent(
      sprite: await loadSprite('shadow.png'),
      size: Vector2(100, 45),
      position: Vector2(150, 150),
      onTap: (tapPosition, shadowComponent) =>
          _onShadowTapped(tapPosition, shadowComponent),
    );
    _world.add(_persistentShadow!);
  }

  //bonus shadow
  Future<void> _createBonusShadow() async {
    _bonusShadow = ShadowComponent(
      sprite: await loadSprite(
        'shadow.png',
      ), // You can use a different sprite later
      size: Vector2(100, 45),
      position: Vector2(
        50,
        200,
      ), //  Move to a different position than main shadow
      onTap: (tapPosition, shadow) => _onBonusShadowTapped(tapPosition, shadow),
    );
    _world.add(_bonusShadow!);
  }

  void _onShadowTapped(Vector2 tapPosition, ShadowComponent shadow) {
    // Initialize audio on first user interaction (required for web browsers)
    _initializeAudioIfNeeded();

    if (!_isGameRunning) return;
    if (_isBobberActive) {
      print("⏳ Wait for the current bobber to finish!");
      return;
    }

    _isBobberActive = true;
    _currentBobber?.removeFromParent();

    // Play bloop sound when casting on a shadow
    FlameAudio.play('bloop.wav');

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
        // Move BOTH shadows after bobber disappears
        moveBothShadowsToNonOverlappingPositions();
      },
      onTap: _attemptCatch,
    );
    _world.add(_currentBobber!);

    // ✅ Change rod pose when bobber is active
    _rod?.position = Vector2(-135, 78);
    _rod?.angle = -0.3;
  }

  void _onBonusShadowTapped(Vector2 tapPosition, ShadowComponent shadow) {
    _initializeAudioIfNeeded();

    if (!_isGameRunning) return;
    if (_isBobberActive) return;

    _isBobberActive = true;
    _currentBobber?.removeFromParent();

    FlameAudio.play('bloop.wav');

    _currentBobber = BobberComponent(
      position: shadow.position,
      onWriggleEnd: () {
        _currentBobber = null;
        _isBobberActive = false;
        _rod?.position = Vector2(-145, 71);
        _rod?.angle = -0.8;
        _bonusShadow?.showFeedback(false);
        // Move BOTH shadows after bobber disappears
        moveBothShadowsToNonOverlappingPositions();
      },
      onTap: (success) => _attemptCatchBonus(success),
    );
    _world.add(_currentBobber!);

    _rod?.position = Vector2(-135, 78);
    _rod?.angle = -0.3;
  }

  // Helper - get random position for shadows in the lake, after the boat
  Vector2 getRandomShadowLakePosition() {
    // Updated bounds from user:
    double minX = -90, maxX = 450, minY = 80, maxY = 200;
    return Vector2(
      minX + _random.nextDouble() * (maxX - minX),
      minY + _random.nextDouble() * (maxY - minY),
    );
  }
  void moveShadowToNewLakePosition(ShadowComponent? shadow) {
    if (shadow == null) return;
    shadow.position = getRandomShadowLakePosition();
  }

  void moveBothShadowsToNonOverlappingPositions() {
    if (_persistentShadow == null || _bonusShadow == null) return;
    final double minDistance = ((_persistentShadow?.size.x ?? 60) / 2) + ((_bonusShadow?.size.x ?? 60) / 2) + 20; // pixel gap
    Vector2 first = getRandomShadowLakePosition();
    Vector2 second;
    int attempts = 0;
    do {
      second = getRandomShadowLakePosition();
      attempts++;
    } while (first.distanceTo(second) < minDistance && attempts < 30);
    _persistentShadow!.position = first;
    _bonusShadow!.position = second;
  }

  void _attemptCatch(bool success) {
    if (!_isGameRunning || _currentBobber == null) return;

    // If tap was too early
    if (!success) {
      print("Too early! The fish hasn’t bitten yet!");
      _persistentShadow?.showFeedback(false);
      _currentBobber?.removeFromParent();
      _currentBobber = null;
      _isBobberActive = false;
      // Move BOTH shadows even if failed
      moveBothShadowsToNonOverlappingPositions();
      return;
    }

    // ✅ Attempting to catch a fish
    print("Attempting to catch fish...");
    _currentBobber?.removeFromParent();
    _currentBobber = null;
    _isBobberActive = false;

    // Reset rod
    _rod?.position = Vector2(-145, 71);
    _rod?.angle = -0.8;

    // Catch logic
    if (_random.nextDouble() < _rodSuccessChance) {
      final fishWeight = _generateFishWeight();
      _playerWeight += fishWeight;
      if (_playerWeight > _levelGoal) _playerWeight = _levelGoal;

      _hud?.updatePlayerWeight(_playerWeight, _levelGoal);
      _hud?.updateFillProgress(_playerWeight / _levelGoal);

      print(
        "SUCCESS! Caught a fish! Weight: ${fishWeight}kg. Total: ${_playerWeight}kg",
      );
      _persistentShadow?.showFeedback(true, fishWeight.toDouble());

      if (_playerWeight >= _levelGoal) {
        _countdownTimer?.cancel();
        _isGameRunning = false;

        if (_currentLevel == 5) {
          // Automatically trigger fish rain for level 5
          _triggerFishRainCelebrationLoop();
        } else {
          overlays.add('NextLevelMenu');
          overlays.remove('LevelIntroOverlay');
        }
      }
    } else {
      print("FAILED! The fish got away!");
      _persistentShadow?.showFeedback(false);
    }
    // Move BOTH shadows after bobber disappears, regardless of success
    moveBothShadowsToNonOverlappingPositions();
  }

  void _attemptCatchBonus(bool success) {
    if (!_isGameRunning || _currentBobber == null) return;

    if (!success) {
      _bonusShadow?.showFeedback(false);
      _currentBobber?.removeFromParent();
      _currentBobber = null;
      _isBobberActive = false;
      // Move BOTH shadows even if failed
      moveBothShadowsToNonOverlappingPositions();
      return;
    }

    _currentBobber?.removeFromParent();
    _currentBobber = null;
    _isBobberActive = false;

    _rod?.position = Vector2(-145, 71);
    _rod?.angle = -0.8;

    // 🎯 Give this shadow higher catch success chance
    double bonusChance = _rodSuccessChance + 0.25; // +25% higher success chance
    if (bonusChance > 0.95) bonusChance = 0.95; // cap at 95%

    if (_random.nextDouble() < bonusChance) {
      final fishWeight = _generateFishWeight();
      _playerWeight += fishWeight;
      if (_playerWeight > _levelGoal) _playerWeight = _levelGoal;

      _hud?.updatePlayerWeight(_playerWeight, _levelGoal);
      _hud?.updateFillProgress(_playerWeight / _levelGoal);

      _bonusShadow?.showFeedback(true, fishWeight.toDouble());

      if (_playerWeight >= _levelGoal) {
        _countdownTimer?.cancel();
        _isGameRunning = false;

        if (_currentLevel == 5) {
          // Automatically trigger fish rain for level 5
          _triggerFishRainCelebrationLoop();
        } else {
          overlays.add('NextLevelMenu');
          overlays.remove('LevelIntroOverlay');
        }
      }
    } else {
      _bonusShadow?.showFeedback(false);
    }
    // Move BOTH shadows after bobber disappears, regardless of success
    moveBothShadowsToNonOverlappingPositions();
  }

  /// ✅ Fish weight generation balanced for Level 1 rod (50% success rate).
  /// 65% chance → 1kg, 25% → 2kg, 10% → 3kg
  /// 🎣 Generates fish weight based on current rod level.
  /// The rod defines the possible range (min–max weight) and
  /// heavier rods tend to catch heavier fish on average.
  int _generateFishWeight() {
    final config = _rodConfigs[_currentLevel] ?? _rodConfigs[1]!;
    final min = config["minW"] as int;
    final max = config["maxW"] as int;

    // Roll between min and max
    int fishWeight = min + _random.nextInt(max - min + 1);

    // Prevent overshooting target goal
    final remainingWeight = _levelGoal - _playerWeight;
    if (fishWeight > remainingWeight) {
      fishWeight = remainingWeight;
    }

    print('🐟 Level $_currentLevel caught a fish weighing $fishWeight kg');
    return fishWeight;
  }

  Future<void> startNextLevel() async {
    _playerWeight = 0;
    _timeLeft = 60;
    _isGameRunning = false; // pause game start until overlay closes

    if (_currentLevel >= 5) {
      return;
    }

    _currentLevel++;

    await _loadRodForLevel(_currentLevel);
    _hud?.updateLevelTitle(_currentLevel);


    // Reset HUD visuals
    _hud?.updatePlayerWeight(_playerWeight, _levelGoal);
    _hud?.updateFillProgress(0.0);
    _hud?.updateGameTimer(_timeLeft);

    // Reset rod position
    _rod?.position = Vector2(-145, 71);
    _rod?.angle = -0.8;

    // Cancel any old timer
    _countdownTimer?.cancel();

    // 🪧 Show Level Intro overlay first
    overlays.add('LevelIntroOverlay');
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
    print(
      '🎣 Loaded rod for Level $level → ${config["minW"]}-${config["maxW"]} kg range, ${(_rodSuccessChance * 100).toInt()}% catch chance',
    );
  }

  void startLevelAfterIntro() {
    _isGameRunning = true;
    _timeLeft = 60;
    _initializeAudioIfNeeded();
    _countdownTimer?.cancel();
    _countdownTimer = async.Timer.periodic(const Duration(seconds: 1), (timer) {
      _timeLeft--;
      _hud?.updateGameTimer(_timeLeft);

      if (_timeLeft <= 0) {
        timer.cancel();
        _endGame();
      }
    });

    print("🚀 Level $_currentLevel officially started after intro!");
  }
  void restartCurrentLevel() async {
     _stopFishRain(); // 🧼 stop fish rain immediately
  await Future.delayed(const Duration(milliseconds: 200));
  print("🔁 Restarting Level $_currentLevel...");

  // Reset basic game state
  _playerWeight = 0;
  _timeLeft = 60;
  _isGameRunning = false;
  _isBobberActive = false;

  // Reset HUD values
  _hud?.updatePlayerWeight(_playerWeight, _levelGoal);
  _hud?.updateFillProgress(0.0);
  _hud?.updateGameTimer(_timeLeft);

  // Reset rod
  _rod?.position = Vector2(-145, 71);
  _rod?.angle = -0.8;

  // Cancel old timer
  _countdownTimer?.cancel();

  // 💡 Restart game immediately
  startGame();
}


  Future<void> _triggerFishRainCelebrationLoop() async {
  print("🎉 Level 5 reached goal! Fish rain starts looping!");
  _isFishRainActive = true;

  void spawnFish() async {
    if (!_isFishRainActive) return; // Stop spawning if reset

    final fish = SpriteComponent(
      sprite: await loadSprite('fish.png'),
      size: Vector2(50, 40),
      anchor: Anchor.center,
      position: Vector2(
        -500 + Random().nextDouble() * 1000,
        -100 - Random().nextDouble() * 300,
      ),
    );

    double fallDuration = 3 + Random().nextDouble() * 2;
    double spinSpeed = (Random().nextBool() ? 1 : -1) * (1 + Random().nextDouble());

    FlameAudio.play('splash.wav', volume: 0.2 + Random().nextDouble() * 0.2);

    fish.addAll([
      RotateEffect.by(
        spinSpeed * pi * 2,
        EffectController(duration: fallDuration),
      ),
      MoveEffect.by(
        Vector2(0, 600),
        EffectController(duration: fallDuration),
      ),
    ]);

    _world.add(fish);

    // Schedule next fish and store the timer
    final nextTimer = async.Timer(
      Duration(milliseconds: 80 + Random().nextInt(100)),
      spawnFish,
    );
    _fishRainTimers.add(nextTimer);
  }

  // Start spawning loop
  spawnFish();

  // Show Fish Rain Modal after 2 seconds
  final modalTimer = async.Timer(const Duration(seconds: 2), () {
    if (_isFishRainActive) overlays.add('FishRainModal');
  });
  _fishRainTimers.add(modalTimer);
}


void _stopFishRain() {
  print("🛑 Stopping fish rain...");
  _isFishRainActive = false;

  // Cancel all active timers immediately
  for (final timer in _fishRainTimers) {
    if (timer.isActive) timer.cancel();
  }
  _fishRainTimers.clear();

  // Immediately remove any fish components from the world
  final fishToRemove = _world.children.whereType<SpriteComponent>().where((c) {
    // Safer identification: check position or size range typical for falling fish
    return c.size.y == 40 && c.size.x == 50; // matches your fish size
  }).toList();

  for (final fish in fishToRemove) {
    fish.removeFromParent(); // immediate removal
  }

  // Remove fish rain overlay if active
  if (overlays.isActive('FishRainModal')) overlays.remove('FishRainModal');
}



  void restartGameToLevel1() async {
    _stopFishRain();
    await Future.delayed(const Duration(milliseconds: 200));
    print("🔄 Restarting whole game to Level 1");
    _currentLevel = 1;
    _hud?.updateLevelTitle(_currentLevel);
    _playerWeight = 0;
    _timeLeft = 60;
    _isGameRunning = false;
    _isBobberActive = false;
    _hud?.updatePlayerWeight(_playerWeight, _levelGoal);
    _hud?.updateFillProgress(0.0);
    _hud?.updateGameTimer(_timeLeft);
    _rod?.position = Vector2(-145, 71);
    _rod?.angle = -0.8;
    _countdownTimer?.cancel();
    overlays.clear();
    overlays.add('StartMenu');
  }
}
