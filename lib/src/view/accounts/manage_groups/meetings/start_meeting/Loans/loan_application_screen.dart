import 'package:bottom_bar_matu/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../../../database/localStorage.dart';

class MemberLoan {
  final String memberId;
  final double loanAmount;
  final String loanPurpose;
  final DateTime repaymentDate;

  MemberLoan({
    required this.memberId,
    required this.loanAmount,
    required this.loanPurpose,
    required this.repaymentDate,
  });
}

class LoanApplicationScreen extends StatefulWidget {
  final int groupId;
  final int cycleId;
  final int meetingId;
  final List<Map<String, dynamic>> groupMembers;
  final Function(List<Map<String, dynamic>>) onRecentActivityUpdated;

  const LoanApplicationScreen({
    super.key,
    required this.groupMembers,
    required this.onRecentActivityUpdated,
    required this.groupId,
    required this.cycleId,
    required this.meetingId,
  });

  @override
  _LoanApplicationScreenState createState() => _LoanApplicationScreenState();
}

class _LoanApplicationScreenState extends State<LoanApplicationScreen> {
  String? selectedMemberId; // Selected member ID
  double loanAmount = 0.0;
  String loanPurpose = '';
  DateTime repaymentDate = DateTime.now();
  List<Map<String, dynamic>> recentActivity = [];
  List<MemberLoan> memberLoans = [];
  double? InterestRate;

  double totalGroupSavings = 0;

  Future<void> fetchInterestRate(int groupId) async {
    try {
      InterestRate = await DatabaseHelper.instance.getInterestRate(groupId);
      totalGroupSavings =
          await DatabaseHelper.instance.getTotalGroupSavings(widget.groupId);
      print('Group Savings; $totalGroupSavings');

      final loans =
          await DatabaseHelper.instance.getAllLoansForGroup(widget.groupId);
      print('Loans: $loans');

      print('Interest Rate: $InterestRate');
    } catch (e) {
      print('Error: $e');
    }
  }

  String formatDateWithoutTime(DateTime dateTime) {
    final formatter = DateFormat('yyyy-MM-dd'); // Format as 'YYYY-MM-DD'
    return formatter.format(dateTime);
  }

