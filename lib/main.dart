import 'package:flutter/material.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'cat_fish.dart';
import 'overlays/start_menu.dart';
import 'overlays/fail_menu.dart';
import 'overlays/next_level_menu.dart';

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
                'NextLevelMenu': (BuildContext context, CatFish game) => NextLevelMenu(
                      onNext: () {
                        game.overlays.remove('NextLevelMenu');
                        game.startNextLevel(); // ✅ This will be your new method in CatFish
                      },
                    ),
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
