import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../cat_fish.dart';

class LevelIntroOverlay extends StatelessWidget {
  final CatFish game;
  final int level;
  final bool isResetMode;

  const LevelIntroOverlay({super.key, required this.game, required this.level, required this.isResetMode});

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

          // Close Button (top-right corner over container, not dialog)
          Positioned(
            top: 19,
            right: 15,
            child: GestureDetector(
              onTap: () {
                game.overlays.remove('LevelIntroOverlay');
                if (isResetMode) {
                  game.resumeGame();
                } else {
                  game.startLevelAfterIntro();
                }
              },
              child: SizedBox(
                width: 32,
                height: 32,
                child: Image.asset('assets/images/xbutton.png', fit: BoxFit.contain, filterQuality: FilterQuality.none),
              ),
            ),
          ),

          // 📜 content
          // 📜 content
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 30,
              vertical: 35,
            ), // 🔧 reduced vertical padding
            child:  Column(
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
    const SizedBox(height: 8),

    // 🎣 Dynamic Rod Message
    Text(
      level == 1
          ? "🎣 You obtained your first fishing rod!"
          : "🎣 You obtained a new upgraded rod!",
      textAlign: TextAlign.center,
      style: GoogleFonts.pressStart2p(
        fontSize: 8,
        height: 1.4,
        color: const Color(0xFF4A2E16),
      ),
    ),

    const SizedBox(height: 6),

    // 🎣 Rod Preview Section (reduced size)
    Stack(
      alignment: Alignment.center,
      children: [
        Image.asset(
          'assets/images/RC.png',
          width: 160, // ⬅️ reduced from 200
          height: 120, // ⬅️ reduced from 160
          fit: BoxFit.contain,
          filterQuality: FilterQuality.none,
        ),
        Image.asset(
          'assets/images/$rodSprite',
          width: 90, // ⬅️ reduced from 120
          fit: BoxFit.contain,
          filterQuality: FilterQuality.none,
        ),
      ],
    ),

    const SizedBox(height: 4),

    // 🏷️ Label under the rod
    Text(
      "Level $level Rod",
      style: GoogleFonts.pressStart2p(
        fontSize: 9,
        color: const Color(0xFF4A2E16),
      ),
    ),

    const SizedBox(height: 6),

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
    Text(
      "Target: ${game.levelGoals[level] ?? 0} kg",
      style: GoogleFonts.pressStart2p(
        fontSize: 8,
        color: const Color(0xFF4A2E16),
      ),
    ),

    const SizedBox(height: 10),

    // 🟤 Start Level Button
    ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF8B5E3C),
        padding: const EdgeInsets.symmetric(
          horizontal: 35,
          vertical: 10,
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
        if (isResetMode) {
          game.restartGameToLevel1();
          // overlays logic inside restartGameToLevel1, no need to duplicate
        } else {
          game.overlays.remove('LevelIntroOverlay');
          game.startLevelAfterIntro();
        }
      },
      child: Text(
        isResetMode ? "RESET GAME" : "START LEVEL",
        style: GoogleFonts.pressStart2p(
          fontSize: 10,
          color: const Color(0xFFFFEBD2),
        ),
      ),
    ),
  ],
)

            ),
        ],
      ),
    );
  }
}
