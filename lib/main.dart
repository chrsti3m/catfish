import 'package:flutter/material.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'cat_fish.dart';
import 'overlays/start_menu.dart';
import 'overlays/fail_menu.dart';
import 'overlays/next_level_menu.dart';
import 'overlays/level_intro_overlay.dart';
import 'overlays/fish_rain_modal.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final game = CatFish();

  await Flame.device.fullScreen();
  await Flame.device.setLandscape();

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: 1024,
              height: 421,
              child: GameWidget(
                game: game,
              overlayBuilderMap: {
                'StartMenu': (BuildContext context, CatFish game) => StartMenu(game: game),
                'FailMenu': (BuildContext context, CatFish game) => FailMenu(game: game),
                'LevelIntroOverlay': (BuildContext context, CatFish game) =>
                    LevelIntroOverlay(game: game, level: game.currentLevel),
                'NextLevelMenu': (BuildContext context, CatFish game) =>
                    NextLevelMenu(game: game),
                'FishRainModal': (BuildContext context, CatFish game) => FishRainModal(game: game),
              },

                initialActiveOverlays: const ['StartMenu'],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
