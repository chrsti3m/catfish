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
          Image.asset(
            'assets/images/container.png',
            width: 410,
            height: 320,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.none,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/LAS.gif',
                  width: 150,
                  height: 120,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.none,
                ),
                const SizedBox(height: 36),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5E3C),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 35,
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
                      fontSize: 14,
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
