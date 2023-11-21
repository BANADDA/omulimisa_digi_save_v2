import 'package:flutter/material.dart';

class ImageCard extends StatelessWidget {
  final String imageUrl;
  final int index;

  const ImageCard({super.key, required this.imageUrl, required this.index});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          elevation: 4,
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 200,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 8),
              Text('Card ${index + 1}'),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
