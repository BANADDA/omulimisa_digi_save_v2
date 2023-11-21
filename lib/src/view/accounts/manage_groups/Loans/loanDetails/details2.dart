import 'package:flutter/material.dart';

import 'custom_payment.dart';

class SecondScreen extends StatefulWidget {
  final Map<String, dynamic> loanApplicationDetails;
  final Map<String, dynamic> paymentInfo;
  const SecondScreen(
      {super.key,
      required this.loanApplicationDetails,
      required this.paymentInfo});

  @override
  State<SecondScreen> createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              Container(
                child: ListTile(
                    title: Flexible(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Loan Payments',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 0, 43, 2),
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              'View and manage loan payments made by ${widget.loanApplicationDetails['loan_applicant']}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color.fromARGB(255, 1, 32, 1),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                )),
              ),
              const Divider(),
              const SizedBox(
                height: 20,
              ),
              const CustomWidget(
                title1: 'Date',
                value1: 'Wednesday, June 23rd, 2023',
                title2: 'Amount Paid',
                value2: 'UGX 5000',
              ),
              const Divider(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: const Text('Add Payment'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
