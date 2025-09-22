import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/camera.dart'; // safe to include
import 'package:flame/extensions.dart';

class CatFish extends FlameGame {
  late final World _world;
  late final CameraComponent _camera;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _world = World();
    add(_world);

    // Create a camera with fixed logical resolution equal to your bg
    _camera = CameraComponent.withFixedResolution(
      world: _world,
      width: 1024,
      height: 421,
    );
    // center the viewfinder so (0,0) is centered in the viewport
    _camera.viewfinder.anchor = Anchor.center;
    add(_camera);

    // Put background in the world, centered at world origin
    final bg = SpriteComponent(
      sprite: await loadSprite('BACKGROUND.png'),
      size: Vector2(1024, 421),
      anchor: Anchor.center,
      position: Vector2.zero(), // world origin
    );
    _world.add(bg);

    // Character example (centered)
    final character = SpriteComponent(
      sprite: await loadSprite('cat.png'),
      size: Vector2(70, 40),
      anchor: Anchor.center,
      position: Vector2(-205, 90), // in center of world
    );
    _world.add(character);
  }
}