import 'package:flutter/material.dart';
import 'dart:ui';

class StartCard extends StatelessWidget {
  const StartCard({
    Key? key,
    required this.theWidth,
    required this.theHeight,
    required this.theChild,
    this.borderRadius = 30.0, // Default border radius value
  }) : super(key: key);

  final double theWidth;
  final double theHeight;
  final Widget theChild;
  final double borderRadius; // Border radius parameter

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius:
          BorderRadius.circular(borderRadius), // Use the provided border radius
      child: Container(
        width: theWidth,
        height: theHeight,
        color: Colors.transparent,
        child: Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 4.0,
                sigmaY: 4.0,
              ),
              child: Container(),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                    borderRadius), // Use the provided border radius
                border: Border.all(color: Colors.white.withOpacity(0.15)),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.07),
                    Colors.white.withOpacity(0.00),
                  ],
                ),
              ),
            ),
            Center(child: theChild),
          ],
        ),
      ),
    );
  }
}
