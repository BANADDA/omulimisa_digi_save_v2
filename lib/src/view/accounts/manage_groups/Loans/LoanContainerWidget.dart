import 'package:flutter/material.dart';
import '/src/view/accounts/manage_groups/Loans/loan_details.dart';

import 'loan_class.dart';

class LoanContainerWidget extends StatelessWidget {
  final String name;
  final double loanTaken;
  final double balance;
  final bool cleared;
  final double clearedAmount;
  final Loan loan;
  final Map<String, dynamic> loanApplicationDetails;
  final Map<String, dynamic> paymentInfo;

  const LoanContainerWidget({
    super.key,
    required this.name,
    required this.loanTaken,
    required this.balance,
    required this.cleared,
    required this.clearedAmount,
    required this.loan,
    required this.loanApplicationDetails,
    required this.paymentInfo,
  });

  @override
  Widget build(BuildContext context) {
    void navigateToGroupStart(Loan loan, loanApplicationDetails, paymentInfo) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SwipeScreens(
              loan: loan,
              loanApplicationDetails: loanApplicationDetails,
              paymentInfo: paymentInfo),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color.fromARGB(255, 235, 233, 233),
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Row(
                  children: [
                    const Text(
                      'Loan Taken: ',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'UGX ${loanTaken.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      'Balance: ',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'UGX ${balance.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const VerticalDivider(
              color: Color.fromARGB(255, 235, 233, 233),
              width: 1,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cleared ? 'Cleared' : 'Not Cleared',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (cleared)
                  Row(
                    children: [
                      Text(
                        'UGX ${clearedAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Color.fromARGB(255, 1, 143, 5),
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ElevatedButton(
                  onPressed: () {
                    navigateToGroupStart(
                        loan, loanApplicationDetails, paymentInfo);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 0, 103, 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  child: const Text(
                    'View',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 19.0,
                      color: Colors.white,
                    ),
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
