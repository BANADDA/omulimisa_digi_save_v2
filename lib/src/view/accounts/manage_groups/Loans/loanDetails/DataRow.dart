import 'package:flutter/material.dart';

class CustomDataRow extends StatelessWidget {
  final String title;
  final String value;
  final Color valueColor;

  const CustomDataRow({super.key, 
    required this.title,
    required this.value,
    this.valueColor = Colors.black, // You can provide a default color
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, // Updated this line
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color.fromARGB(255, 1, 32, 1),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
