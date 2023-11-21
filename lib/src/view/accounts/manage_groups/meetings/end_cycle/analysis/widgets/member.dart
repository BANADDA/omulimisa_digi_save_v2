import 'package:flutter/material.dart';

class UserProfileContainer extends StatelessWidget {
  // final String imageUrl;
  // Uint8List bytesImage;
  final String personName;
  final double totalSavings;
  final double sharesOwned;

  const UserProfileContainer({super.key, 
    // required this.imageUrl,
    // required this.bytesImage,
    required this.personName,
    required this.totalSavings,
    required this.sharesOwned,
  });

  String formatCurrency(double amount, String currencySymbol) {
    // Use the toFixed method to round the number to 2 decimal places.
    String formattedAmount = amount.toStringAsFixed(2);

    // Add commas as thousand separators.
    final parts = formattedAmount.split('.');
    final wholePart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );

    // Combine the whole part and decimal part, and add the currency symbol.
    formattedAmount = '$currencySymbol $wholePart.${parts[1]}';

    return formattedAmount;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.grey.withOpacity(0.5),
        //     spreadRadius: 2,
        //     blurRadius: 5,
        //     offset: Offset(0, 3),
        //   ),
        // ],
        border: Border(
            bottom: BorderSide(
                width: 1.0,
                color: const Color.fromARGB(255, 109, 107, 107)
                    .withOpacity(0.5))), // Add this line
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // CircleAvatar(
          //   radius: 20,
          //   backgroundImage:
          //       MemoryImage(bytesImage), // Use MemoryImage to display Uint8List
          // ),
          // SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                personName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Shares Owned: ',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$sharesOwned',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color.fromARGB(255, 0, 160, 5)),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Savings: ',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    formatCurrency(totalSavings * 2000, 'UGX'),
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color.fromARGB(255, 0, 160, 5)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
