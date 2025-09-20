import 'package:flame/game.dart';
import 'package:flame/components.dart';

class CatFish extends FlameGame {
  late final World _world;
  
  @override
  Future<void> onLoad() async {
    _world = World();
    
    // Assign the built-in camera
    final camera = CameraComponent.withFixedResolution(
      world: _world,
      width: 1170,
      height: 865,
    );
    add(camera);

    try {
      // Load background
      final background = SpriteComponent(
        sprite: await loadSprite('assets/images/background.png'),
        size: Vector2(1170, 865),
        anchor: Anchor.topLeft,
        position: Vector2.zero(),
      );

      // Load character
      final character = SpriteComponent(
        sprite: await loadSprite('assets/images/cat.png'),
        size: Vector2(100, 100),
        anchor: Anchor.center,
        position: Vector2(1170 / 2, 865 / 2),
      );

      // Add components to the world
      _world.add(background);
      _world.add(character);
    } catch (e) {
      print('Error loading assets: $e');
      rethrow;
    }
  }
}