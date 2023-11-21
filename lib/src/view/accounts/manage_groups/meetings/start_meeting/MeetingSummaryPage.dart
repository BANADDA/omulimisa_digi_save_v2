import 'package:flutter/material.dart';

class MeetingSummaryPage extends StatelessWidget {
  final DateTime meetingEndTime;
  final String meetingPurpose;
  final String location;
  final List<String> objectives;
  final Map<String, Map<String, bool>> attendanceData;
  final List<String> proposals;
  final String concludingRemarks;

  const MeetingSummaryPage({super.key, 
    required this.meetingEndTime,
    required this.meetingPurpose,
    required this.location,
    required this.objectives,
    required this.attendanceData,
    required this.proposals,
    required this.concludingRemarks,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meeting Summary'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Meeting End Time: ${meetingEndTime.toLocal()}'),
            const SizedBox(height: 16.0),
            Text('Meeting Purpose: $meetingPurpose'),
            const SizedBox(height: 16.0),
            Text('Location: $location'),
            const SizedBox(height: 16.0),
            const Text('Objectives:'),
            ListView.builder(
              shrinkWrap: true,
              itemCount: objectives.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Text('${index + 1}.'),
                  title: Text(objectives[index]),
                );
              },
            ),
            const SizedBox(height: 16.0),
            const Text('Attendance Data:'),
            // Display attendance data here as needed
            const SizedBox(height: 16.0),
            const Text('Proposals:'),
            ListView.builder(
              shrinkWrap: true,
              itemCount: proposals.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Text('${index + 1}.'),
                  title: Text(proposals[index]),
                );
              },
            ),
            const SizedBox(height: 16.0),
            const Text('Concluding Remarks & Adjournments:'),
            Text(concludingRemarks),
          ],
        ),
      ),
    );
  }
}
