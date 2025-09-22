import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'cat_fish.dart';
import 'package:flame/flame.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final game = CatFish();

  await Flame.device.fullScreen();
  await Flame.device.setLandscape();

  runApp(
    GameWidget(
      game: game,
    ),
  );
}
