import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../../../database/localStorage.dart';

class MemberSocialFund {
  final String memberId;
  final double loanAmount;
  final String loanPurpose;
  final DateTime repaymentDate;

  MemberSocialFund({
    required this.memberId,
    required this.loanAmount,
    required this.loanPurpose,
    required this.repaymentDate,
  });
}

class SocialFundApplication extends StatefulWidget {
  final String groupId;
  final String cycleId;
  final String meetingId;
  final List<Map<String, dynamic>> groupMembers;
  final Function(List<Map<String, dynamic>>) onRecentActivityUpdated;

  const SocialFundApplication({super.key, 
    required this.groupMembers,
    required this.onRecentActivityUpdated,
    required this.groupId,
    required this.cycleId,
    required this.meetingId,
  });

  @override
  _SocialFundApplicationState createState() => _SocialFundApplicationState();
}

class _SocialFundApplicationState extends State<SocialFundApplication> {
  String? selectedMemberId; // Selected member ID
  double loanAmount = 0.0;
  String loanPurpose = '';
  DateTime repaymentDate = DateTime.now();
  List<Map<String, dynamic>> recentActivity = [];
  List<MemberSocialFund> memberLoans = [];

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> dropdownItems = widget.groupMembers;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 1, 67, 3),
        title: const Text(
          'Social Fund Application',
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
              const Text('Social Fund Amount Needed:'),
              TextFormField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    loanAmount = double.tryParse(value) ?? 0.0;
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text('Purpose of Social Fund:'),
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

                          // Check if the member has already applied for a loan on the same date
                          final existingLoan =
                              await checkExistingSocialApplication(
                            widget.groupId,
                            widget.cycleId,
                            widget.meetingId,
                            selectedMemberId!,
                            applicationDate,
                          );

                          if (existingLoan != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'This member has already applied for a social today.'),
                              ),
                            );
                            return;
                          }

                          final selectedMember = widget.groupMembers.firstWhere(
                            (member) =>
                                member['id'].toString() == selectedMemberId,
                            orElse: () => {},
                          );

                          if (selectedMember.isNotEmpty) {
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

                            // Define the loan application data
                            final loanApplicationData = {
                              'group_id': widget.groupId,
                              'cycle_id': widget.cycleId,
                              'meeting_id': widget.meetingId,
                              'submission_date':
                                  applicationDate.toIso8601String(),
                              'applicant': activity['memberName'],
                              'group_member_id': selectedMemberId,
                              'amount_needed': loanAmount,
                              'social_purpose': loanPurpose,
                              'repayment_date': repaymentDate.toIso8601String(),
                            };

                            final DatabaseHelper dbHelper =
                                DatabaseHelper.instance;

                            // Insert the loan application data into the database
                            final insertedId = await dbHelper
                                .insertSocialApplication(loanApplicationData);

                            // Check if the data was inserted successfully
                            if (insertedId != null) {
                              print('Loan Application: $loanApplicationData');
                              // Data inserted successfully, close the screen
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
                      'Submit Form',
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

  // Function to check for an existing loan application in the database
  Future<Map<String, dynamic>?> checkExistingSocialApplication(
      String groupId,
      String cycleId,
      String meetingId,
      String memberId,
      DateTime applicationDate) async {
    final DatabaseHelper dbHelper = DatabaseHelper.instance;
    final existingSocialApplication =
        await dbHelper.getSocialApplicationByDetails(
      groupId,
      cycleId,
      meetingId,
      memberId,
      applicationDate,
    );
    return existingSocialApplication;
  }
}
