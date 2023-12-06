import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../../../database/localStorage.dart';
import 'social_editing_screen.dart';

class SocialRecentActivityScreen extends StatefulWidget {
  final String groupId;
  final String cycleId;
  final String meetingId;
  const SocialRecentActivityScreen({super.key, 
    required this.groupId,
    required this.cycleId,
    required this.meetingId,
  });
  @override
  _SocialRecentActivityScreenState createState() =>
      _SocialRecentActivityScreenState();
}

class _SocialRecentActivityScreenState
    extends State<SocialRecentActivityScreen> {
  List<Map<String, dynamic>> recentActivity = [];

  @override
  void initState() {
    super.initState();
    fetchRecentActivityData(widget.groupId, widget.cycleId, widget.meetingId);
  }

  // Fetch recent social activity data from the database for a specific group, meeting, and cycle
  void fetchRecentActivityData(String groupId, String meetingId, String cycleId) async {
    try {
      final DatabaseHelper dbHelper = DatabaseHelper.instance;
      final List<Map<String, dynamic>> activityData =
          await dbHelper.getRecentSocialActivity(groupId, meetingId, cycleId);
      print('Recent activity: $activityData');
      setState(() {
        recentActivity = activityData;
      });
    } catch (e) {
      print('Error fetching recent social activity: $e');
    }
  }

  Future<void> _navigateToLoanEditingScreen(
      Map<String, dynamic> loanData) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SocialEditingScreen(
          loanData: loanData,
        ),
      ),
    );

    if (result != null && result) {
      // Refresh recent activity data
      fetchRecentActivityData(widget.groupId, widget.cycleId, widget.meetingId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 1, 67, 3),
        title: const Text(
          'Recent Social Activities',
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
          final submissionDate = activity['submission_date'] != null
              ? DateTime.parse(activity['submission_date'])
              : DateTime.now();

          // Check if this is the first entry or if the submission_date is different from the previous one
          final bool isFirstEntry = index == 0 ||
              submissionDate !=
                  DateTime.parse(recentActivity[index - 1]['submission_date']);

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
    final memberName = activity['applicant'] ??
        'N/A'; // Provide a default value if memberName is null
    final loanAmount = activity['amount_needed'] ??
        0.0; // Provide a default value if loanAmount is null
    final loanPurpose = activity['social_purpose'] ??
        'N/A'; // Provide a default value if loanPurpose is null
    final repaymentDate = activity['repayment_date'] != null
        ? DateTime.parse(activity['repayment_date'])
        : DateTime
            .now(); // Use DateTime.now() as a default date if repaymentDate is null
    final submissionDate = activity['submission_date'] != null
        ? DateTime.parse(activity['submission_date'])
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
            Text(
              'Repayment Date: ${DateFormat('MMMM dd, yyyy').format(repaymentDate)}',
            ),
            if (isToday) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _navigateToLoanEditingScreen(activity);
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 0, 103, 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Text(
                          'Edit Fund',
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
                      // Delete the loan entry from the database.
                      final DatabaseHelper dbHelper = DatabaseHelper.instance;
                      await dbHelper.deleteSocialEntry(activity['id']);

                      // Fetch the updated recent activity data
                      fetchRecentActivityData(
                          widget.groupId, widget.cycleId, widget.meetingId);
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 0, 103, 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Text(
                          'Delete',
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
