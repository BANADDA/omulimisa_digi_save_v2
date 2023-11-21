import 'package:flutter/material.dart';

class MemberDetailsScreen extends StatelessWidget {
  final int memberId;
  final List<Map<String, dynamic>> memberDetails;

  const MemberDetailsScreen({super.key, 
    required this.memberId,
    required this.memberDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Member Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Member ID: $memberId', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            const Text('Member Details:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            for (var detail in memberDetails) ...[
              const SizedBox(height: 8),
              Text('Name: ${detail['fname']} ${detail['lname']}'),
              Text('Email: ${detail['email']}'),
              Text('Phone: ${detail['phone']}'),
              // Add more fields as needed
            ],
          ],
        ),
      ),
    );
  }
}
