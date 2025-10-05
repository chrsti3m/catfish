    import 'package:flutter/material.dart';
    import '../cat_fish.dart';
    import 'package:google_fonts/google_fonts.dart';

    class StartMenu extends StatelessWidget {
    final CatFish game;
    const StartMenu({super.key, required this.game});

    @override
    Widget build(BuildContext context) {
        return Container(
        color: Colors.black.withOpacity(0.8),
        child: Center(
            child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.grey[900],
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: const [
                BoxShadow(color: Colors.green, blurRadius: 8, spreadRadius: 2),
                ],
            ),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                Text(
                    " Start Fishing ",
                    style: GoogleFonts.pressStart2p(
                    color: Colors.greenAccent,
                    fontSize: 16,
                    ),
                ),
                const SizedBox(height: 20),
                                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[800],
                        foregroundColor: Colors.white,
                        shadowColor: Colors.greenAccent,
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0), // Square corners for pixelated look
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: () {
                        game.overlays.remove('StartMenu');
                        game.startGame();
                    },
                    child: Text(
                        "Start",
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
