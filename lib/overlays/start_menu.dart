import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../cat_fish.dart';
import 'package:google_fonts/google_fonts.dart';

class StartMenu extends StatelessWidget {
  final CatFish game;
  const StartMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    // 1. Full-screen transparent overlay
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double availableHeight = constraints.maxHeight; // ~421
          // Keep the logo at ~55% of available height and button around ~10%.
          final double logoMaxHeight = availableHeight * 0.55;
          final double buttonHeight = availableHeight * 0.10;
          final double buttonMaxWidth = math.min(constraints.maxWidth * 0.35, 340);
          final double fontSize = buttonHeight * 0.38; // clamp naturally small on tiny screens
          return Center(
            child: Column(
          // Center the content block vertically
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max, // Allow children to flex within available height
          children: [
            // 2. Catfish Logo Image
            SizedBox(
              height: logoMaxHeight,
              child: Image.asset(
                // **Use the confirmed path based on your pubspec.yaml**
                'assets/images/LOGO.png',
                fit: BoxFit.contain,
                // CRUCIAL: Set filterQuality to 'none' to maintain the crisp pixel art look
                filterQuality: FilterQuality.none,
              ),
            ),

            const SizedBox(height: 20), // Space between logo and button

            // 3. Start Button - wooden plank style to match the logo
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
                    game.startGame();
                  },
                  splashColor: const Color(0xFF3E2414).withOpacity(0.15),
                  highlightColor: Colors.transparent,
                  child: Ink(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    decoration: BoxDecoration(
                      // Vertical wood-like gradient
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFFB07A3E), // light wood
                          Color(0xFF8B5E3C),
                          Color(0xFF6E3E1F), // dark wood
                        ],
                        stops: [0.0, 0.55, 1.0],
                      ),
                      border: Border.all(
                        color: const Color(0xFF3E2414),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.6),
                          offset: const Offset(0, 6),
                          blurRadius: 0,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Removed inner highlight/shadow stripes to avoid a visible line behind the text
                        Text(
                          "Start Fishing",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.pressStart2p(
                            fontSize: fontSize.clamp(10, 16),
                            color: const Color(0xFFFFF4D6),
                            // Removed heavy drop shadow to avoid a bordered look on the label
                          ),
                        ),
                      ],
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