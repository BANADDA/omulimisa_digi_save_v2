import 'package:flutter/material.dart';

class CustomListTileWithAmountAndIcon extends StatelessWidget {
  final String text;
  final String amount;
  final Color amountColor;
  final IconData icon;
  final Color iconColor;

  const CustomListTileWithAmountAndIcon({super.key, 
    required this.text,
    required this.amount,
    required this.amountColor,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 226, 247, 227),
        border: Border.all(
          color: const Color.fromARGB(255, 226, 247, 227),
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      child: ListTile(
        title: Row(
          children: [
            Icon(
              icon,
              color: iconColor,
              size: 40,
            ),
            const SizedBox(width: 35),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  amount,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: amountColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
