import 'package:flutter/material.dart';
import '../cat_fish.dart';
import 'package:google_fonts/google_fonts.dart';

class FailMenu extends StatelessWidget {
  final CatFish game;
  const FailMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.9),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red[900],
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    Text(
        " time's up ",
        style: GoogleFonts.pressStart2p(
        color: Colors.red,
        fontSize: 16,
        ),
    ),
    const SizedBox(height: 20),
        ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red[800],
        foregroundColor: Colors.white,
        shadowColor: Colors.redAccent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0), // Square corners for pixelated look
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      onPressed: () {
        game.overlays.remove('FailMenu');
        game.overlays.add('StartMenu');
      },
      child: Text(
        "Try Again",
        style: GoogleFonts.pressStart2p(
          fontSize: 14,
          color: Colors.white,
        ),
      ),
    ),
  ],
),
        ),
      ),
    );
  }
}