  @override
  void initState() {
    fetchInterestRate(widget.groupId);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> dropdownItems = widget.groupMembers;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 1, 67, 3),
        title: const Text(
          'Loan Application',
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select Member:'),
              DropdownButton<String>(
                value: selectedMemberId,
                onChanged: (newValue) {
                  setState(() {
                    selectedMemberId = newValue;
                  });
                },
                items: dropdownItems.map((member) {
                  return DropdownMenuItem<String>(
                    value: member['id'].toString(),
                    child: Text(
                      '${member['fname']} ${member['lname']}',
                    ),
                  );
                }).toList(),
                hint: const Text('Select a member'), // Placeholder text
              ),
              const SizedBox(height: 16),
              const Text('Amount Needed:'),
              TextFormField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    loanAmount = double.tryParse(value) ?? 0.0;
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text('Purpose of Loan:'),
              TextFormField(
                onChanged: (value) {
                  setState(() {
                    loanPurpose = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text('Repayment Date:'),
              ElevatedButton(
                onPressed: () async {
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: repaymentDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 90)),
                  );

                  if (selectedDate != null) {
                    setState(() {
                      repaymentDate = selectedDate;
                    });
                  }
                },
                style: TextButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 0, 103, 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                child: const Text(
                  'Select Repayment Date',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Text(
                'Selected Repayment Date: ${DateFormat('MMMM dd, yyyy').format(repaymentDate)}',
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        // Handle loan application submission here
                        if (selectedMemberId != null) {
                          final DateTime now = DateTime.now();
                          final DateTime applicationDate =
                              DateTime(now.year, now.month, now.day);

                          final selectedMember = widget.groupMembers.firstWhere(
                            (member) =>
                                member['id'].toString() == selectedMemberId,
                            orElse: () => {},
                          );

                          if (selectedMember.isNotEmpty) {
                            // Check if the selected member already has a loan
                            bool hasLoans = await DatabaseHelper.instance
                                .doesMemberHaveActiveLoan(
                                    widget.groupId, selectedMemberId.toInt());
                            print('Has loan? $hasLoans');
                            print('Group Id: ${widget.groupId}');

                            if (hasLoans) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'The selected member already has an active loan. Please repay the existing loan before applying for a new one.'),
                                ),
                              );
                              return;
                            }

                            // Get total shares for the selected member in the cycle
                            final totalShares = await DatabaseHelper.instance
                                .getTotalShareQuantityForMemberInCycle(
                                    widget.cycleId, selectedMemberId!);
                            print('Total Shares:$totalShares');

                            // Calculate the maximum allowed loan amount
                            final maxAllowedLoanAmount = 3 * 20 * totalShares;
                            print('Total Shares: $maxAllowedLoanAmount');

                            // Compare the requested loan amount with the maximum allowed
                            if (loanAmount > maxAllowedLoanAmount) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Loan amount UGX $loanAmount exceeds the maximum allowed amount UGX $maxAllowedLoanAmount. Please request a lower amount.',
                                  ),
                                ),
                              );
                              return;
                            }

                            if (loanAmount > totalGroupSavings) {
                              print('Loan disbursed successfully!');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'The group has insufficient savings (UGX $totalGroupSavings), reduce your loan request and try again',
                                  ),
                                ),
                              );
                              return;
                            }

                            // Add the loan application activity to recentActivity
                            Map<String, dynamic> activity = {
                              'memberName':
                                  '${selectedMember['fname']} ${selectedMember['lname']}',
                              'loanAmount': loanAmount,
                              'loanPurpose': loanPurpose,
                              'repaymentDate': repaymentDate,
                            };
                            recentActivity.add(activity);

                            // Call the callback function to send the updated recentActivity data back
                            widget.onRecentActivityUpdated(recentActivity);
                            const status = 'Active';
                            double loanedMoney =
                                loanAmount + (loanAmount * InterestRate! / 100);
                            print('Loaned Money: $loanedMoney');
                            // Define the loan application data
                            final loanApplicationData = {
                              'groupId': widget.groupId,
                              'start_date': applicationDate.toIso8601String(),
                              'loan_applicant': activity['memberName'],
                              'member_id': selectedMemberId,
                              'interest_rate': InterestRate,
                              'loan_amount': loanedMoney,
                              'loan_purpose': loanPurpose,
                              'status': status,
                              'end_date': repaymentDate.toIso8601String(),
                            };

                            final DatabaseHelper dbHelper =
                                DatabaseHelper.instance;

                            // Insert the loan application data into the database
                            final insertedId =
                                await dbHelper.insertLoan(loanApplicationData);

                            // Check if the data was inserted successfully
                            if (insertedId != null) {
                              print('Loan Application: $loanApplicationData');

                              String dateWithoutTime = formatDateWithoutTime(
                                  DateTime.now().toLocal());

                              // You can insert disbursement records here
                              final disbursementData = {
                                'member_id': selectedMemberId,
                                'groupId': widget
                                    .groupId, // Set the group ID from your widget
                                'cycleId': widget.cycleId,
                                'loan_id':
                                    insertedId, // 'insertedId' is the ID of the inserted loan
                                'disbursement_amount':
                                    loanAmount, // Amount to be disbursed
                                'disbursement_date': dateWithoutTime,
                              };

                              final disbursementId = await dbHelper
                                  .insertDisbursement(disbursementData);

                              if (disbursementId != null) {
                                // Disbursement data inserted successfully
                                // Deduct the loan amount from the member's savings

                                String dateWithoutTime = formatDateWithoutTime(
                                    DateTime.now().toLocal());

                                final prefs =
                                    await SharedPreferences.getInstance();
                                final loggedInUserId = prefs.getInt('userId');
                                final deductionData = {
                                  'group_id': widget.groupId,
                                  'logged_in_user_id': loggedInUserId,
                                  'date': dateWithoutTime,
                                  'purpose': 'Loan disbursement',
                                  'amount':
                                      -loanAmount, // Negative amount represents a deduction
                                };
                                final savingsAccount = await dbHelper
                                    .insertSavingsAccount(deductionData);
                                print('Disbursement: $disbursementData');
                                print(
                                    'Savings Account Inserted for $savingsAccount: $deductionData');

                                totalGroupSavings = await DatabaseHelper
                                    .instance
                                    .getTotalGroupSavings(widget.groupId);
                                print('New Savings: UGX $totalGroupSavings');
                              } else {
                                // Handle disbursement insertion failure
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Failed to disburse the loan. Please try again.'),
                                  ),
                                );
                              }
                              Navigator.of(context).pop();
                            } else {
                              // Handle the case when data insertion fails
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Failed to submit loan application. Please try again.'),
                                ),
                              );
                            }
                          }
                        } else {
                          // Show an error message for not selecting a member
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please select a member for the loan application.',
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        // Handle any exceptions that occur during data insertion
                        print('Error submitting loan application: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'An error occurred while submitting the loan application.'),
                          ),
                        );
                      }
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 0, 103, 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    child: const Text(
                      'Submit Loan Application',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // // Function to check for an existing loan application in the database
  // Future<Map<String, dynamic>?> checkExistingLoanApplication(
  //     String memberId, DateTime applicationDate) async {
  //   final DatabaseHelper dbHelper = DatabaseHelper.instance;
  //   final existingLoan = await dbHelper.getLoanApplicationByDate(
  //     memberId,
  //     applicationDate,
  //   );
  //   return existingLoan;
  // }
}
