import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../cat_fish.dart';

class FishRainModal extends StatelessWidget {
  final CatFish game;
  const FishRainModal({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 🟫 Background image
          Image.asset(
            'assets/images/container.png',
            width: 420,
            height: 340,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.none,
          ),

          // 📦 Modal content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🐱 Cat image — centered and slightly smaller
                Image.asset(
                  'assets/images/LAS.gif',
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.none,
                ),

                const SizedBox(height: 24),

                // 🎉 Title
                Text(
                  'CONGRATULATIONS!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.pressStart2p(
                    fontSize: 12,
                    color: const Color(0xFF5B3C1A),
                    height: 1.5,
                    shadows: [
                      Shadow(
                        color: Colors.white.withOpacity(0.6),
                        offset: const Offset(1, 1),
                        blurRadius: 1,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // 🏆 Subtext
                Text(
                  'You’ve completed all levels!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.pressStart2p(
                    fontSize: 8,
                    color: const Color(0xFF5B3C1A),
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 28),

                // 🕹 Play Again button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5E3C),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 45,
                      vertical: 14,
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
                    game.overlays.remove('FishRainModal');
                    game.restartGameToLevel1();
                  },
                  child: Text(
                    'PLAY AGAIN',
                    style: GoogleFonts.pressStart2p(
                      fontSize: 10,
                      color: const Color(0xFFFFEBD2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
