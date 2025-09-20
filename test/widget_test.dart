import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:cat_fish/cat_fish.dart';

void main() {
  testWidgets('CatFish game loads', (WidgetTester tester) async {
    await tester.pumpWidget(GameWidget(game: CatFish()));
    expect(find.byType(GameWidget), findsOneWidget);
  });
}