import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/colors.dart';

class AnalyticsWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String amount;
  final IconData? iconData;
  final Widget? customIcon;

  const AnalyticsWidget({super.key, 
    required this.title,
    required this.subtitle,
    required this.amount,
    this.iconData, // Optional IconData
    this.customIcon, // Optional custom icon
  });

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Container(
      margin: const EdgeInsets.only(top: 10, left: 20, right: 20),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 221, 245, 222),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: grey.withOpacity(0.03),
            spreadRadius: 10,
            blurRadius: 3,
          ),
        ],
      ),
      child: Padding(
        padding:
            const EdgeInsets.only(top: 10, bottom: 10, right: 10, left: 10),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: arrowbgColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: iconData != null // Check if IconData is provided
                    ? Icon(iconData)
                    : customIcon, // Use custom icon if provided
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                width: (size.width - 90) * 0.7,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        color: black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: black.withOpacity(0.5),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      amount,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: Color.fromARGB(255, 0, 128, 4)),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
