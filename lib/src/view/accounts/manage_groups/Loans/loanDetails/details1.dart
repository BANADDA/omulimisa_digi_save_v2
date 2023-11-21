import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '/database/localStorage.dart';

import 'DataRow.dart';

class FirstScreen extends StatefulWidget {
  final Map<String, dynamic> loanApplicationDetails;
  final Map<String, dynamic> paymentInfo;
  const FirstScreen(
      {super.key,
      required this.loanApplicationDetails,
      required this.paymentInfo});

  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  double interest = 0.0;
  @override
  void initState() {
    interest = (widget.loanApplicationDetails['loan_amount'] * 20 / 100);
    ImageData();
    getImageForMember();
    super.initState();
  }

  double calculateAmountCleared(Map<String, dynamic> paymentInfo) {
    // Calculate the total payment amount from payment information.
    if (paymentInfo['payment_amount'] != null) {
      return paymentInfo['payment_amount'];
    } else {
      return 0.0; // If payment information is not available or payment_amount is null.
    }
  }

  double calculateLoanBalance(Map<String, dynamic> loanApplicationDetails,
      Map<String, dynamic> paymentInfo) {
    // Calculate the loan balance based on loan taken and total payment amount.
    double loanTaken = loanApplicationDetails['loan_amount'];
    double totalPayment = calculateAmountCleared(paymentInfo);

    return loanTaken - totalPayment + interest;
  }

  int loanerId = 0;
  Uint8List? _bytesImage;
  Map<String, dynamic>? userDetails;

  Future<void> ImageData() async {
    final memberIdsAndUserIds =
        await DatabaseHelper.instance.getAllMemberIdsAndUserIds();
    print('Member IDs and User IDs: $memberIdsAndUserIds');
    int memberId = widget.loanApplicationDetails['member_id'];
    print('MemberId: $memberId');
    loanerId = (await DatabaseHelper.instance.getUserIdForId(memberId))!;
    print('LoanerId: $loanerId');
    userDetails = await DatabaseHelper.instance.getUserDataById(loanerId);
    print('phone: ${userDetails!["phone"]}');
  }

  // Future<Uint8List?> getDefaultImage() async {
  //   const defaultImagePath = 'assets/background.jpeg';
  //   final defaultImageData = await rootBundle.load(defaultImagePath);
  //   print('Default: ${defaultImageData.buffer.asUint8List()}');
  //   _bytesImage = defaultImageData.buffer.asUint8List();
  //   return _bytesImage;
  // }

  Future<Uint8List?> getImageForMember() async {
    try {
      String? imageData =
          await DatabaseHelper.instance.getImagePathForMember(loanerId);
      print('Image path Member: $imageData');

      // Check if imageData is null before using the null check operator.
      if (imageData == null) {
        const defaultImagePath = 'assets/background.jpeg';
        final defaultImageData = await rootBundle.load(defaultImagePath);
        print('Default: ${defaultImageData.buffer.asUint8List()}');
        _bytesImage = defaultImageData.buffer.asUint8List();
        return _bytesImage;
      } else {
        _bytesImage = const Base64Decoder().convert(imageData);
        return _bytesImage;
      }
    } catch (e) {
      print('Error: $e');
      return null; // Return null in case of an error.
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('EEEE, MMMM d, y').format(
      DateTime.parse(widget.loanApplicationDetails['start_date']),
    );

    String dueDate = DateFormat('EEEE, MMMM d, y').format(
      DateTime.parse(widget.loanApplicationDetails['end_date']),
    );

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 224, 248, 225),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: const Color.fromARGB(255, 235, 233, 233),
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        borderRadius: BorderRadius.circular(20),
                        child: SizedBox(
                          height: 100,
                          width: 100,
                          child: FittedBox(
                            child: Image.memory(_bytesImage ?? Uint8List(0)),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Name: ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 0, 43, 2),
                                  ),
                                ),
                                Text(
                                  widget
                                      .loanApplicationDetails['loan_applicant'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 0, 43, 2),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Row(
                              children: [
                                const Text(
                                  'Contact: ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color.fromARGB(255, 15, 46, 15),
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  userDetails!['phone'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color.fromARGB(255, 15, 46, 15),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: const Color.fromARGB(255, 235, 233, 233),
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Loaning Date',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 0, 43, 2),
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                const Icon(Icons.calendar_month),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  formattedDate,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color.fromARGB(255, 0, 29, 0),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            const Divider(),
                            const SizedBox(
                              height: 5,
                            ),
                            const Text(
                              'Due Date',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 0, 43, 2),
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_month,
                                  color: Colors.red,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  dueDate,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: const Color.fromARGB(255, 235, 233, 233),
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Loan Purpose',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 0, 43, 2),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                const Icon(Icons.edit_note_sharp),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  widget.loanApplicationDetails['loan_purpose'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color.fromARGB(255, 1, 32, 1),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: const Color.fromARGB(255, 235, 233, 233),
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: ListTile(
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Payment Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 0, 43, 2),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      CustomDataRow(
                          title: 'Loan Amount Taken',
                          value:
                              'UGX ${widget.loanApplicationDetails['amount_needed'].toString()},'),
                      CustomDataRow(
                          title: 'Loan Interest',
                          value:
                              'UGX ${(widget.loanApplicationDetails['amount_needed'] * 20 / 100).toString()},'),
                      CustomDataRow(
                        title: 'Amount Cleared',
                        value:
                            'UGX ${calculateAmountCleared(widget.paymentInfo).toStringAsFixed(2)}',
                      ),
                      CustomDataRow(
                        title: 'Loan Balance',
                        value:
                            'UGX ${calculateLoanBalance(widget.loanApplicationDetails, widget.paymentInfo).toStringAsFixed(2)}',
                        valueColor: calculateLoanBalance(
                                    widget.loanApplicationDetails,
                                    widget.paymentInfo) ==
                                0.0
                            ? Colors.green // If balance is 0.0, use green color
                            : const Color.fromARGB(255, 163, 13, 2),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
