import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../cat_fish.dart';

class LevelIntroOverlay extends StatelessWidget {
  final CatFish game;
  final int level;

  const LevelIntroOverlay({super.key, required this.game, required this.level});

  @override
  Widget build(BuildContext context) {
    // get rod details from your rodConfigs
    final rodConfig = game.rodConfigs[level]!;
    final rodSprite = rodConfig['sprite'];
    final chance = (rodConfig['chance'] * 100).toInt();
    final minW = rodConfig['minW'];
    final maxW = rodConfig['maxW'];

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 🧱 container background
          Image.asset(
            'assets/images/container.png',
            width: 506,
            height: 408,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.none,
          ),

          // 📜 content
          // 📜 content
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 30,
              vertical: 35,
            ), // 🔧 reduced vertical padding
            child: SingleChildScrollView(
              // ✅ prevents overflow
              physics:
                  const NeverScrollableScrollPhysics(), // invisible scroll (no scrollbar)
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 🧭 Level Header
                  Text(
                    "LEVEL $level",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.pressStart2p(
                      fontSize: 14,
                      color: const Color(0xFF4A2E16),
                    ),
                  ),
                  const SizedBox(height: 10), // 🔧 reduced spacing
                  // 🎣 Rod Preview
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        'assets/images/RC.png',
                        width: 200,
                        height: 160, // 🔧 reduced from 180
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.none,
                      ),
                      Image.asset(
                        'assets/images/$rodSprite',
                        width: 120,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.none,
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                  Text(
                    "Level $level Rod",
                    style: GoogleFonts.pressStart2p(
                      fontSize: 8,
                      color: const Color(0xFF4A2E16),
                    ),
                  ),

                  const SizedBox(height: 8),
                  Text(
                    "Catch Chance: $chance%",
                    style: GoogleFonts.pressStart2p(
                      fontSize: 8,
                      color: const Color(0xFF4A2E16),
                    ),
                  ),
                  Text(
                    "Fish Range: $minW–$maxW kg",
                    style: GoogleFonts.pressStart2p(
                      fontSize: 8,
                      color: const Color(0xFF4A2E16),
                    ),
                  ),

                  const SizedBox(height: 15), // 🔧 slightly less spacing
                  // 🟤 Start Level Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5E3C),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                        side: const BorderSide(
                          color: Color(0xFF3E2414),
                          width: 3,
                        ),
                      ),
                    ),
                    onPressed: () {
                      game.overlays.remove(
                        'LevelIntroOverlay',
                      ); // close overlay
                      game.startLevelAfterIntro(); // ✅ start level safely
                    },
                    child: Text(
                      "START LEVEL",
                      style: GoogleFonts.pressStart2p(
                        fontSize: 10,
                        color: const Color(0xFFFFEBD2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
