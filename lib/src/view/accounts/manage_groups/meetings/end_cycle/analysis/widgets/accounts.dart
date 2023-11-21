import 'package:flutter/material.dart';

class Accounts extends StatelessWidget {
  final String leftText;
  final String rightText;
  final Color leftTextColor;
  final Color rightTextColor;

  const Accounts({super.key, 
    required this.leftText,
    required this.rightText,
    this.leftTextColor = const Color.fromARGB(255, 105, 104, 104),
    this.rightTextColor = const Color.fromARGB(255, 0, 128, 4),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(
          leftText,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: leftTextColor,
          ),
        ),
        Text(
          rightText,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: rightTextColor,
          ),
        ),
      ],
    );
  }
}
