import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NextLevelMenu extends StatelessWidget {
  final VoidCallback onNext;

  const NextLevelMenu({Key? key, required this.onNext}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black87,
          border: Border.all(color: Colors.white, width: 3),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "LEVEL COMPLETE!",
              style: GoogleFonts.pressStart2p(
                textStyle: const TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 18,
                ),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: onNext,
              child: Text(
                "NEXT LEVEL",
                style: GoogleFonts.pressStart2p(
                  textStyle: const TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
