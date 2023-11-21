import 'package:flutter/material.dart';
import '/database/localStorage.dart';

import 'LoanContainerWidget.dart';
import 'loan_class.dart';

class LoanStatus extends StatefulWidget {
  final int? groupId;
  final String? groupName;
  final List<Loan>? loans;
  const LoanStatus({super.key, this.groupId, this.groupName, this.loans});

  @override
  State<LoanStatus> createState() => _LoanStatusState();
}

class _LoanStatusState extends State<LoanStatus> {
  List<Loan> loans = [];
  List<Map<String, dynamic>> loanApplicationDetails = []; // Declare this list
  List<Map<String, dynamic>> paymentInfoList = [];
  @override
  void initState() {
    super.initState();

    // Get the member IDs for all members of the group.
    DatabaseHelper.instance.getMemberIds(widget.groupId!).then((memberIds) {
      print('Member IDs: $memberIds'); // Print member IDs

      // Get the loan application details for all members of the group.
      DatabaseHelper.instance
          .getLoanApplicationDetails(widget.groupId!)
          .then((details) {
        setState(() {
          loanApplicationDetails =
              details; // Update the loanApplicationDetails list
        });
        print(
            'Loan Application Details: $loanApplicationDetails'); // Print loan application details

        // Fetch the payment information for all members of the group.
        final fetchPaymentInfoTasks = memberIds.map((memberId) {
          return DatabaseHelper.instance
              .getPaymentInfo(memberId, widget.groupId!);
        });

        Future.wait(fetchPaymentInfoTasks)
            .then((List<Map<String, dynamic>?> infoList) {
          setState(() {
            paymentInfoList = infoList
                .where((info) => info != null) // Filter out null values
                .map((info) =>
                    info as Map<String, dynamic>) // Cast non-null values
                .toList(); // Convert to a List
          });
          print(
              'Payment Information List: $paymentInfoList'); // Print payment information list

          // Create a list of Loan objects based on the payment information for each member.
          final loans = <Loan>[];

          for (int i = 0; i < memberIds.length; i++) {
            final memberId = memberIds[i];
            final loanApplicationDetail = loanApplicationDetails.firstWhere(
              (detail) => detail['member_id'] == memberId,
              orElse: () => {
                'loan_applicant': 'Unknown',
                'loan_amount': 0.0,
                // Add other default values as needed
              },
            );

            final loanTaken = loanApplicationDetail['loan_amount'];
            final paymentInfo = paymentInfoList[i] ??
                {
                  'payment_amount': 0.0
                }; // Default value if payment info is not found

            final loan = Loan(
              name: loanApplicationDetail['loan_applicant'],
              loanTaken: loanTaken,
              balance: loanTaken - paymentInfo['payment_amount'],
              cleared: paymentInfo['payment_amount'] == loanTaken,
              clearedAmount: paymentInfo['payment_amount'],
            );

            loans.add(loan);
          }

          // Set the state of the screen with the list of Loan objects.
          setState(() {
            this.loans = loans;
          });
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 1, 67, 3),
        title: const Text(
          'Current Group Loans',
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: loans.isNotEmpty
                  ? ListView.builder(
                      itemCount: loans.length,
                      itemBuilder: (context, index) {
                        final loan = loans[index];

                        if (!loan.cleared) {
                          return LoanContainerWidget(
                            name: loan.name,
                            loanTaken: loan.loanTaken,
                            balance: loan.balance,
                            cleared: loan.cleared,
                            clearedAmount: loan.clearedAmount,
                            loan: loan,
                            loanApplicationDetails:
                                loanApplicationDetails[index],
                            paymentInfo: paymentInfoList[index],
                          );
                        } else {
                          return Container();
                        }
                      },
                    )
                  : const Center(
                      child: Text('No loans available'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
