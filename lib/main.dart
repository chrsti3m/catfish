import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'cat_fish.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final game = CatFish();
  runApp(
    GameWidget(
      game: game,
    ),
  );
}