import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../../../database/localStorage.dart';
import 'LoanEditingScreen.dart';

class RecentActivityScreen extends StatefulWidget {
  final int groupId;
  final int cycleId;
  final int meetingId;
  const RecentActivityScreen({
    super.key,
    required this.groupId,
    required this.cycleId,
    required this.meetingId,
  });
  @override
  _RecentActivityScreenState createState() => _RecentActivityScreenState();
}

class _RecentActivityScreenState extends State<RecentActivityScreen> {
  List<Map<String, dynamic>> recentActivity = [];

  @override
  void initState() {
    super.initState();
    fetchRecentActivityData(widget.groupId, widget.cycleId, widget.meetingId);
  }

  // Fetch recent loan application data from the database
  void fetchRecentActivityData(int groupId, int meetingId, int cycleId) async {
    try {
      final DatabaseHelper dbHelper = DatabaseHelper.instance;
      final List<Map<String, dynamic>> activityData =
          await dbHelper.getRecentLoanActivity(groupId);

      setState(() {
        recentActivity = activityData;
      });
    } catch (e) {
      print('Error fetching recent activity: $e');
    }
  }

  Future<void> _navigateToLoanEditingScreen(
      Map<String, dynamic> loanData) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LoanEditingScreen(
          groupId: widget.groupId,
          loanData: loanData,
        ),
      ),
    );

    if (result != null && result) {
      // Refresh recent activity data
      fetchRecentActivityData(widget.groupId, widget.cycleId, widget.meetingId);
    }
  }

  String formatDateWithoutTime(DateTime dateTime) {
    final formatter = DateFormat('yyyy-MM-dd'); // Format as 'YYYY-MM-DD'
    return formatter.format(dateTime);
  }

  Future<void> _showConfirmationDialog(Function onConfirm) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Dismissible only with "Cancel" button
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Reversal'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to reverse this transaction?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () {
                onConfirm();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 1, 67, 3),
        title: const Text(
          'Recent Loan Activities',
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
      body: ListView.builder(
        itemCount: recentActivity.length,
        itemBuilder: (context, index) {
          final activity = recentActivity[index];
          final submissionDate = activity['start_date'] != null
              ? DateTime.parse(activity['start_date'])
              : DateTime.now();

          // Check if this is the first entry or if the start_date is different from the previous one
          final bool isFirstEntry = index == 0 ||
              submissionDate !=
                  DateTime.parse(recentActivity[index - 1]['start_date']);

          if (isFirstEntry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Text(
                    'Activities on ${DateFormat('MMMM dd, yyyy').format(submissionDate)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildActivityList(activity),
              ],
            );
          } else {
            return _buildActivityList(activity);
          }
        },
      ),
    );
  }

  Widget _buildActivityList(Map<String, dynamic> activity) {
    final memberName = activity['loan_applicant'] ??
        'N/A'; // Provide a default value if memberName is null
    final loanStatus = activity['status'] ?? 'N/A'; // Loan status
    print('Loan status: $loanStatus');
    final loanAmount = activity['loan_amount'] ??
        0.0; // Provide a default value if loanAmount is null
    final loanPurpose = activity['loan_purpose'] ??
        'N/A'; // Provide a default value if loanPurpose is null
    final repaymentDate = activity['end_date'] != null
        ? DateTime.parse(activity['end_date'])
        : DateTime
            .now(); // Use DateTime.now() as a default date if repaymentDate is null
    final submissionDate = activity['start_date'] != null
        ? DateTime.parse(activity['start_date'])
        : DateTime.now();

    final formattedSubmissionDate =
        DateFormat('yyyy-MM-dd').format(submissionDate);
    print('SubmissionDate: $formattedSubmissionDate');

    // Check if the submission date is today
    final DateTime now = DateTime.now();
    final DateTime applicationDate = DateTime(now.year, now.month, now.day);

    print('Application Date: $applicationDate');
    final isToday = submissionDate.isAtSameMomentAs(applicationDate);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Member: $memberName'),
            Text('Loan Amount: UGX ${loanAmount.toStringAsFixed(2)}'),
            Text('Loan Purpose: $loanPurpose'),
            // Text(
            //     'Repayment Date: ${DateFormat('MMMM dd, yyyy').format(repaymentDate)}',
            //     ),
            Text(
              'Loan Status: $loanStatus',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: loanStatus == 'Active' ? Colors.red : Colors.green,
              ),
            ),
            if (isToday) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: loanStatus == 'Active'
                        ? () {
                            _navigateToLoanEditingScreen(activity);
                          }
                        : null,
                    style: TextButton.styleFrom(
                      backgroundColor: loanStatus == 'Active'
                          ? const Color.fromARGB(255, 0, 103, 4)
                          : Colors
                              .grey, // Set a different color when the button is disabled
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Text(
                          'Edit Loan',
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Icon(Icons.edit, color: Colors.white)
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (loanStatus == 'Active') {
                        // Delete the loan entry from the database.
                        print('Here');
                        await _showConfirmationDialog(() async {
                          final DatabaseHelper dbHelper =
                              DatabaseHelper.instance;

                          try {
                            Map<String, dynamic> deletedData =
                                await dbHelper.deleteLoanEntry(activity['id']);
                            if (deletedData.isNotEmpty) {
                              // Data was successfully deleted, and deletedData contains the deleted details
                              print(
                                  'Loan entry deleted: ${deletedData['loan_amount']}');
                              String dateWithoutTime = formatDateWithoutTime(
                                  DateTime.now().toLocal());

                              final prefs =
                                  await SharedPreferences.getInstance();
                              final loggedInUserId = prefs.getInt('userId');
                              final deductionData = {
                                'group_id': widget.groupId,
                                'logged_in_user_id': loggedInUserId,
                                'date': dateWithoutTime,
                                'purpose': 'Reverse Transaction',
                                'amount': deletedData['loan_amount'],
                              };
                              final savingsAccount = await DatabaseHelper
                                  .instance
                                  .insertSavingsAccount(deductionData);
                              print(
                                  'Savings Account Inserted for $savingsAccount: $deductionData');
                              // Reversed Data
                              Map<String, dynamic> reversedData = {
                                'group_id': widget.groupId,
                                'savings_account_id': savingsAccount,
                                'logged_in_user_id': loggedInUserId,
                                'date': dateWithoutTime,
                                'purpose': 'Reverse loan',
                                'reversed_amount': deletedData['loan_amount'],
                                'reversed_data': deletedData
                              };

                              int reverse = await DatabaseHelper.instance
                                  .inserReversedTransactions(reversedData);

                              if (reverse != 0) {
                                print(
                                    'Savings data inserted successfully with ID: $reverse.');
                                print('Savings data: $reversedData.');
                              } else {
                                print('Failed to insert savings data.');
                              }

                              // Fetch the updated recent activity data
                              fetchRecentActivityData(widget.groupId,
                                  widget.cycleId, widget.meetingId);
                            } else {
                              // Data was not found or not deleted
                              print('Loan entry not found or deletion failed.');
                            }
                          } catch (e) {
                            // Handle any exceptions that may occur during the deletion process
                            print('Error deleting loan entry: $e');
                          }
                        });
                      }
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: loanStatus == 'Active'
                          ? const Color.fromARGB(255, 0, 103, 4)
                          : Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Text(
                          'Reverse',
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Icon(
                          Icons.delete,
                          color: Colors.white,
                        )
                      ],
                    ),
                  )
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
