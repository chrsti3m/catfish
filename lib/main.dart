import 'package:flutter/material.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'cat_fish.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final game = CatFish();

  // optional for mobile, harmless on web
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();

  runApp(
    MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: FittedBox(
            fit: BoxFit.contain, // preserves aspect ratio and centers
            child: SizedBox(
              width: 1024, // logical size = your background resolution
              height: 421,
              child: GameWidget(game: game),
            ),
          ),
        ),
      ),
    ),
  );
}
