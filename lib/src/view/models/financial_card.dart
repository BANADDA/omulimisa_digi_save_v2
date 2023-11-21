import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class FinancialCard extends StatefulWidget {
  // const FinancialCard({super.key});

  final String header;
  double formattedSavings;

  FinancialCard(
      {Key? key, required this.header, required this.formattedSavings})
      : super(key: key);

  @override
  State<FinancialCard> createState() => _FinancialCardState();
}

class _FinancialCardState extends State<FinancialCard> {
  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
        symbol: 'UGX '); // Replace 'UGX ' with your currency symbol
    final formattedSavings = currencyFormat.format(widget.formattedSavings);
    return Card(
      elevation: 8,
      shadowColor: Colors.green,
      child: Stack(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                child: Column(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 1, 67, 3),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: const Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Financial Overview',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 0.0, bottom: 10.0),
                      child: Center(
                        child: Column(
                          children: <Widget>[
                            const SizedBox(height: 30),
                            const Text(
                              "Total Savings",
                              style: TextStyle(
                                  color: Color.fromARGB(255, 0, 90, 3),
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              formattedSavings,
                              style: const TextStyle(
                                  color: Color.fromARGB(255, 0, 90, 3),
                                  fontSize: 25.0,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildFinancialItem(String label, String value) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
