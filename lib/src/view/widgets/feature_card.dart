import 'package:flutter/material.dart';

import 'custom/dimensions.dart';
import 'custom/styles.dart';

class FeatureCard extends StatelessWidget {
  final String image;
  final String title;
  final Function onPress; // Function to be executed when the card is tapped

  const FeatureCard({
    super.key,
    required this.image,
    required this.title,
    required this.onPress, // Add this line
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Execute the onPress function when the card is tapped
        onPress();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Container(
          width: MediaQuery.of(context).size.width * .4,
          padding: const EdgeInsets.all(Dimensions.PADDING_SIZE_DEFAULT + 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: const Color.fromARGB(255, 214, 240, 206),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(255, 191, 247, 208).withOpacity(0.08),
                spreadRadius: 1,
                blurRadius: 1,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Image.asset(
                  image,
                  height: MediaQuery.of(context).size.height * .10,
                  width: MediaQuery.of(context).size.width * .10,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * .01,
              ),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: urbanistRegular.copyWith(
                    fontSize: 14,
                    color: Colors.black,
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
