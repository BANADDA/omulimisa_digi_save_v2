import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../../../database/localStorage.dart';
import 'PaymentInfo.dart';
import 'loan_applications.dart';

class LoanFundPaymentScreen extends StatefulWidget {
  final String groupId;
  final String cycleId;
  final String? meetingId;

  const LoanFundPaymentScreen(
      {Key? key, required this.groupId, required this.cycleId, this.meetingId})
      : super(key: key);

  @override
  _LoanFundPaymentScreenState createState() => _LoanFundPaymentScreenState();
}

class _LoanFundPaymentScreenState extends State<LoanFundPaymentScreen> {
  late List<LoanApplication> loanApplications = [];
  late List paymentDetails = [];
  Map<String, double> paymentAmounts = {};

  TextEditingController paymentController = TextEditingController();
  String loanStatus = '';

  @override
  void initState() {
    super.initState();
    // Fetch loan applications for the specific group and cycle
    fetchLoanApplications();
  }

  void fetchLoanApplications() async {
    loanApplications = await DatabaseHelper.instance
        .getLoanApplicationsForGroupAndCycle(widget.groupId);
    paymentDetails =
        await DatabaseHelper.instance.getAllPaymentForGroup(widget.groupId);
    // print('Payment Details');
    // print(paymentDetails);
    setState(() {});
  }

  String formatDateWithoutTime(DateTime dateTime) {
    final formatter = DateFormat('yyyy-MM-dd'); // Format as 'YYYY-MM-DD'
    return formatter.format(dateTime);
  }

  DatabaseHelper dbHelper = DatabaseHelper.instance;

  Future<double> calculateTotalPayments(
      String groupId, String memberId, String loanId) async {
    double totalPayments =
        await dbHelper.getTotalPaymentsForLoan(groupId, memberId, loanId);
    return totalPayments;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 224, 250, 224),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 1, 67, 3),
          title: const Text(
            'Loan Fund Payment',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          elevation: 0.0,
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
        ),
        body: FutureBuilder(
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return SingleChildScrollView(
                  child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
                child: Column(
                  children: [
                    Column(
                      children: loanApplications.map((loan) {
                        final paymentController = TextEditingController();
                        return Container(
                          padding: const EdgeInsets.all(
                              8.0), // Adjust padding as needed
                          margin: const EdgeInsets.symmetric(
                            vertical: 8.0, // Adjust margin as needed
                          ),
                          decoration: BoxDecoration(
                            color: Colors
                                .white, // Set the background color to white
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(
                                8.0), // Add rounded corners
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                loan.loanApplicant,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Row(
                                children: [
                                  const Text(
                                    'Loan Amount Taken: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                      color: Color.fromARGB(255, 29, 28, 28),
                                    ),
                                  ),
                                  Text(
                                    'UGX ${loan.amountNeeded.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                      color: Color.fromARGB(255, 105, 1, 1),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                              LoanPaymentWidget(
                                loan: loan,
                                groupId: widget.groupId,
                                onPaymentAmountChanged: (double amount) {
                                  paymentAmounts[
                                          "${loan.groupMemberId}_${loan.id}"] =
                                      amount;
                                },
                                paymentController: paymentController,
                              )
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        // Iterate over loanApplications to capture payment amounts
                        for (LoanApplication loan in loanApplications) {
                          try {
                            double paymentAmount = paymentAmounts[
                                    "${loan.groupMemberId}_${loan.id}"] ??
                                0.0;

                            print('Payment Amount db: $paymentAmount');

                            // Call the function to save the payment information
                            DateTime now = DateTime.now();
                            DateTime paymentDate =
                                DateTime(now.year, now.month, now.day);

                            PaymentInfo paymentInfo = PaymentInfo(
                              groupId: widget.groupId,
                              loanId: loan.id,
                              memberID: loan.groupMemberId,
                              amount: paymentAmount,
                              paymentDate: paymentDate,
                            );
                            print('Payment Data: $paymentAmount');

                            await DatabaseHelper.instance
                                .savePaymentInfo(paymentInfo);

                            setState(() {
                              paymentController.clear(); // Clear the TextField
                            });

                            String dateWithoutTime =
                                formatDateWithoutTime(DateTime.now().toLocal());

                            final prefs = await SharedPreferences.getInstance();
                            final loggedInUserId = prefs.getInt('userId');
                            final deductionData = {
                              'group_id': widget.groupId,
                              'logged_in_user_id': loggedInUserId,
                              'date': dateWithoutTime,
                              'purpose': 'Loan payment',
                              'amount': paymentAmount,
                            };
                            final savingsAccount = await DatabaseHelper.instance
                                .insertSavingsAccount(deductionData);
                            print(
                                'Savings Account Inserted for $savingsAccount: $deductionData');

                            // Check if remaining balance is zero and update loan status
                            double allPaymentAmount =
                                await calculateTotalPayments(widget.groupId,
                                    loan.groupMemberId, loan.id);
                            double remainingBalance =
                                loan.amountNeeded - allPaymentAmount;
                            print('Remaining balance: $remainingBalance');
                            print('amountNeeded: ${loan.amountNeeded}');
                            print('paymentAmount: $paymentAmount');
                            if (remainingBalance <= 0.0) {
                              print(
                                  'Updating loan status to Cleared for loan id: ${loan.id}');
                              await DatabaseHelper.instance.updateLoanStatus(
                                  widget.groupId,
                                  loan.id,
                                  loan.groupMemberId,
                                  'Cleared');
                            }
                          } catch (e) {
                            // Handle the exception here, e.g., show an error message or log the error.
                            print('Error: $e');
                          }
                        }
                        // Show a success message using a SnackBar
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Payments saved successfully')),
                        );

                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => LoanFundPaymentScreen(
                              groupId: widget.groupId,
                              cycleId: widget.cycleId,
                              meetingId: widget.meetingId,
                            ),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.green,
                        backgroundColor: const Color.fromARGB(255, 0, 103, 4),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0)),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 5.0,
                        ),
                        child: Text(
                          'Submit',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.0,
                              color: Colors.white),
                        ),
                      ),
                    )
                  ],
                ),
              ));
            }
          },
          future: null,
        ));
  }
}

