import 'package:flutter/material.dart';

class ShareoutContainer extends StatelessWidget {
  final String applicantName;
  final double sharesOwned;
  final double shareValue;

  const ShareoutContainer({
    super.key,
    required this.applicantName,
    required this.sharesOwned,
    required this.shareValue,
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
    formattedAmount = '$currencySymbol $wholePart';

    return formattedAmount;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color.fromARGB(255, 235, 233, 233),
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      margin: const EdgeInsets.all(16),
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Member Name: ',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Text(
              applicantName,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color.fromARGB(255, 1, 27, 1)),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                    Text(sharesOwned.toString(),
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color.fromARGB(255, 0, 160, 5))),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Share Value: ',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(formatCurrency(shareValue, 'UGX'),
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color.fromARGB(255, 0, 160, 5))),
                  ],
                ),
              ],
            ),
            // SizedBox(
            //   height: 15,
            // ),
          ],
        ),
      ),
    );
  }
}
