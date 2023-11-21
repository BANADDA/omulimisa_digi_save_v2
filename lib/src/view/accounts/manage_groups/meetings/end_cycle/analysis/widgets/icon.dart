import 'package:flutter/material.dart';

class CustomDonationIcon extends StatelessWidget {
  final String imageAssetPath;

  const CustomDonationIcon({super.key, required this.imageAssetPath});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Icon(
          Icons.image,
          size: 20, // Adjust the size as needed
          color: Colors.white,
          semanticLabel: 'Custom Donation Icon',
        ),
        Positioned(
          top: 0,
          left: 0,
          child: Image.asset(
            imageAssetPath, // Use the provided image asset path
            width: 20,
            height: 20,
          ),
        ),
      ],
    );
  }
}