class LoanPaymentWidget extends StatefulWidget {
  final LoanApplication loan;
  String groupId;
  final ValueChanged<double> onPaymentAmountChanged;
  final TextEditingController paymentController;

  LoanPaymentWidget({
    super.key,
    required this.loan,
    required this.groupId,
    required this.onPaymentAmountChanged,
    required this.paymentController,
    required,
  });

  @override
  _LoanPaymentWidgetState createState() => _LoanPaymentWidgetState();
}

class _LoanPaymentWidgetState extends State<LoanPaymentWidget> {
  double paymentAmount = 0;
  double totalPaid = 0;

  @override
  void initState() {
    super.initState();
    // Fetch the total paid for this loan from the payments table
    fetchTotalPaidForLoan();
  }

  void fetchTotalPaidForLoan() async {
    // Query the database to calculate the total payments for this loan
    final totalPaidForLoan = await DatabaseHelper.instance
        .getTotalPaidForLoan(widget.loan.id, widget.groupId);
    print('Total paid');
    print(totalPaidForLoan);
    setState(() {
      totalPaid = totalPaidForLoan;
    });
  }

  @override
  Widget build(BuildContext context) {
    double remainingBalance = 0;
    remainingBalance = widget.loan.amountNeeded - totalPaid;
    print('Remaning balance: $remainingBalance');
    bool isEnable = false;

    return Column(
      children: [
        Column(
          children: [
            TextField(
              enabled: remainingBalance > 0.0,
              controller: widget.paymentController,
              decoration: const InputDecoration(
                labelText: 'Enter Payment Amount',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                double paymentAmount = double.tryParse(value) ?? 0;
                if (paymentAmount > widget.loan.amountNeeded) {
                  paymentAmount = widget.loan.amountNeeded;
                }
                // Notify the parent widget of the payment amount change
                widget.onPaymentAmountChanged(paymentAmount);
              },
            ),
            Row(
              children: [
                const Text(
                  'Loan Balance: ',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  'UGX $remainingBalance', // Display remaining balance
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Text(
                  'Total Paid: ',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  'UGX $totalPaid', // Display total paid for this loan
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Text(
                  'Loan Status: ',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  widget.loan.LoanStatus,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: widget.loan.LoanStatus == 'Active'
                        ? Colors.red
                        : Colors.green,
                  ),
                ),
              ],
            )
          ],
        ),
      ],
    );
  }
}
