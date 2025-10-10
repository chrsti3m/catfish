import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../cat_fish.dart';
import 'package:google_fonts/google_fonts.dart';

class StartMenu extends StatelessWidget {
  final CatFish game;
  const StartMenu({super.key, required this.game});

  void _showHowToPlayModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true, // tap outside to close
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Stack(
  alignment: Alignment.center,
  children: [
    // 🧱 Background
    Image.asset(
      'assets/images/container.png',
      fit: BoxFit.contain,
      filterQuality: FilterQuality.none,
    ),

    // 📜 Text content (centered inside)
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 350),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 5),
            Text(
              "HOW TO PLAY",
              textAlign: TextAlign.center,
              style: GoogleFonts.pressStart2p(
                fontSize: 14,
                color: Color(0xFF4A2E16),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "🎯 Goal:\n"
              "Catch enough fish to reach the target weight before time runs out.\n\n"
              "🎮 Controls:\n"
              "1️. Tap a SHADOW in the water to cast your line.\n"
              "2️. Wait for the BOBBER to shake — that means a fish is biting!\n"
              "3️. Tap the bobber quickly before the bobber timer runs out to catch it.\n\n"
              "💡 Tips:\n"
              "• Each fish adds to your total weight shown in the Progress Bar.\n"
              "• Each new level upgrades your ROD — increasing catch chance and fish size.\n"
              "• Timing matters: Tap too early and the fish escapes!\n\n"
              "⚙️ Keep fishing, level up your rod, and become the ultimate Cat Fisher!",
              textAlign: TextAlign.center,
              style: GoogleFonts.pressStart2p(
                fontSize: 8,
                height: 1.6,
                color: Color(0xFF4A2E16),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    ),

    // 🎯 Button overlayed near bottom of container
    Positioned(
      bottom: 40, // adjust to align with brown plank edge
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8B5E3C),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: const BorderSide(color: Color(0xFF3E2414), width: 3),
          ),
        ),
        onPressed: () => Navigator.of(context).pop(),
        child: Text(
          "GOT IT",
          style: GoogleFonts.pressStart2p(
            fontSize: 10,
            color: const Color(0xFFFFEBD2),
          ),
        ),
      ),
    ),
  ],
),

        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF2FA357),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double availableHeight = constraints.maxHeight;
          final double logoMaxHeight = availableHeight * 0.55;
          final double buttonHeight = availableHeight * 0.10;
          final double buttonMaxWidth = math.min(
            constraints.maxWidth * 0.35,
            340,
          );
          final double fontSize = buttonHeight * 0.38;

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🐟 Logo
                SizedBox(
                  height: logoMaxHeight,
                  child: Image.asset(
                    'assets/images/LOGO.png',
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.none,
                  ),
                ),
                const SizedBox(height: 20),

                // 🎣 Start Fishing Button
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: buttonMaxWidth,
                    minHeight: buttonHeight,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        game.overlays.remove('StartMenu');

                        // 🆕 Show level intro overlay instead of starting immediately
                        game.overlays.add('LevelIntroOverlay');
                      },

                      splashColor: const Color(0xFF3E2414).withOpacity(0.15),
                      highlightColor: Colors.transparent,
                      child: Ink(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFFB07A3E),
                              Color(0xFF8B5E3C),
                              Color(0xFF6E3E1F),
                            ],
                          ),
                          border: Border.all(
                            color: Color(0xFF3E2414),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.6),
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            "START FISHING",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.pressStart2p(
                              fontSize: fontSize.clamp(10, 16),
                              color: const Color(0xFFFFF4D6),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 🟤 HOW TO PLAY Button
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: buttonMaxWidth * 0.8,
                    minHeight: buttonHeight * 0.8,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _showHowToPlayModal(context),
                      splashColor: const Color(0xFF3E2414).withOpacity(0.15),
                      highlightColor: Colors.transparent,
                      child: Ink(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFFB07A3E),
                              Color(0xFF8B5E3C),
                              Color(0xFF6E3E1F),
                            ],
                          ),
                          border: Border.all(
                            color: Color(0xFF3E2414),
                            width: 3,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            "HOW TO PLAY",
                            style: GoogleFonts.pressStart2p(
                              fontSize: fontSize.clamp(8, 12),
                              color: const Color(0xFFFFF4D6),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
